//! APDS9960 – Gesture / Proximity / Ambient Light (RGBC) sensor, I2C.
//! Wokwi Custom Chip · Zig 0.16 (wasm32-freestanding, no_std)
//!
//! Implements the essentials needed by the canonical test spec
//! (test_spec_apds9960.md): the ID check, the register shadow file with
//! power-on reset values, STATUS AVALID/PVALID reporting, and the five
//! observable data registers (CDATA/RDATA/GDATA/BDATA Little-Endian pairs,
//! PDATA) driven by live percent attributes.
//!
//! Register bit layout / percent encoding is ported VERBATIM from
//! artifacts/apds9960/prompt0c/src/main.zig (data-conversions-complex-logic,
//! the single source of truth — see conversions_manifest.md).

const std = @import("std");
const builtin = @import("builtin");

// true in the wasm chip build, false in the host `zig build test` build.
const chip_mode = !builtin.is_test;

// ─── Wokwi API types (mirrors assets/wokwi_api.zig / wokwi-api.h) ────────────

const Pin = i32;
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

const PinValue = enum(u32) {
    low = 0,
    high = 1,
};

const Edge = enum(u32) {
    rising = 1,
    falling = 2,
    both = 3,
};

/// Passed to pinWatch; must stay alive (heap or global) for the simulation.
const PinWatchConfig = extern struct {
    user_data: ?*anyopaque,
    edge: u32,
    pin_change: *const fn (?*anyopaque, Pin, u32) callconv(.c) void,
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
    reserved: [8]u32,
};

// ─── Wokwi Host-Function Imports (become WASM imports from "env") ─────────────

extern fn pinInit(name: [*:0]const u8, mode: u32) Pin;
extern fn pinMode(pin: Pin, mode: u32) void;
extern fn pinRead(pin: Pin) u32;
extern fn pinWatch(pin: Pin, config: *const PinWatchConfig) bool;
extern fn attrInit(name: [*:0]const u8, default_value: f64) u32;
extern fn attrReadFloat(attr_id: u32) f64;
extern fn i2cInit(config: *const I2cConfig) I2cDev;

// ─── Canonical conversions (PORTED from prompt0c/src/main.zig) ───────────────

// One ALS/color integration step (and one wait-time step), 2.78 ms per spec.
const LSB_STEP_MS: f32 = 2.78;
// Fixed proximity ADC conversion time in the tPROX formula (tCNVT = 796.6 us).
const T_CNVT_US: f32 = 796.6;
const RGBC_FULL_SCALE: u16 = 65535;
const PROX_FULL_SCALE: u16 = 255;

/// Assemble a Little-Endian RGBC 16-bit count from its two register bytes.
pub fn rgbcFromBytes(low: u8, high: u8) u16 {
    return (@as(u16, high) << 8) | low;
}

pub const RgbcBytes = struct {
    low: u8,
    high: u8,
};

/// Split a Little-Endian RGBC 16-bit count into its two register bytes.
pub fn rgbcToBytes(count: u16) RgbcBytes {
    return .{ .low = @truncate(count), .high = @truncate(count >> 8) };
}

/// RGBC count (0..65535) -> percentage of full scale (value / 65535 * 100).
pub fn rgbcPercentFromCount(count: u16) f32 {
    return @as(f32, @floatFromInt(count)) / @as(f32, RGBC_FULL_SCALE) * 100.0;
}

/// Proximity count (0..255) -> percentage of full scale (value / 255 * 100).
pub fn proxPercentFromCount(count: u8) f32 {
    return @as(f32, @floatFromInt(count)) / @as(f32, PROX_FULL_SCALE) * 100.0;
}

/// ENCODE: percentage (0..100) -> RGBC 16-bit count. Inverse of
/// `rgbcPercentFromCount` (rounded to nearest count). Clamps/saturates
/// out-of-range; NaN clamps to 0.
pub fn rgbcCountFromPercent(pct: f32) u16 {
    const clamped = if (std.math.isNan(pct)) 0.0 else std.math.clamp(pct, 0.0, 100.0);
    return @intFromFloat(std.math.round(clamped * 655.35));
}

/// ENCODE: percentage (0..100) -> proximity 8-bit count. Inverse of
/// `proxPercentFromCount` (rounded to nearest count). Clamps/saturates
/// out-of-range; NaN clamps to 0.
pub fn proxCountFromPercent(pct: f32) u8 {
    const clamped = if (std.math.isNan(pct)) 0.0 else std.math.clamp(pct, 0.0, 100.0);
    return @intFromFloat(std.math.round(clamped * 2.55));
}

