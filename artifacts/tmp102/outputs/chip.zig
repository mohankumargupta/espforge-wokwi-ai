//! TMP102 — digital temperature sensor (I2C) — Wokwi custom chip, Zig 0.16.
//!
//! Implements the essentials required by the canonical test spec:
//! I2C slave at 0x48 returning the temperature observable (default 21.0 °C)
//! in the normal 12-bit register format. AL/THIGN logic, shutdown, one-shot,
//! extended mode, ADD0 straps and general-call reset are excluded by the
//! qa table and intentionally not emulated.
//!
//! Encoding/decoding of the register words is an explicit port of the
//! validated conversions in
//!   artifacts/tmp102/prompt0c/src/root.zig
//! (`conversions_manifest.md`) and MUST NOT be re-derived from the datasheet.
//!
//! The Wokwi ABI (extern imports, exported chipInit, I2C callbacks) is gated
//! behind `chip_mode = !builtin.is_test` so the same file compiles as a pure
//! unit-test module for the native host (`zig build test`).

const std = @import("std");
const builtin = @import("builtin");

const chip_mode = !builtin.is_test;

// ===========================================================================
// Canonical conversions (ported verbatim from prompt0c/src/root.zig)
// ===========================================================================

/// Conversion scale: 1 LSB = 0.0625 C.
const RESOLUTION: f32 = 0.0625;

// Register map addresses (pointer bytes).
const REG_TEMPERATURE: u8 = 0x00;
const REG_CONFIGURATION: u8 = 0x01;
const REG_LOW_LIMIT: u8 = 0x02;
const REG_HIGH_LIMIT: u8 = 0x03;
const REG_COUNT: u8 = 0x04;

/// Power-up / general-call-reset value of the Configuration register.
/// Byte 1 = 0x60 (R1,R0 = 11 -> 12-bit), Byte 2 = 0xA0 (CR1,CR0 = 10 -> 4 Hz,
/// AL = 1 -> alert not asserted, EM = 0 -> normal mode).
const CONFIG_RESET: u16 = 0x60A0;

/// Reset value of the TLOW and THIGH registers (count << 4 for +75 / +80 °C).
const TLOW_RESET: u16 = 0x4B00;
const THIGH_RESET: u16 = 0x5000;

/// Assemble a big-endian 16-bit register word from the two bytes read from
/// the bus, MSB-first.
fn bytesToWord(msb: u8, lsb: u8) u16 {
    return (@as(u16, msb) << 8) | @as(u16, lsb);
}

/// Split a 16-bit register word into the two big-endian bus bytes, MSB-first.
fn wordToBytes(reg: u16) [2]u8 {
    return .{ @truncate(@as(u32, reg) >> 8), @truncate(reg) };
}

/// Decode a normal-mode (12-bit) temperature register word to degrees C.
/// (Arithmetic shift so bit 15 sign-extends.)
fn decodeTempNormal(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 4)) * RESOLUTION;
}

/// Encode a temperature in degrees C to a normal-mode (12-bit) register word,
/// left-aligned at bits 15:4, rounded to the nearest 0.0625 C LSB. Clamps to
/// the 12-bit signed range [-128, 127.9375] C.
fn encodeTempNormal(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = std.math.clamp(raw, -2048, 2047);
    return @as(u16, @bitCast(@as(i16, @intCast(count)))) << 4;
}

// Configuration register (0x01) — write handling. Read-only fields:
// R1/R0 (bits 15:... 14,13) and AL (bit 5) must keep their stored value.
const CONFIG_READ_ONLY_MASK: u16 = 0x6020; // R1 + R0 + AL
const CONFIG_WRITABLE_MASK: u16 = 0x9FD0; // OS,F1,F0,POL,TM,SD,CR1,CR0,EM

/// Merge a written config word into the current one, preserving read-only bits
/// and forcing the reserved lower nibble to 0 (both starts 0 in the reset).
fn configMerge(current: u16, written: u16) u16 {
    return (current & CONFIG_READ_ONLY_MASK) | (written & CONFIG_WRITABLE_MASK);
}

// ===========================================================================
// Wokwi ABI primitives (only referenced in wasm builds)
// ===========================================================================

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

extern fn pinInit(name: [*:0]const u8, mode: u32) Pin;
extern fn attrInit(name: [*:0]const u8, default_value: f64) u32;
extern fn attrReadFloat(attr: u32) f64;
extern fn i2cInit(config: *const I2cConfig) I2cDev;

