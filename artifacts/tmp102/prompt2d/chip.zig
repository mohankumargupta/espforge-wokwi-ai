//! TMP102 – Digital Temperature Sensor with I2C Interface
//! Wokwi Custom Chip · Zig 0.16 (no_std / WASM)
//!
//! Datasheet: TI SBOS397 (TMP102). SPDX-License-Identifier: MIT
//!
//! Scope: implement the essentials required by the canonical test spec
//! (`test_spec_tmp102.md`): I2C slave at 0x48 that reports the temperature via
//! the 0x00 Temperature Register (big-endian, MSB-first, 12-bit signed value
//! left-aligned at bits 15:4). The live temperature value comes from the
//! `temperature` diagram control (default 21.0 °C). TLOW/THIGH and the
//! Configuration register hold their reset defaults; extended mode, alert,
//! one-shot, shutdown, fault queue and general-call reset are intentionally
//! out of scope (see test spec "Excluded Features").
//!
//! The register-encoding/decoding helpers here are ported VERBATIM from the
//! canonical conversions module `artifacts/tmp102/prompt0c/src/root.zig`
//! (registered as the single source of truth in
//! `artifacts/tmp102/prompt0c/conversions_manifest.md`). They are NOT re-derived
//! from text: the datasheet's register-map and bit-field tables were previously
//! found to disagree (see feedback/tmp102/prompt0c.md).

const std = @import("std");
const builtin = @import("builtin");

/// Build-time flag: when compiling the host unit-test target `builtin.is_test`
/// is true and the raw Wokwi ABI (extern imports + exported chipInit) is left
/// out so the conversion functions can be unit tested on the host; when the
/// business of emitting the WASM chip binary there's false and the chip is
/// compiled as usual. This lets `chip.zig` carry BOTH the chip implementation
/// AND its unit tests in one file.
const chip_mode = !builtin.is_test;

// ─── Wokwi ABI (only pulled in for the WASM chip build) ──────────────────────

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

const PinWatchConfig = extern struct {
    user_data: ?*anyopaque,
    edge: u32,
    pin_change: *const fn (?*anyopaque, Pin, u32) callconv(.c) void,
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
    reserved: [8]u32,
};

// Host-function imports (become WASM imports from "env"). Declared at container
// scope: declarations emit no code by themselves, and everything that calls them
// is reachable only from the exported chipInit, which is itself only compiled
// when `chip_mode` is true.
extern fn pinInit(name: [*:0]const u8, mode: u32) Pin;
extern fn attrInit(name: [*:0]const u8, default_value: f64) u32;
extern fn attrReadFloat(attr: u32) f64;
extern fn i2cInit(config: *const I2cConfig) I2cDev;

// ─── Register map (portable to both build modes) ──────────────────────────────

pub const REG_TEMPERATURE: u8 = 0x00;
pub const REG_CONFIGURATION: u8 = 0x01;
pub const REG_LOW_LIMIT: u8 = 0x02;
pub const REG_HIGH_LIMIT: u8 = 0x03;
pub const REG_COUNT: u8 = 4;

/// Power-up / General-Call reset defaults.
pub const CONFIG_RESET: u16 = 0x6080; // byte1 0x60, byte2 0x80 (CR=4 Hz)
pub const TLOW_RESET: u16 = 0x4B00; // 75 °C
pub const THIGH_RESET: u16 = 0x5000; // 80 °C

pub const I2C_ADDRESS: u32 = 0x48; // ADD0 = GND (default strap)

/// Conversion scale: 1 LSB = 0.0625 C.
pub const RESOLUTION: f32 = 0.0625;

/// Canonical default ambient temperature from the test spec.
pub const DEFAULT_TEMP_C: f32 = 21.0;

// =============================================================================
// Canonical conversions  (ported verbatim from prompt0c/src/root.zig)
// =============================================================================