/// ATIME register -> ALS/color integration cycles (1..256). CYCLES = 256 - ATIME.
pub fn atimeToCycles(atime: u8) u16 {
    return @as(u16, 256) - atime;
}

/// ATIME register -> ALS/color integration time in ms (CYCLES * 2.78 ms).
pub fn atimeToIntegrationMs(atime: u8) f32 {
    return @as(f32, @floatFromInt(atimeToCycles(atime))) * LSB_STEP_MS;
}

/// ATIME register -> full-scale count (max raw count before saturation).
/// CountMAX = min(1024 * CYCLES + 1, 65535) — the spec's own worked examples
/// (0xF6 -> 10241, 0xDB -> 37889) are authoritative over the inline
/// "min(1025 x CYCLES, 65535)" text.
pub fn atimeToFullScale(atime: u8) u16 {
    const cycles: u32 = atimeToCycles(atime);
    const max_count: u32 = @min(1024 * cycles + 1, @as(u32, RGBC_FULL_SCALE));
    return @intCast(max_count);
}

/// WTIME register -> wait steps (1..256). WAIT_STEPS = 256 - WTIME.
pub fn wtimeToSteps(wtime: u8) u16 {
    return @as(u16, 256) - wtime;
}

/// WTIME register (and CONFIG1 WLONG flag) -> wait time in ms.
pub fn wtimeToWaitMs(wtime: u8, wlong: bool) f32 {
    const steps: f32 = @as(f32, @floatFromInt(wtimeToSteps(wtime)));
    const base = steps * LSB_STEP_MS;
    return if (wlong) base * 12.0 else base;
}

/// Decode a sign/magnitude offset register byte (POFFSET_UR/DL, GOFFSET_*)
/// to a signed offset. bit 7 = sign (1 = negative), bits 6:0 = magnitude.
pub fn offsetFromByte(reg: u8) i8 {
    const mag: i8 = @intCast(reg & 0x7F);
    return if ((reg & 0x80) != 0) -mag else mag;
}

/// ENCODE: signed offset -> sign/magnitude offset register byte.
/// Clamps to [-127, +127]; 0 encodes as 0x00.
pub fn offsetToByte(offset: i32) u8 {
    const clamped = std.math.clamp(offset, -127, 127);
    const mag: u8 = @intCast(@abs(clamped));
    return if (clamped < 0) mag | 0x80 else mag;
}

/// PPULSE register field (bits 5:0) -> actual number of proximity/gesture
/// LED pulses. pulses = PPULSE + 1 (range 1..64).
pub fn pulseCount(ppulse_field: u6) u8 {
    return @as(u8, ppulse_field) + 1;
}

/// PPLEN/GPLEN field (bits 7:6) -> LED pulse length in us. 0=4, 1=8, 2=16, 3=32.
pub fn pulseLengthUs(pplen_field: u2) u16 {
    return switch (pplen_field) {
        0 => 4,
        1 => 8,
        2 => 16,
        3 => 32,
    };
}

/// Proximity result time in ms. tPROX = (tINIT + tCNVT + pulses * tACC) / 1000.
pub fn proximityResultTimeMs(pulses: u8, t_init_us: u16, t_acc_us: u16) f32 {
    const total_us = @as(f32, @floatFromInt(t_init_us)) + T_CNVT_US +
        @as(f32, @floatFromInt(pulses)) * @as(f32, @floatFromInt(t_acc_us));
    return total_us / 1000.0;
}

// ─── Register Map (power-on defaults per spec_apds9960.md) ───────────────────