const I2C_ADDRESS: u8 = 0x48; // ADD0 = GND, the only address under test.

// ===========================================================================
// Chip state
// ===========================================================================

const ChipState = struct {
    i2c: I2cDev = 0,
    scl: Pin = 0,
    sda: Pin = 0,
    temperature_attr: u32 = 0,

    // Data register file (temperatures read-only), power-up defaults.
    regs: [REG_COUNT]u16 = .{ 0x0000, CONFIG_RESET, TLOW_RESET, THIGH_RESET },

    // Pointer register selection (P1:P0) remembered until next write.
    pointer: u8 = 0,
    has_pointer: bool = false,

    // Read-transaction byte index into the selected 16-bit register.
    read_index: u8 = 0,

    // Partial-write accumulator for 16-bit register writes (MSB then LSB).
    write_reg: u8 = 0,
    write_byte: u8 = 0,
    write_pending: bool = false,
};

var chip: ChipState = .{};

fn apiVersion() callconv(.c) u32 {
    return 1;
}

fn chipInit() callconv(.c) void {
    chip = .{};

    chip.scl = pinInit("SCL", @intFromEnum(PinMode.input));
    chip.sda = pinInit("SDA", @intFromEnum(PinMode.input));

    chip.temperature_attr = attrInit("temperature", 21.0);

    const cfg = I2cConfig{
        .user_data = &chip,
        .address = I2C_ADDRESS,
        .scl = chip.scl,
        .sda = chip.sda,
        .connect = onI2cConnect,
        .read = onI2cRead,
        .write = onI2cWrite,
        .disconnect = onI2cDisconnect,
    };
    chip.i2c = i2cInit(&cfg);
}

comptime {
    if (chip_mode) {
        @export(&chipInit, .{ .name = "chipInit" });
        @export(&apiVersion, .{ .name = "__wokwi_api_version_1" });
    }
}

// ===========================================================================
// Register access
// ===========================================================================

/// Live temperature in C, read fresh from the diagram control attribute.
fn currentTemperature() f32 {
    return @floatCast(attrReadFloat(chip.temperature_attr));
}

/// Register word addressed by the current pointer. Temperature is always
/// encoded live in normal (12-bit) mode from the current control value.
fn readRegisterWord(self: *ChipState) u16 {
    return switch (self.pointer) {
        REG_TEMPERATURE => blk: {
            const t = currentTemperature();
            break :blk encodeTempNormal(t);
        },
        REG_CONFIGURATION => self.regs[REG_CONFIGURATION],
        REG_LOW_LIMIT => self.regs[REG_LOW_LIMIT],
        REG_HIGH_LIMIT => self.regs[REG_HIGH_LIMIT],
        else => 0,
    };
}

/// Accept a data byte for the register currently selected by the pointer.
/// 16-bit registers need two bytes (MSB then LSB); temperature is read-only.
fn writeRegisterByte(self: *ChipState, byte: u8) void {
    if (self.pointer == REG_TEMPERATURE) return;

    if (!self.write_pending) {
        self.write_pending = true;
        self.write_reg = self.pointer;
        self.write_byte = byte;
        return;
    }
    if (self.write_reg != self.pointer) {
        self.write_pending = false;
        return;
    }
    const word: u16 = bytesToWord(self.write_byte, byte);
    switch (self.pointer) {
        REG_CONFIGURATION => self.regs[REG_CONFIGURATION] = configMerge(self.regs[REG_CONFIGURATION], word),
        REG_LOW_LIMIT => self.regs[REG_LOW_LIMIT] = word,
        REG_HIGH_LIMIT => self.regs[REG_HIGH_LIMIT] = word,
        else => {},
    }
    self.write_pending = false;
}

// ===========================================================================
// I2C callbacks
// ===========================================================================

fn onI2cConnect(user_data: ?*anyopaque, address: u32, read: bool) callconv(.c) bool {
    const self: *ChipState = @ptrCast(@alignCast(user_data));
    if (address != I2C_ADDRESS) return false; // NACK — only answer our address.

    self.read_index = 0;
    if (!read) {
        // A fresh write transaction: next byte is the pointer register.
        self.has_pointer = false;
        self.write_pending = false;
    }
    return true; // ACK
}