/// Assemble a big-endian 16-bit register word from the two bus bytes (MSB first).
pub fn bytesToWord(msb: u8, lsb: u8) u16 {
    return (@as(u16, msb) << 8) | @as(u16, lsb);
}

/// Split a 16-bit register word into the two big-endian bus bytes (MSB first).
pub fn wordToBytes(reg: u16) [2]u8 {
    return .{ @truncate(@as(u32, reg) >> 8), @truncate(reg) };
}

/// Decode a normal-mode (12-bit) temperature register word to degrees C.
pub fn decodeTempNormal(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 4)) * RESOLUTION;
}

/// Encode a temperature in degrees C to a normal-mode (12-bit) register word,
/// left-aligned at bits 15:4, rounded to the nearest 0.0625 C LSB. Clamps to the
/// 12-bit signed range [-128, 127.9375] C.
pub fn encodeTempNormal(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = clamp(raw, -2048, 2047);
    return @as(u16, @bitCast(@as(i16, @intCast(count)))) << 4;
}

/// Decode an extended-mode (13-bit) temperature register word to degrees C.
pub fn decodeTempExtended(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 3)) * RESOLUTION;
}

/// Encode a temperature to an extended-mode (13-bit) register word (bits 15:3,
/// with the extended-marker bit 0 set). Clamps to [-256, 255.9375] C.
pub fn encodeTempExtended(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = clamp(raw, -4096, 4095);
    const base: u16 = @as(u16, @bitCast(@as(i16, @intCast(count)))) << 3;
    return base | 0x0001;
}

/// Clamp a value to [min, max] (local helper kept out of the std import graph).
pub fn clamp(v: i32, min: i32, max: i32) i32 {
    return if (v < min) min else if (v > max) max else v;
}

// Configuration register field helpers (ported verbatim).
pub fn getBit(reg: u16, bit: u4) bool {
    return ((reg >> bit) & 1) == 1;
}

pub fn setBit(reg: u16, bit: u4, value: bool) u16 {
    const bit_value: u16 = @as(u16, 1) << bit;
    if (value) return reg | bit_value;
    return reg & ~bit_value;
}

pub fn configShutdown(reg: u16) bool {
    return getBit(reg, 8);
}

pub fn configExtendedMode(reg: u16) bool {
    return getBit(reg, 4);
}

pub fn conversionRateField(reg: u16) u2 {
    return @truncate(reg >> 6);
}

pub fn conversionRateHz(reg: u16) f32 {
    return switch (conversionRateField(reg)) {
        0 => 0.25,
        1 => 1.0,
        2 => 4.0,
        3 => 8.0,
    };
}

// =============================================================================
// Chip state machine
// =============================================================================

const ChipState = struct {
    i2c: I2cDev = 0,
    temp_attr: u32 = 0, // live ambient temperature control (deg C)
    config: u16 = CONFIG_RESET,
    low_limit: u16 = TLOW_RESET,
    high_limit: u16 = THIGH_RESET,
    // I2C register pointer (16-bit registers, no auto-increment per protocol).
    has_reg_ptr: bool = false,
    reg_ptr: u8 = REG_TEMPERATURE,
    // Selects which byte of the current 16-bit register the next READ returns.
    read_byte_idx: u8 = 0,
    // Selects which byte of a register write transaction is expected next.
    write_word: u16 = 0,
    write_msb_next: bool = true,
};

var global_chip: ChipState = undefined;

fn readWord(chip: *ChipState, reg: u8) u16 {
    const active = configExtendedMode(chip.config);
    return switch (reg) {
        REG_TEMPERATURE => blk: {
            const c: f32 = @floatCast(attrReadFloat(chip.temp_attr));
            break :blk if (active) encodeTempExtended(c) else encodeTempNormal(c);
        },
        REG_CONFIGURATION => chip.config,
        REG_LOW_LIMIT => chip.low_limit,
        REG_HIGH_LIMIT => chip.high_limit,
        else => 0,
    };
}