const R = struct {
    const enable: u8 = 0x80; // reset 0x00
    const atime: u8 = 0x81; // reset 0xFF
    const wtime: u8 = 0x83; // reset 0xFF
    const ailtl: u8 = 0x84;
    const ailth: u8 = 0x85;
    const aihtl: u8 = 0x86; // reset 0x00
    const aihth: u8 = 0x87; // reset 0x00
    const pilt: u8 = 0x89; // reset 0x00
    const piht: u8 = 0x8B; // reset 0x00
    const pers: u8 = 0x8C; // reset 0x00
    const config1: u8 = 0x8D; // reset 0x40
    const ppulse: u8 = 0x8E; // reset 0x40
    const control: u8 = 0x8F; // reset 0x00
    const config2: u8 = 0x90; // reset 0x01
    const id: u8 = 0x92; // fixed 0xAB (read-only)
    const status: u8 = 0x93; // computed (read-only)
    const cdata: u8 = 0x94; // 0x94/0x95 (read-only)
    const rdata: u8 = 0x96; // 0x96/0x97 (read-only)
    const gdata: u8 = 0x98; // 0x98/0x99 (read-only)
    const bdata: u8 = 0x9A; // 0x9A/0x9B (read-only)
    const pdata: u8 = 0x9C; // read-only
    const poffset_ur: u8 = 0x9D; // reset 0x00
    const poffset_dl: u8 = 0x9E; // reset 0x00
    const config3: u8 = 0x9F; // reset 0x00
    const gpentha: u8 = 0xA0; // reset 0x00
    const gexth: u8 = 0xA1; // reset 0x00
    const gconf1: u8 = 0xA2; // reset 0x00
    const gconf2: u8 = 0xA3; // reset 0x00
    const goffset_u: u8 = 0xA4; // reset 0x00
    const goffset_d: u8 = 0xA5; // reset 0x00
    const gpulse: u8 = 0xA6; // reset 0x40
    const goffset_l: u8 = 0xA7; // reset 0x00
    const goffset_r: u8 = 0xA9; // reset 0x00
    const gconf3: u8 = 0xAA; // reset 0x00
    const gconf4: u8 = 0xAB; // reset 0x00
    const gflvl: u8 = 0xAE; // reset 0x00 (read-only)
    const gstatus: u8 = 0xAF; // reset 0x00 (read-only)
    const gfifo: u8 = 0xFC; // 0xFC-0xFF gesture FIFO (read-only)
};

/// Factory-fixed 7-bit I2C address (spec_apds9960.md: single address, no strap
/// pin). Fixed wiring parameter — NOT an overridable attribute.
const I2C_ADDR: u32 = 0x39;

const CHIP_PINS = struct {
    const sda: [*:0]const u8 = "SDA";
    const scl: [*:0]const u8 = "SCL";
    const int: [*:0]const u8 = "INT";
};

// ─── Chip State ───────────────────────────────────────────────────────────────

const ChipState = struct {
    i2c: I2cDev = 0,

    // Full 256-byte register file indexed by register address. Registers
    // 0x00-0x7F are general-purpose RAM (reset 0x00); 0x80+ control/data.
    regs: [256]u8 = [_]u8{0} ** 256,

    // I2C sequential-access pointer
    reg_ptr: u8 = 0,
    has_reg_ptr: bool = false,

    // Pin handles
    sda_pin: Pin = 0,
    scl_pin: Pin = 0,
    int_pin: Pin = 0,

    // Attribute ids for the live observable percent controls
    attr_clear: u32 = 0,
    attr_red: u32 = 0,
    attr_green: u32 = 0,
    attr_blue: u32 = 0,
    attr_proximity: u32 = 0,
};

// Global static state instead of dynamic allocation
var global_chip: ChipState = undefined;

// ─── chip_init (exported as "chipInit" – called once by Wokwi at startup) ────

comptime {
    if (chip_mode) {
        @export(&chipInit, .{ .name = "chipInit" });
    }
}

fn chipInit() callconv(.c) void {
    const chip = &global_chip;
    chip.* = ChipState{};

    resetRegisters(chip);

    // ── Live observable percent controls (environmental inputs) ─────────
    // Defaults match the canonical observable defaults (test_spec_apds9960.md);
    // attrReadFloat re-reads on every data-register access so a user moving a
    // chip.json slider while the simulation runs is seen on the next read.
    chip.attr_clear = attrInit("clear", 20.0);
    chip.attr_red = attrInit("red", 15.0);
    chip.attr_green = attrInit("green", 12.0);
    chip.attr_blue = attrInit("blue", 9.0);
    chip.attr_proximity = attrInit("proximity", 7.1);

    // ── INT pin: open-drain, active-low; released (input) at reset ──────
    chip.int_pin = pinInit(CHIP_PINS.int, @intFromEnum(PinMode.input));

    // ── I2C at the fixed factory address 0x39 ────────────────────────────
    const i2c_cfg = I2cConfig{
        .user_data = chip,
        .address = I2C_ADDR,
        .scl = pinInit(CHIP_PINS.scl, @intFromEnum(PinMode.input)),
        .sda = pinInit(CHIP_PINS.sda, @intFromEnum(PinMode.input)),
        .connect = onI2cConnect,
        .read = onI2cRead,
        .write = onI2cWrite,
        .disconnect = onI2cDisconnect,
        .reserved = [_]u32{0} ** 8,
    };
    chip.i2c = i2cInit(&i2c_cfg);
}

