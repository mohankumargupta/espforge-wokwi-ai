//! TMP102 – Low-Power, Digital Temperature Sensor (I²C)
//! Wokwi Custom Chip · Zig 0.16 (No-std)
//!
//! Canonical test essentials: exposes a "temperature" float attribute (°C),
//! encodes it in the 12-bit two's-complement Temperature Register (0x00) and
//! answers I²C reads at address 0x48 (0x49 when ADD0 is tied high).
//!
//! Registers (16-bit, MSB stored first):
//!   0x00 Temperature   (R)
//!   0x01 Configuration (R/W) reset 0x6180
//!   0x02 TLOW          (R/W) reset 0x04B0 (75 °C)
//!   0x03 THIGH         (R/W) reset 0x0500 (80 °C)
//!
//! SPDX-License-Identifier: MIT

/// Opaque pin handle returned by pinInit.
const Pin = i32;

/// Opaque I²C device handle returned by i2cInit.
const I2cDev = u32;

const PinMode = enum(u32) {
    input = 0,
    output = 1,
    input_pullup = 2,
    input_pulldown = 3,
    analog = 4,
    output_low = 16,
    output_high = 17,
};

/// Passed to i2cInit; the struct is copied by the host so stack lifetime is fine.
const I2cConfig = extern struct {
    user_data: ?*anyopaque,
    address: u32,
    scl: Pin,
    sda: Pin,
    connect: *const fn (?*anyopaque, u32, bool) callconv(.c) bool,
    read: *const fn (?*anyopaque) callconv(.c) u8,
    write: *const fn (?*anyopaque, u8) callconv(.c) bool,
    disconnect: *const fn (?*anyopaque) callconv(.c) void,
};

// ─── Wokwi Host-Function Imports (WASM imports from "env") ──────────────────────

pub export fn __wokwi_api_version_1() u32 {
    return 1;
}

extern fn pinInit(name: [*:0]const u8, mode: u32) Pin;
extern fn pinRead(pin: Pin) u32;
extern fn attrInit(name: [*:0]const u8, default_value: f64) u32;
extern fn attrReadFloat(attr: u32) f64;
extern fn i2cInit(config: *const I2cConfig) I2cDev;

// ─── Register/bit constants ─────────────────────────────────────────────────────

const REG_TEMP: u8 = 0x00;
const REG_CONFIG: u8 = 0x01;
const REG_TLOW: u8 = 0x02;
const REG_THIGH: u8 = 0x03;

const ADDR_GND: u32 = 0x48; // ADD0 = GND  (default)
const ADDR_VCC: u32 = 0x49; // ADD0 = V+

const RESET_CONFIG: u16 = 0x6180;
const RESET_TLOW: u16 = 0x04B0; // 75 °C
const RESET_THIGH: u16 = 0x0500; // 80 °C

const LSB_DEGC: f64 = 0.0625; // one LSB = 0.0625 °C
const N_BITS: u32 = 12;
const TEMP_MASK: u16 = 0x0FFF; // 12-bit two's-complement window

// ─── Chip State ─────────────────────────────────────────────────────────────────

const ChipState = struct {
    i2c: I2cDev = 0,

    // Shadow registers, stored MSB-first in a byte-addressed file so that the
    // two bytes of each 16-bit register are read/written in the correct order.
    byte_regs: [8]u8 = [_]u8{0} ** 8,

    // I²C sequential-access byte pointer (0..7).
    reg_ptr: u8 = 0,
    has_reg_ptr: bool = false,

    // Read-in-progress position, restored from reg_ptr on each connect-read.
    read_pos: u8 = 0,

    // Resolved I²C address from the ADD0 pin.
    i2c_addr: u32 = ADDR_GND,

    // Pin handles.
    scl: Pin = 0,
    sda: Pin = 0,
    add0: Pin = 0,
    alert: Pin = 0,

    // Float attribute driving the temperature reading.
    temp_attr: u32 = 0,
};

// Global static state instead of dynamic allocation.
var global_chip: ChipState = undefined;

// ─── Temperature encoding ───────────────────────────────────────────────────────

/// Encode a signed temperature (°C) into 12-bit two's-complement raw value.
inline fn tempToRaw(deg_c: f64) u16 {
    const scaled: i64 = @intFromFloat(@round(deg_c / LSB_DEGC));
    return @intCast(@mod(scaled, 4096));
}