fn onI2cRead(user_data: ?*anyopaque) callconv(.c) u8 {
    const self: *ChipState = @ptrCast(@alignCast(user_data));
    const bytes = wordToBytes(readRegisterWord(self));
    const idx = self.read_index;
    if (idx < 2) self.read_index += 1;
    return switch (idx) {
        0 => bytes[0],
        1 => bytes[1],
        else => 0,
    };
}

fn onI2cWrite(user_data: ?*anyopaque, byte: u8) callconv(.c) bool {
    const self: *ChipState = @ptrCast(@alignCast(user_data));
    if (!self.has_pointer) {
        self.pointer = byte & 0x03;
        self.has_pointer = true;
        self.write_pending = false;
    } else {
        writeRegisterByte(self, byte);
    }
    return true; // ACK
}

fn onI2cDisconnect(user_data: ?*anyopaque) callconv(.c) void {
    const self: *ChipState = @ptrCast(@alignCast(user_data));
    self.has_pointer = false;
    self.write_pending = false;
}

// ===========================================================================
// Unit tests — exact register words vs canonical conversions
// ===========================================================================

test "temperature default observable 21.0 C encodes to 0x1500" {
    // 21.0 / 0.0625 = 336 counts (0x150), left-aligned to 0x1500.
    try std.testing.expectEqual(@as(u16, 0x1500), encodeTempNormal(21.0));
    try std.testing.expectApproxEqAbs(21.0, decodeTempNormal(0x1500), 0.0001);
    // Bytes appear on the bus MSB-first.
    try std.testing.expectEqual([2]u8{ 0x15, 0x00 }, wordToBytes(encodeTempNormal(21.0)));
}

test "spec worked examples round-trip in normal mode" {
    const values = [_]struct { c: f32, word: u16 }{
        .{ .c = 127.9375, .word = 0x7FF0 },
        .{ .c = 100.0, .word = 0x6400 },
        .{ .c = 80.0, .word = 0x5000 },
        .{ .c = 75.0, .word = 0x4B00 },
        .{ .c = 25.0, .word = 0x1900 },
        .{ .c = 0.25, .word = 0x0040 },
        .{ .c = 0.0, .word = 0x0000 },
        .{ .c = -0.25, .word = 0xFFC0 },
        .{ .c = -25.0, .word = 0xE700 },
        .{ .c = -55.0, .word = 0xC900 },
    };
    for (values) |v| {
        try std.testing.expectApproxEqAbs(v.c, decodeTempNormal(v.word), 0.0001);
        try std.testing.expectEqual(v.word, encodeTempNormal(v.c));
    }
}

test "normal mode clamps to the 12-bit signed range" {
    try std.testing.expectEqual(@as(u16, 0x7FF0), encodeTempNormal(128.0));
    try std.testing.expectEqual(@as(u16, 0x8000), encodeTempNormal(-128.1));
}

test "byte-order helpers assemble big-endian words" {
    try std.testing.expectEqual(@as(u16, 0x6400), bytesToWord(0x64, 0x00));
    try std.testing.expectEqual([2]u8{ 0x60, 0xA0 }, wordToBytes(CONFIG_RESET));
}

test "power-up register defaults" {
    try std.testing.expectEqual(@as(u16, 0x60A0), CONFIG_RESET);
    try std.testing.expectEqual(@as(u16, 0x4B00), TLOW_RESET); // +75 C
    try std.testing.expectEqual(@as(u16, 0x5000), THIGH_RESET); // +80 C
    try std.testing.expectEqual(@as(u16, 0x0000), encodeTempNormal(0.0));
}

test "config write preserves read-only fields and reserved bits" {
    // Writing all-zero clears only writable fields; R1/R0 (bits 14,13) and
    // AL (bit 5) keep their reset values and the reserved nibble stays zero.
    try std.testing.expectEqual(@as(u16, 0x6020), configMerge(CONFIG_RESET, 0x0000));
    // Writing back the default writable fields (CR1:CR0 = 10) rebuilds 0x60A0.
    try std.testing.expectEqual(@as(u16, 0x60A0), configMerge(CONFIG_RESET, 0x00A0));
    // Writing the one-shot bit (OS, bit 15) is honoured next to preserved bits.
    try std.testing.expectEqual(@as(u16, 0xE020), configMerge(CONFIG_RESET, 0x8000));
    // Setting every bit leaves the read-only and reserved fields clear.
    try std.testing.expectEqual(@as(u16, 0x9FD0), configMerge(0x0000, 0xFFFF));
}