/// Apply power-on reset register values (spec_apds9960.md register map).
fn resetRegisters(chip: *ChipState) void {
    chip.regs = [_]u8{0} ** 256;
    chip.regs[R.atime] = 0xFF;
    chip.regs[R.wtime] = 0xFF;
    chip.regs[R.config1] = 0x40;
    chip.regs[R.ppulse] = 0x40;
    chip.regs[R.config2] = 0x01;
    chip.regs[R.gpulse] = 0x40;
}

// ─── Live observable reads ───────────────────────────────────────────────────
// attrReadFloat is called per data-register access so that moving a chip.json
// slider while the simulation runs takes effect on the next read.

fn clearPct(chip: *ChipState) f32 {
    return @floatCast(attrReadFloat(chip.attr_clear));
}
fn redPct(chip: *ChipState) f32 {
    return @floatCast(attrReadFloat(chip.attr_red));
}
fn greenPct(chip: *ChipState) f32 {
    return @floatCast(attrReadFloat(chip.attr_green));
}
fn bluePct(chip: *ChipState) f32 {
    return @floatCast(attrReadFloat(chip.attr_blue));
}
fn proxPct(chip: *ChipState) f32 {
    return @floatCast(attrReadFloat(chip.attr_proximity));
}

// ─── Register Read / Write ───────────────────────────────────────────────────

/// STATUS is computed on every read: AVALID (bit 0) set while the ALS/color
/// engine is enabled, PVALID (bit 1) set while the proximity engine is
/// enabled. Data is always considered "ready" — the conversion completes the
/// moment the engine is enabled (ideal_conditions per test spec).
fn computeStatus(chip: *ChipState) u8 {
    const en = chip.regs[R.enable];
    var s: u8 = 0;
    if (en & 0x02 != 0) s |= 0x01; // AVALID
    if (en & 0x04 != 0) s |= 0x02; // PVALID
    return s;
}

/// RGBC data byte for a register address in 0x94..0x9B.
/// Channel order is C, R, G, B; each channel is a Little-Endian low/high pair.
fn rgbcByte(chip: *ChipState, reg: u8) u8 {
    const idx = reg - R.cdata; // 0..7
    const channel = idx / 2; // 0=C, 1=R, 2=G, 3=B
    const high_byte = idx % 2 == 1;

    const pct: f32 = switch (channel) {
        0 => clearPct(chip),
        1 => redPct(chip),
        2 => greenPct(chip),
        else => bluePct(chip),
    };
    const bytes = rgbcToBytes(rgbcCountFromPercent(pct));
    return if (high_byte) bytes.high else bytes.low;
}

fn readReg(chip: *ChipState, reg: u8) u8 {
    return switch (reg) {
        R.id => 0xAB, // APDS-9960 device ID
        R.status => computeStatus(chip),
        R.cdata, R.rdata, R.gdata, R.bdata => rgbcByte(chip, reg),
        R.pdata => proxCountFromPercent(proxPct(chip)),
        else => chip.regs[reg],
    };
}

fn writeReg(chip: *ChipState, reg: u8, val: u8) void {
    switch (reg) {
        // Read-only registers: data registers, ID, STATUS, gesture status/FIFO.
        R.id, R.status, R.cdata, R.rdata, R.gdata, R.bdata, R.pdata, R.gflvl, R.gstatus, R.gfifo, R.gfifo + 1, R.gfifo + 2, R.gfifo + 3 => {},
        else => chip.regs[reg] = val,
    }
}

// ─── I2C Callbacks ────────────────────────────────────────────────────────────

fn onI2cConnect(user_data: ?*anyopaque, address: u32, read: bool) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    // Filter: only accept our fixed factory address
    if (address != I2C_ADDR) return false; // NACK

    if (!read) {
        chip.has_reg_ptr = false;
    }
    return true; // ACK
}

fn onI2cRead(user_data: ?*anyopaque) callconv(.c) u8 {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    const val = readReg(chip, chip.reg_ptr);

    // Sequential access: advance the pointer after every byte, so block reads
    // such as ESPHome's read_bytes(0x94, raw, 8) stream across the RGBC pairs.
    chip.reg_ptr +%= 1;

    return val;
}