/// Refresh the two temperature register bytes from the live attribute value.
fn updateTemperature(chip: *ChipState) void {
    const raw = tempToRaw(attrReadFloat(chip.temp_attr));
    chip.byte_regs[REG_TEMP * 2] = @intCast((raw >> 4) & 0xFF); // MSB
    chip.byte_regs[REG_TEMP * 2 + 1] = @intCast((raw & 0x0F) << 4); // LSB
}

// ─── chip_init (exported as "chipInit" – called once by Wokwi at startup) ─────

export fn chipInit() void {
    const chip = &global_chip;
    chip.* = ChipState{};

    // Float attribute read from diagram.json; this is the canonical observable.
    chip.temp_attr = attrInit("temperature", 21.0);

    // ── Power-on register defaults ──────────────────────────────────────
    chip.byte_regs[REG_CONFIG * 2] = @intCast((RESET_CONFIG >> 8) & 0xFF);
    chip.byte_regs[REG_CONFIG * 2 + 1] = @intCast(RESET_CONFIG & 0xFF);
    chip.byte_regs[REG_TLOW * 2] = @intCast((RESET_TLOW >> 8) & 0xFF);
    chip.byte_regs[REG_TLOW * 2 + 1] = @intCast(RESET_TLOW & 0xFF);
    chip.byte_regs[REG_THIGH * 2] = @intCast((RESET_THIGH >> 8) & 0xFF);
    chip.byte_regs[REG_THIGH * 2 + 1] = @intCast(RESET_THIGH & 0xFF);
    updateTemperature(chip);

    // ── Address selection pin (ADD0): GND = 0x48, V+ = 0x49 ─────────────
    chip.add0 = pinInit("ADD0", @intFromEnum(PinMode.input_pulldown));
    chip.i2c_addr = if (pinRead(chip.add0) != 0) ADDR_VCC else ADDR_GND;

    // ── ALERT is open-drain; left floating (alarm features excluded). ──
    chip.alert = pinInit("ALERT", @intFromEnum(PinMode.input));

    // ── I²C – listen on the resolved hardware address ───────────────────
    chip.scl = pinInit("SCL", @intFromEnum(PinMode.input));
    chip.sda = pinInit("SDA", @intFromEnum(PinMode.input));
    const i2c_cfg = I2cConfig{
        .user_data = chip,
        .address = chip.i2c_addr,
        .scl = chip.scl,
        .sda = chip.sda,
        .connect = onI2cConnect,
        .read = onI2cRead,
        .write = onI2cWrite,
        .disconnect = onI2cDisconnect,
    };
    chip.i2c = i2cInit(&i2c_cfg);
}

// ─── I²C Callbacks ──────────────────────────────────────────────────────────────

fn onI2cConnect(user_data: ?*anyopaque, address: u32, read: bool) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    // Only acknowledged at our hardware address.
    if (address != chip.i2c_addr) return false; // NACK

    if (!read) {
        // A write transaction begins with the pointer byte.
        chip.has_reg_ptr = false;
    } else {
        // A read transaction resumes from the current pointer position.
        chip.read_pos = chip.reg_ptr;
        updateTemperature(chip);
    }
    return true; // ACK
}

fn onI2cRead(user_data: ?*anyopaque) callconv(.c) u8 {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    const val = chip.byte_regs[chip.read_pos & 0x07];
    chip.read_pos = (chip.read_pos +% 1) & 0x07;
    return val;
}

fn onI2cWrite(user_data: ?*anyopaque, byte: u8) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    if (!chip.has_reg_ptr) {
        // First byte after the address is the pointer (only P1:P0 used).
        chip.reg_ptr = (byte & 0x03) * 2;
        chip.read_pos = chip.reg_ptr;
        chip.has_reg_ptr = true;
    } else {
        chip.byte_regs[chip.reg_ptr & 0x07] = byte;
        chip.reg_ptr = (chip.reg_ptr +% 1) & 0x07;
    }
    return true; // ACK
}

fn onI2cDisconnect(user_data: ?*anyopaque) callconv(.c) void {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    chip.has_reg_ptr = false;
}