fn readRegByte(chip: *ChipState) u8 {
    const word = readWord(chip, chip.reg_ptr);
    const bytes = wordToBytes(word);
    const b = bytes[chip.read_byte_idx & 1];
    chip.read_byte_idx +%= 1;
    return b;
}

fn writeRegWord(chip: *ChipState, reg: u8, word: u16) void {
    switch (reg) {
        REG_CONFIGURATION => chip.config = word,
        REG_LOW_LIMIT => chip.low_limit = word,
        REG_HIGH_LIMIT => chip.high_limit = word,
        // REG_TEMPERATURE is read-only.
        else => {},
    }
}

// ─── Wokwi callbacks ──────────────────────────────────────────────────────────

fn onI2cConnect(user_data: ?*anyopaque, address: u32, read: bool) callconv(.c) bool {
    _ = read;
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    if (address != I2C_ADDRESS) return false; // NACK
    chip.read_byte_idx = 0;
    return true; // ACK
}

fn onI2cRead(user_data: ?*anyopaque) callconv(.c) u8 {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    return readRegByte(chip);
}

fn onI2cWrite(user_data: ?*anyopaque, byte: u8) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    if (!chip.has_reg_ptr) {
        // First byte of a write transaction selects the register pointer.
        chip.reg_ptr = byte % REG_COUNT;
        chip.has_reg_ptr = true;
        chip.read_byte_idx = 0;
        chip.write_word = 0;
        chip.write_msb_next = true;
    } else if (chip.write_msb_next) {
        // Second byte = MSB of the 16-bit register word.
        chip.write_word = @as(u16, byte) << 8;
        chip.write_msb_next = false;
    } else {
        // Third byte = LSB; assemble and commit the word.
        const word = chip.write_word | byte;
        writeRegWord(chip, chip.reg_ptr, word);
        chip.write_word = 0;
        chip.write_msb_next = true;
    }
    return true; // ACK
}

fn onI2cDisconnect(user_data: ?*anyopaque) callconv(.c) void {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    chip.has_reg_ptr = false;
}

comptime {
    if (chip_mode) {
        @export(&chipInit, .{ .name = "chipInit" });
    }
}

fn chipInit() callconv(.c) void {
    const chip = &global_chip;
    chip.* = ChipState{};

    // Ambient temperature read from the `temperature` diagram control.
    chip.temp_attr = attrInit("temperature", DEFAULT_TEMP_C);

    const i2c_cfg = I2cConfig{
        .user_data = chip,
        .address = I2C_ADDRESS,
        .scl = pinInit("SCL", @intFromEnum(PinMode.input)),
        .sda = pinInit("SDA", @intFromEnum(PinMode.input)),
        .connect = onI2cConnect,
        .read = onI2cRead,
        .write = onI2cWrite,
        .disconnect = onI2cDisconnect,
        .reserved = [_]u32{0} ** 8,
    };
    chip.i2c = i2cInit(&i2c_cfg);
}

// =============================================================================
// Unit tests — register-encoding helpers vs. concrete worked examples
// (mirrors the verified cases in prompt0c/src/root.zig; the canonical pin of
// 21.0 C is asserted as a register word of 0x1500 exactly per the test spec).
// =============================================================================

test "byte order is MSB-first" {
    try std.testing.expectEqual(@as(u16, 0x6400), bytesToWord(0x64, 0x00));
    try std.testing.expectEqualSlices(u8, &.{ 0x64, 0x00 }, &wordToBytes(0x6400));
    for (0..0x10000) |i| {
        const r: u16 = @intCast(i);
        const b = wordToBytes(r);
        try std.testing.expectEqual(r, bytesToWord(b[0], b[1]));
    }
}

