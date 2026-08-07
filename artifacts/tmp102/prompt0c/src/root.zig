//! TMP102 data conversions and reference algorithms.
//!
//! This module is the **single source of truth** for the register-level bit
//! layout of the TMP102 temperature sensor (TI datasheet SBOS397; Tables 6-2/6-3,
//! 6-8/6-9 and 6-10/6-11). Any downstream skill that encodes or decodes TMP102
//! register words MUST reuse or port these exact functions rather than
//! re-deriving the bit layout.
//!
//! Data is read/written over I2C **MSB-first** (big-endian). The 16-bit
//! temperature result is a signed, two's-complement value left-justified in the
//! register word. One LSB equals 0.0625 C.
const std = @import("std");

/// Conversion scale: 1 LSB = 0.0625 C.
pub const RESOLUTION: f32 = 0.0625;

// Register map addresses (pointer bytes).
pub const REG_TEMPERATURE: u8 = 0x00;
pub const REG_CONFIGURATION: u8 = 0x01;
pub const REG_LOW_LIMIT: u8 = 0x02;
pub const REG_HIGH_LIMIT: u8 = 0x03;

/// Power-up/reset value of the configuration register (byte1 0x60, byte2 0x80).
pub const CONFIG_RESET: u16 = 0x6080;

// ===========================================================================
// Byte order (the register is transmitted MSB-first over the I2C bus)
// ===========================================================================

/// Assemble a big-endian 16-bit register word from the two bytes read from the
/// bus, MSB-first (byte1 = most significant byte).
pub fn bytesToWord(msb: u8, lsb: u8) u16 {
    return (@as(u16, msb) << 8) | @as(u16, lsb);
}

/// Split a 16-bit register word into the two big-endian bus bytes, MSB-first.
pub fn wordToBytes(reg: u16) [2]u8 {
    return .{ @truncate(@as(u32, reg) >> 8), @truncate(reg) };
}

// ===========================================================================
// Temperature conversions - Normal mode (12-bit, EM = 0)
//
// The 12-bit two's-complement value T11..T0 is left-aligned in bits 15:4; the
// lower nibble (bits 3:0) always reads 0. Decode via an arithmetic shift so the
// sign bit (bit 15) sign-extends automatically:
//   temp_C = ((i16)reg >> 4) * 0.0625
// ===========================================================================

/// Decode a normal-mode (12-bit) temperature register word to degrees C.
pub fn decodeTempNormal(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 4)) * RESOLUTION;
}

/// Encode a temperature in degrees C to a normal-mode (12-bit) register word,
/// left-aligned at bits 15:4, rounded to the nearest 0.0625 C LSB.
/// Clamps to the 12-bit signed range [-128, 127.9375] C.
pub fn encodeTempNormal(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = std.math.clamp(raw, -2048, 2047);
    return @as(u16, @bitCast(@as(i16, @intCast(count)))) << 4;
}

// ===========================================================================
// Temperature - Extended mode (13-bit, EM = 1)
//
// The 13-bit two's-complement value T12..T0 occupies bits 15:3 (left-aligned);
// bit 0 of the register word (D0 of byte 2) is set to 1 to flag the extended
// data format. Decode via an arithmetic shift of the signed register word:
//   temp_C = ((i16)reg >> 3) * 0.0625
// ===========================================================================

pub fn decodeTempExtended(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 3)) * RESOLUTION;
}

/// Encode a temperature (degrees C) to an extended-mode (13-bit) register word,
/// left-aligned at bits 15:3 with the extended marker set in bit 0.
/// Round-clamped to the 13-bit signed range [-256, 255.9375] C.
pub fn encodeTempExtended(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = std.math.clamp(raw, -4096, 4095);
    const base: u16 = @as(u16, @bitCast(@as(i16, @intCast(count)))) << 3;
    // Bit 0 (D0 of byte 2) flags the extended data format.
    return base | 0x0001;
}

// ===========================================================================
// Configuration register (0x01) - field helpers
//
// Byte 1 (MSB):  D7..D0 = OS, R1, R0, F1, F0, POL, TM, SD
// Byte 2 (LSB):  D7..D0 = CR1, CR0, AL, EM, -, -, -, -
// ===========================================================================

/// Read bit `bit` (0..15) of a 16-bit register word.
pub fn getBit(reg: u16, bit: u4) bool {
    return ((reg >> bit) & 1) == 1;
}

/// Return a copy of `reg` with bit `bit` set to `value`.
pub fn setBit(reg: u16, bit: u4, value: bool) u16 {
    const bit_value: u16 = @as(u16, 1) << bit;
    if (value) return reg | bit_value;
    return reg & ~bit_value;
}

/// Overtemperature-alert polarity (POL): 0 = active-low, 1 = active-high.
pub fn configPolarity(reg: u16) bool {
    return getBit(reg, 10);
}
/// Thermostat mode (TM): 0 = comparator, 1 = interrupt.
pub fn configThermostatMode(reg: u16) bool {
    return getBit(reg, 9);
}
/// Shutdown mode (SD): 1 = shutdown / low power.
pub fn configShutdown(reg: u16) bool {
    return getBit(reg, 8);
}
/// Extended Mode (EM): 0 = 12-bit, 1 = 13-bit.
pub fn configExtendedMode(reg: u16) bool {
    return getBit(reg, 4);
}

/// Extract the 2-bit conversion-rate field (CR1:CR0) from bits 7:6.
pub fn conversionRateField(reg: u16) u2 {
    return @truncate(reg >> 6);
}