fn onI2cWrite(user_data: ?*anyopaque, byte: u8) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    if (!chip.has_reg_ptr) {
        chip.reg_ptr = byte;
        chip.has_reg_ptr = true;
    } else {
        writeReg(chip, chip.reg_ptr, byte);
        chip.reg_ptr +%= 1;
    }
    return true; // ACK
}

fn onI2cDisconnect(user_data: ?*anyopaque) callconv(.c) void {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    chip.has_reg_ptr = false;
}

// ─── Tests (host `zig build test` only; not built into the wasm chip) ────────
//
// These assert the exact encoded register bytes for every canonical observable
// default (test_spec_apds9960.md) against the values recorded in
// conversions_manifest.md. They run on the native host via build.zig's test
// step; the wasm chip build never includes them (chip_mode gates the ABI).

test "rgbc byte pair assembly (Little-Endian)" {
    try std.testing.expectEqual(@as(u16, 0x3333), rgbcFromBytes(0x33, 0x33));
    try std.testing.expectEqual(@as(u16, 0x2666), rgbcFromBytes(0x66, 0x26));
    try std.testing.expectEqual(@as(u16, 0x1EB8), rgbcFromBytes(0xB8, 0x1E));
    try std.testing.expectEqual(@as(u16, 0x170A), rgbcFromBytes(0x0A, 0x17));
    try std.testing.expectEqual(@as(u16, 0x0001), rgbcFromBytes(0x01, 0x00));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x33, .high = 0x33 }, rgbcToBytes(0x3333));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x66, .high = 0x26 }, rgbcToBytes(0x2666));
    try std.testing.expectEqual(RgbcBytes{ .low = 0xB8, .high = 0x1E }, rgbcToBytes(0x1EB8));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x0A, .high = 0x17 }, rgbcToBytes(0x170A));
}

test "canonical defaults -> exact register bytes (test_spec_apds9960.md)" {
    // clear 20.0% -> CDATAL=0x33, CDATAH=0x33 (0x3333 = 13107)
    try std.testing.expectEqual(@as(u16, 0x3333), rgbcCountFromPercent(20.0));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x33, .high = 0x33 }, rgbcToBytes(rgbcCountFromPercent(20.0)));
    // red 15.0% -> RDATAL=0x66, RDATAH=0x26 (0x2666 = 9830)
    try std.testing.expectEqual(@as(u16, 0x2666), rgbcCountFromPercent(15.0));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x66, .high = 0x26 }, rgbcToBytes(rgbcCountFromPercent(15.0)));
    // green 12.0% -> GDATAL=0xB8, GDATAH=0x1E (0x1EB8 = 7864)
    try std.testing.expectEqual(@as(u16, 0x1EB8), rgbcCountFromPercent(12.0));
    try std.testing.expectEqual(RgbcBytes{ .low = 0xB8, .high = 0x1E }, rgbcToBytes(rgbcCountFromPercent(12.0)));
    // blue 9.0% -> BDATAL=0x0A, BDATAH=0x17 (0x170A = 5898)
    try std.testing.expectEqual(@as(u16, 0x170A), rgbcCountFromPercent(9.0));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x0A, .high = 0x17 }, rgbcToBytes(rgbcCountFromPercent(9.0)));
    // proximity 7.1% -> PDATA=0x12 (18)
    try std.testing.expectEqual(@as(u8, 18), proxCountFromPercent(7.1));
}

test "percent decode (canonical defaults -> %)" {
    try std.testing.expectApproxEqAbs(20.0, rgbcPercentFromCount(13107), 0.001);
    try std.testing.expectApproxEqAbs(15.0, rgbcPercentFromCount(9830), 0.001);
    try std.testing.expectApproxEqAbs(12.0, rgbcPercentFromCount(7864), 0.001);
    try std.testing.expectApproxEqAbs(9.0, rgbcPercentFromCount(5898), 0.001);
    try std.testing.expectApproxEqAbs(7.1, proxPercentFromCount(18), 0.05);
    try std.testing.expectApproxEqAbs(0.0, rgbcPercentFromCount(0), 0.001);
    try std.testing.expectApproxEqAbs(100.0, rgbcPercentFromCount(65535), 0.001);
    try std.testing.expectApproxEqAbs(100.0, proxPercentFromCount(255), 0.001);
}