test "canonical default temperature encodes to 0x1500 (21.0 C -> register word)" {
    // count = 21.0 / 0.0625 = 336 = 0x150 -> left-aligned at bits 15:4 = 0x1500.
    try std.testing.expectEqual(@as(u16, 0x1500), encodeTempNormal(DEFAULT_TEMP_C));
    try std.testing.expectApproxEqAbs(DEFAULT_TEMP_C, decodeTempNormal(0x1500), 0.0001);
}

test "decode normal-mode register word (12-bit) from spec table" {
    const cases = [_]struct { reg: u16, c: f32 }{
        .{ .reg = 0x7FF0, .c = 127.9375 },
        .{ .reg = 0x6400, .c = 100.0 },
        .{ .reg = 0x5000, .c = 80.0 },
        .{ .reg = 0x4B00, .c = 75.0 },
        .{ .reg = 0x3200, .c = 50.0 },
        .{ .reg = 0x1900, .c = 25.0 },
        .{ .reg = 0x0040, .c = 0.25 },
        .{ .reg = 0x0000, .c = 0.0 },
        .{ .reg = 0xFFC0, .c = -0.25 },
        .{ .reg = 0xE700, .c = -25.0 },
        .{ .reg = 0xC900, .c = -55.0 },
    };
    for (cases) |case| {
        try std.testing.expectApproxEqAbs(case.c, decodeTempNormal(case.reg), 0.0001);
    }
}

test "encode normal-mode register word (12-bit) matches spec table" {
    try std.testing.expectEqual(@as(u16, 0x6400), encodeTempNormal(100.0));
    try std.testing.expectEqual(@as(u16, 0x5000), encodeTempNormal(80.0));
    try std.testing.expectEqual(@as(u16, 0x4B00), encodeTempNormal(75.0));
    try std.testing.expectEqual(@as(u16, 0x3200), encodeTempNormal(50.0));
    try std.testing.expectEqual(@as(u16, 0x1900), encodeTempNormal(25.0));
    try std.testing.expectEqual(@as(u16, 0x0040), encodeTempNormal(0.25));
    try std.testing.expectEqual(@as(u16, 0x0000), encodeTempNormal(0.0));
    try std.testing.expectEqual(@as(u16, 0xFFC0), encodeTempNormal(-0.25));
    try std.testing.expectEqual(@as(u16, 0xE700), encodeTempNormal(-25.0));
    try std.testing.expectEqual(@as(u16, 0xC900), encodeTempNormal(-55.0));
}

test "encode normal mode clamps to 12-bit signed range" {
    try std.testing.expectEqual(@as(u16, 0x7FF0), encodeTempNormal(128.0));
    try std.testing.expectEqual(@as(u16, 0x8000), encodeTempNormal(-128.1));
}

test "extended mode registers match manifest layout" {
    // 150 C -> count 2400 = 0x960 @ bits 15:3 -> 0x4B00 | marker = 0x4B01.
    try std.testing.expectEqual(@as(u16, 0x4B01), encodeTempExtended(150.0));
    // 21 C -> count 336 @ bits 15:3 -> 0x0A80 | marker = 0x0A81.
    try std.testing.expectEqual(@as(u16, 0x0A81), encodeTempExtended(DEFAULT_TEMP_C));
    try std.testing.expectApproxEqAbs(DEFAULT_TEMP_C, decodeTempExtended(0x0A81), 0.0001);
}

test "register defaults and reset values" {
    try std.testing.expectEqual(@as(u16, 0x6080), CONFIG_RESET);
    try std.testing.expectEqual(@as(u16, 0x4B00), TLOW_RESET); // 75 C
    try std.testing.expectEqual(@as(u16, 0x5000), THIGH_RESET); // 80 C
    try std.testing.expectEqual(false, configShutdown(CONFIG_RESET));
    try std.testing.expectEqual(false, configExtendedMode(CONFIG_RESET));
    try std.testing.expectEqual(@as(f32, 4.0), conversionRateHz(CONFIG_RESET)); // CR = 10b
}