/// Map the CR1:CR0 field to the conversion rate in Hz:
///   00 = 0.25 Hz, 01 = 1 Hz, 10 = 4 Hz (reset default), 11 = 8 Hz.
pub fn conversionRateHz(reg: u16) f32 {
    return switch (conversionRateField(reg)) {
        0 => 0.25,
        1 => 1.0,
        2 => 4.0,
        3 => 8.0,
    };
}

/// Map the F1:F0 fault-queue field (bits 12:11) to the required number of
/// consecutive fault measurements: 00=1, 01=2, 10=4, 11=6.
pub fn faultQueueCount(reg: u16) u8 {
    const f: u2 = @truncate(reg >> 11);
    return switch (f) {
        0 => 1,
        1 => 2,
        2 => 4,
        3 => 6,
    };
}

// ===========================================================================
// Tests
// ===========================================================================

test "byte order is inverse" {
    // 100 C -> bytes [0x64, 0x00] big-endian.
    try std.testing.expectEqual(@as(u16, 0x6400), bytesToWord(0x64, 0x00));
    try std.testing.expectEqualSlices(u8, &.{ 0x64, 0x00 }, &wordToBytes(0x6400));
    for (0..0x10000) |i| {
        const r: u16 = @intCast(i);
        const b = wordToBytes(r);
        try std.testing.expectEqual(r, bytesToWord(b[0], b[1]));
    }
}

test "decode normal-mode register word (12-bit) from spec table" {
    // Register word equals (count << 4); values from the canonical spec.
    const cases = [_]struct { reg: u16, c: f32 }{
        .{ .reg = 0x7FF0, .c = 127.9375 }, // ~128 (12-bit max)
        .{ .reg = 0x6400, .c = 100.0 },
        .{ .reg = 0x5000, .c = 80.0 }, // THIGH reset
        .{ .reg = 0x4B00, .c = 75.0 }, // TLOW reset
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
    // 128 C clamps to +127.9375 (0x7FF0); -128.1 C clamps to -128 (0x8000).
    try std.testing.expectEqual(@as(u16, 0x7FF0), encodeTempNormal(128.0));
    try std.testing.expectEqual(@as(u16, 0x8000), encodeTempNormal(-128.1));
}

test "canonical observable 21.0 C round-trip (normal mode)" {
    // count = 21.0 / 0.0625 = 336 = 0x150 -> register word 0x1500.
    try std.testing.expectEqual(@as(u16, 0x1500), encodeTempNormal(21.0));
    try std.testing.expectApproxEqAbs(21.0, decodeTempNormal(0x1500), 0.0001);
}

test "decode extended-mode (13-bit) from spec worked examples" {
    // count13 left-aligned at bits 15:3 + EM marker in bit 0.
    const cases = [_]struct { c: f32, count13: i32 }{
        .{ .c = 150.0, .count13 = 2400 },
        .{ .c = 128.0, .count13 = 2048 },
        .{ .c = 100.0, .count13 = 1600 },
        .{ .c = 25.0, .count13 = 400 },
        .{ .c = -0.25, .count13 = -4 },
        .{ .c = -25.0, .count13 = -400 },
    };
    for (cases) |case| {
        const reg: u16 = (@as(u16, @bitCast(@as(i16, @intCast(case.count13)))) << 3) | 0x0001;
        try std.testing.expectApproxEqAbs(case.c, decodeTempExtended(reg), 0.0001);
    }
}

test "encode extended-mode (13-bit) round-trips" {
    // 150 C -> count 2400 = 0x960 @ bits 15:3 -> 0x4B00 | marker = 0x4B01.
    try std.testing.expectEqual(@as(u16, 0x4B01), encodeTempExtended(150.0));
    // 21.0 C -> count 336 = 0x150 @ bits 15:3 -> 0x0A80 | marker = 0x0A81.
    try std.testing.expectEqual(@as(u16, 0x0A81), encodeTempExtended(21.0));
    // Marker bit must not affect the decoded temperature.
    try std.testing.expectApproxEqAbs(21.0, decodeTempExtended(0x0A81), 0.0001);
}

test "config reset value field decoding" {
    // Reset config 0x6080: byte1 0110 0000, byte2 1000 0000.
    try std.testing.expectEqual(@as(u16, 0x6080), CONFIG_RESET);
    try std.testing.expectEqual(false, configShutdown(0x6080));
    try std.testing.expectEqual(false, configExtendedMode(0x6080));
    try std.testing.expectEqual(@as(f32, 4.0), conversionRateHz(0x6080)); // CR = 10
}

test "config field accessors, setBit, fault queue, conversion rate" {
    // SD set via setBit.
    const sd = setBit(0x0000, 8, true);
    try std.testing.expect(configShutdown(sd));
    try std.testing.expectEqual(false, configShutdown(setBit(sd, 8, false)));
    // F1:F0 fields.
    const f = setBit(setBit(0x0000, 12, true), 11, true);
    try std.testing.expectEqual(@as(u8, 6), faultQueueCount(f));
    try std.testing.expectEqual(@as(u8, 1), faultQueueCount(0x0000));
    // Conversion rate mapping 00..11.
    var rates: [4]f32 = undefined;
    inline for (0..4) |i| {
        rates[i] = conversionRateHz(@as(u16, i) << 6);
    }
    try std.testing.expectEqual([4]f32{ 0.25, 1.0, 4.0, 8.0 }, rates);
}