test "percent encode out-of-range clamps" {
    try std.testing.expectEqual(@as(u16, 0x0000), rgbcCountFromPercent(-5.0));
    try std.testing.expectEqual(@as(u16, 0xFFFF), rgbcCountFromPercent(150.0));
    try std.testing.expectEqual(@as(u16, 0x0000), rgbcCountFromPercent(std.math.nan(f32)));
    try std.testing.expectEqual(@as(u8, 0x00), proxCountFromPercent(-5.0));
    try std.testing.expectEqual(@as(u8, 0xFF), proxCountFromPercent(150.0));
    try std.testing.expectEqual(@as(u8, 0x00), proxCountFromPercent(std.math.nan(f32)));
}

test "ATIME worked examples (cycles / ms / full-scale)" {
    try std.testing.expectEqual(@as(u16, 1), atimeToCycles(0xFF));
    try std.testing.expectEqual(@as(u16, 10), atimeToCycles(0xF6));
    try std.testing.expectEqual(@as(u16, 37), atimeToCycles(0xDB));
    try std.testing.expectEqual(@as(u16, 256), atimeToCycles(0x00));

    try std.testing.expectApproxEqAbs(2.78, atimeToIntegrationMs(0xFF), 0.001);
    try std.testing.expectApproxEqAbs(27.8, atimeToIntegrationMs(0xF6), 0.001);
    try std.testing.expectApproxEqAbs(103.0, atimeToIntegrationMs(0xDB), 0.5);
    try std.testing.expectApproxEqAbs(712.0, atimeToIntegrationMs(0x00), 0.5);

    try std.testing.expectEqual(@as(u16, 1025), atimeToFullScale(0xFF));
    try std.testing.expectEqual(@as(u16, 10241), atimeToFullScale(0xF6));
    try std.testing.expectEqual(@as(u16, 37889), atimeToFullScale(0xDB));
    try std.testing.expectEqual(@as(u16, 65535), atimeToFullScale(0x00));
}

test "WTIME worked examples" {
    try std.testing.expectEqual(@as(u16, 1), wtimeToSteps(0xFF));
    try std.testing.expectEqual(@as(u16, 256), wtimeToSteps(0x00));

    try std.testing.expectApproxEqAbs(2.78, wtimeToWaitMs(0xFF, false), 0.001);
    try std.testing.expectApproxEqAbs(712.0, wtimeToWaitMs(0x00, false), 0.5);
    try std.testing.expectApproxEqAbs(8540.16, wtimeToWaitMs(0x00, true), 0.01);
}

test "offset sign/magnitude decode" {
    try std.testing.expectEqual(@as(i8, 127), offsetFromByte(0x7F));
    try std.testing.expectEqual(@as(i8, -1), offsetFromByte(0x81));
    try std.testing.expectEqual(@as(i8, -127), offsetFromByte(0xFF));
    try std.testing.expectEqual(@as(i8, 0), offsetFromByte(0x00));
    try std.testing.expectEqual(@as(i8, 0), offsetFromByte(0x80));
}

test "offset sign/magnitude encode + clamps" {
    try std.testing.expectEqual(@as(u8, 0x7F), offsetToByte(127));
    try std.testing.expectEqual(@as(u8, 0x81), offsetToByte(-1));
    try std.testing.expectEqual(@as(u8, 0xFF), offsetToByte(-127));
    try std.testing.expectEqual(@as(u8, 0x00), offsetToByte(0));
    try std.testing.expectEqual(@as(u8, 0x41), offsetToByte(65));
    try std.testing.expectEqual(@as(u8, 0x7F), offsetToByte(128));
    try std.testing.expectEqual(@as(u8, 0xFF), offsetToByte(-128));
}

test "pulse count and length decodes" {
    try std.testing.expectEqual(@as(u8, 8), pulseCount(0x07));
    try std.testing.expectEqual(@as(u8, 1), pulseCount(0x00));
    try std.testing.expectEqual(@as(u8, 64), pulseCount(0x3F));
    try std.testing.expectEqual(@as(u16, 4), pulseLengthUs(0));
    try std.testing.expectEqual(@as(u16, 8), pulseLengthUs(1));
    try std.testing.expectEqual(@as(u16, 16), pulseLengthUs(2));
    try std.testing.expectEqual(@as(u16, 32), pulseLengthUs(3));
}

test "proximity result time formula" {
    try std.testing.expectApproxEqAbs(0.7966, proximityResultTimeMs(8, 0, 0), 0.0001);
    try std.testing.expectApproxEqAbs(0.8646, proximityResultTimeMs(8, 4, 8), 0.0001);
}
