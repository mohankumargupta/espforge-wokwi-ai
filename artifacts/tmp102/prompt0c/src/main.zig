//! TMP102 — register-level data conversion and reference algorithms.
//!
//! Single source of truth for TMP102 register bit layout:
//!   * temperature count is two's-complement, 12-bit (Normal) or 13-bit
//!     (Extended Mode, EM=1);
//!   * count is left-aligned in the 16-bit register word — Normal occupies
//!     bits 15:4, Extended occupies bits 15:3 with D0 of byte 2 == 1;
//!   * resolution is 0.0625 C per count;
//!   * the two register bytes travel MSB-first on the I2C bus.
//!
//! Sources: artifacts/tmp102/outputs/spec_tmp102.md ("Temperature Register
//! formatting", "Data Conversion", datasheet Tables 6-2 / 6-3).
//!
//! Downstream reuse contract: skills that later encode/decode TMP102 register
//! values MUST reuse or port these exact functions, never re-derive the
//! layout independently.

const std = @import("std");

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Degrees Celsius represented by one temperature count.
pub const LSB_DEGC = 0.0625;

/// Bit width of the Normal-mode temperature count.
pub const normal_count_bits = 12;

/// Bit width of the Extended-mode (EM=1) temperature count.
pub const extended_count_bits = 13;

/// Left-alignment shift of the 12-bit Normal count inside the 16-bit word.
pub const normal_count_word_shift = 4;

/// Left-alignment shift of the 13-bit Extended count inside the 16-bit word.
pub const extended_count_word_shift = 3;

/// Word bit set in Extended Mode to distinguish it from Normal format.
pub const extended_marker_mask: u16 = 0x0001;

/// Smallest / largest representable 12-bit signed counts.
pub const min_count_normal = -2048;
pub const max_count_normal = 2047;

/// Smallest / largest representable 13-bit signed counts.
pub const min_count_extended = -4096;
pub const max_count_extended = 4095;

// ---------------------------------------------------------------------------
// Sign extension (two's-complement reference algorithm)
// ---------------------------------------------------------------------------

/// Sign-extend a `bits`-wide two's-complement value (held in the low `bits`
/// bits of `value`) to a signed 16-bit integer.
pub fn signExtend(value: u16, comptime bits: u5) i16 {
    const sh: u5 = 16 - bits;
    return @as(i16, @bitCast(value << sh)) >> sh;
}

// ---------------------------------------------------------------------------
// Register word <-> temperature count
// ---------------------------------------------------------------------------

/// Extract the signed 12-bit Normal-mode count from the low nibble of a
/// 16-bit register word (count was left-aligned in bits 15:4).
pub fn count12FromWord(word: u16) i16 {
    return signExtend(word >> normal_count_word_shift, normal_count_bits);
}

/// Extract the signed 13-bit Extended-mode count from a 16-bit register word
/// (count was left-aligned in bits 15:3).
pub fn count13FromWord(word: u16) i16 {
    return signExtend(word >> extended_count_word_shift, extended_count_bits);
}

/// Left-align a signed 12-bit count into bits 15:4 of a 16-bit word.
/// The low nibble D3-D0 is zeroed.
pub fn count12ToWord(count: i16) u16 {
    return (@as(u16, @bitCast(count)) & 0x0FFF) << normal_count_word_shift;
}

/// Left-align a signed 13-bit count into bits 15:3 of a 16-bit word and set
/// D0 (Extended-Mode marker) that distinguishes the format.
pub fn count13ToWord(count: i16) u16 {
    return ((@as(u16, @bitCast(count)) & 0x1FFF) << extended_count_word_shift) |
        extended_marker_mask;
}

// ---------------------------------------------------------------------------
// Register word <-> temperature (C)
// ---------------------------------------------------------------------------

/// Decode a Normal-mode (12-bit) temperature register word to degrees C.
pub fn temperatureCFromWord(word: u16) f32 {
    return @as(f32, @floatFromInt(count12FromWord(word))) * LSB_DEGC;
}

/// Decode an Extended-mode (13-bit) temperature register word to degrees C.
pub fn temperatureCFromWordExtended(word: u16) f32 {
    return @as(f32, @floatFromInt(count13FromWord(word))) * LSB_DEGC;
}

/// True if a register word carries the Extended-Mode marker (D0 == 1).
pub fn registerIsExtendedMode(word: u16) bool {
    return (word & extended_marker_mask) != 0;
}

/// Decode a register word, auto-detecting Normal vs Extended format via D0.
pub fn temperatureCFromWordAuto(word: u16) f32 {
    return if (registerIsExtendedMode(word))
        temperatureCFromWordExtended(word)
    else
        temperatureCFromWord(word);
}

// ---------------------------------------------------------------------------
// Temperature (C) -> count / word (encoding, with rounding + clamping)
// ---------------------------------------------------------------------------

/// Convert degrees C to a signed 12-bit count, rounding to nearest count and
/// clamping to the representable 12-bit range.
pub fn count12FromTemperatureC(temp_c: f32) i16 {
    const scaled = @round(temp_c / LSB_DEGC);
    var c: i32 = @intFromFloat(scaled);
    c = @max(min_count_normal, @min(max_count_normal, c));
    return @intCast(c);
}

/// Convert degrees C to a signed 13-bit count, rounding to nearest count and
/// clamping to the representable 13-bit range.
pub fn count13FromTemperatureC(temp_c: f32) i16 {
    const scaled = @round(temp_c / LSB_DEGC);
    var c: i32 = @intFromFloat(scaled);
    c = @max(min_count_extended, @min(max_count_extended, c));
    return @intCast(c);
}

/// Encode degrees C directly into a Normal-mode (12-bit) register word.
pub fn temperatureCToRegisterWord12(temp_c: f32) u16 {
    return count12ToWord(count12FromTemperatureC(temp_c));
}

/// Encode degrees C directly into an Extended-mode (13-bit) register word.
pub fn temperatureCToRegisterWord13(temp_c: f32) u16 {
    return count13ToWord(count13FromTemperatureC(temp_c));
}

// ---------------------------------------------------------------------------
// Byte packing (the register bytes travel MSB-first on the I2C bus)
// ---------------------------------------------------------------------------

/// Assemble the 16-bit register word from the two MSB-first bytes.
pub fn bytesToWord(msb: u8, lsb: u8) u16 {
    return (@as(u16, msb) << 8) | lsb;
}

/// Split a 16-bit register word into the two MSB-first bytes [msb, lsb].
pub fn wordToBytes(word: u16) [2]u8 {
    return .{ @intCast(word >> 8), @intCast(word & 0xFF) };
}

/// Decode a Normal-mode temperature from the two MSB-first bus bytes.
pub fn temperatureCFromBytes(msb: u8, lsb: u8) f32 {
    return temperatureCFromWord(bytesToWord(msb, lsb));
}

/// Decode a temperature from only the MSB byte (the LSB byte may be omitted
/// on the bus). One LSB of the MSB byte is 4 counts = 0.25 C; the low four
/// count bits are assumed zero. Caller loses 0.0625 C resolution.
pub fn temperatureCFromMsbByteOnly(msb: u8) f32 {
    const count: i16 = @as(i16, @as(i8, @bitCast(msb))) << 4;
    return @as(f32, @floatFromInt(count)) * LSB_DEGC;
}

// ---------------------------------------------------------------------------
// CLI entry point
// ---------------------------------------------------------------------------

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("TMP102 data conversion module loaded; run `zig build test`.\n", .{});
}

// ---------------------------------------------------------------------------
// Unit tests
// ---------------------------------------------------------------------------

const assert = std.testing.expect;
const assertEqual = std.testing.expectEqual;
const assertApprox = std.testing.expectApproxEqRel;

test "signExtend: positive and negative 12-bit values" {
    try assertEqual(@as(i16, 400), signExtend(0x190, 12)); //  25 C raw count
    try assertEqual(@as(i16, -4), signExtend(0xFFC, 12)); // -0.25 C raw count
    try assertEqual(@as(i16, -400), signExtend(0xE70, 12)); // -25 C raw count
    try assertEqual(@as(i16, 2047), signExtend(0x7FF, 12)); // max positive
    try assertEqual(@as(i16, -2048), signExtend(0x800, 12)); // min negative
}

test "signExtend: 13-bit extended values" {
    try assertEqual(@as(i16, 400), signExtend(0x190, 13));
    try assertEqual(@as(i16, -400), signExtend(0x1E70, 13)); // -25 C, 13-bit
    try assertEqual(@as(i16, 4095), signExtend(0x0FFF, 13)); // max positive
    try assertEqual(@as(i16, -1), signExtend(0x1FFF, 13)); // all bits set = -1
    try assertEqual(@as(i16, -4096), signExtend(0x1000, 13));
}

test "datasheet Table 6-2: word decode (12-bit, EM=0)" {
    // Real-world | raw count | full register word
    const vectors = [_][3]i32{
        .{ 128, 0x7FF, 0x7FF0 },
        .{ 100, 0x640, 0x6400 },
        .{ 80, 0x500, 0x5000 },
        .{ 75, 0x4B0, 0x4B00 },
        .{ 50, 0x320, 0x3200 },
        .{ 25, 0x190, 0x1900 },
        .{ 0, 0x000, 0x0000 },
        .{ -25, 0xE70, 0xE700 },
        .{ -55, 0xC90, 0xC900 },
    };
    for (vectors) |v| {
        const deg_c: i32 = v[0];
        const raw_count_hex: u16 = @intCast(v[1]);
        // Datasheet HEX column lists the raw two's-complement count unsigned;
        // sign-extend its 12 bits to recover the signed count.
        const count: i16 = signExtend(raw_count_hex, 12);
        const word: u16 = @intCast(v[2]);
        try assertEqual(count, count12FromWord(word));
        try assertEqual(raw_count_hex, @as(u16, @bitCast(count)) & 0x0FFF);
        try assertEqual(word, count12ToWord(count));
        try assertEqual(count, count12FromTemperatureC(@floatFromInt(deg_c)));
        try assertEqual(word, temperatureCToRegisterWord12(@floatFromInt(deg_c)));
        // Register holds the count exactly, so decode must reproduce
        // count * LSB (max count 0x7FF decodes to 127.9375, not 128).
        const expected_temp = @as(f32, @floatFromInt(count)) * LSB_DEGC;
        try assertApprox(expected_temp, temperatureCFromWord(word), 1e-6);
    }
}

test "datasheet Table 6-2: 0.25 C and min/max edges" {
    //  0.25 C -> 0x004 -> word 0x0040
    try assertEqual(@as(i16, 4), count12FromWord(0x0040));
    try assertApprox(@as(f32, 0.25), temperatureCFromWord(0x0040), 1e-4);
    try assertEqual(@as(u16, 0x0040), temperatureCToRegisterWord12(0.25));
    // -0.25 C -> 0xFFC -> word 0xFFC0
    try assertEqual(@as(i16, -4), count12FromWord(0xFFC0));
    try assertApprox(@as(f32, -0.25), temperatureCFromWord(0xFFC0), 1e-4);
    // max representable: 0x7FF0 = 127.9375 C (datasheet lists 128 also as 0x7FF)
    try assertApprox(@as(f32, 127.9375), temperatureCFromWord(0x7FF0), 1e-4);
    try assertApprox(@as(f32, -128.0), temperatureCFromWord(0x8000), 1e-4);
}

test "encode clamps out-of-range temperatures to 12-bit span" {
    try assertEqual(@as(u16, 0x7FF0), temperatureCToRegisterWord12(200.0));
    try assertEqual(@as(u16, 0x8000), temperatureCToRegisterWord12(-200.0));
    try assertEqual(@as(i16, 2047), count12FromTemperatureC(200.0));
    try assertEqual(@as(i16, -2048), count12FromTemperatureC(-200.0));
}

test "half-count resolution: rounding to nearest count" {
    // 0.03125 C below/above a count boundary rounds down/up.
    try assertEqual(@as(i16, 4), count12FromTemperatureC(0.25));
    try assertEqual(@as(i16, 3), count12FromTemperatureC(0.1875));
    try assertEqual(@as(i16, -4), count12FromTemperatureC(-0.25));
    try assertEqual(@as(i16, -3), count12FromTemperatureC(-0.1875));
}

test "extended mode (13-bit): encode/decode roundtrip" {
    // 25 C -> 13-bit count 0x190 -> word (0x190 << 3) | 1 = 0xC81
    try assertEqual(@as(u16, 0x0C81), temperatureCToRegisterWord13(25.0));
    try assertApprox(@as(f32, 25.0), temperatureCFromWordExtended(0x0C81), 1e-4);
    // -25 C -> 13-bit count 0x1E70 -> word 0xF381
    try assertEqual(@as(u16, 0xF381), temperatureCToRegisterWord13(-25.0));
    try assertApprox(@as(f32, -25.0), temperatureCFromWordExtended(0xF381), 1e-4);
    // Marker distinguishes formats.
    try assert(registerIsExtendedMode(0xF381));
    try assert(!registerIsExtendedMode(0xE700));
}

test "auto-detection via D0 marker" {
    try assertApprox(@as(f32, 21.0), temperatureCFromWordAuto(0x1500), 1e-4); // Normal
    try assertApprox(@as(f32, 25.0), temperatureCFromWordAuto(0x0C81), 1e-4); // Extended
}

test "byte packing: MSB-first bus order" {
    try assertEqual(@as(u16, 0x1900), bytesToWord(0x19, 0x00)); // 25 C
    try assertEqual(@as(u16, 0xE700), bytesToWord(0xE7, 0x00)); // -25 C
    try assertEqualSlicesBytes(&[_]u8{ 0x19, 0x00 }, &wordToBytes(0x1900));
    try assertEqualSlicesBytes(&[_]u8{ 0xE7, 0x00 }, &wordToBytes(0xE700));
    try assertApprox(@as(f32, 25.0), temperatureCFromBytes(0x19, 0x00), 1e-4);
    try assertApprox(@as(f32, -25.0), temperatureCFromBytes(0xE7, 0x00), 1e-4);
}

test "LSB byte omitted: decode from MSB byte only" {
    // LSB of the MSB byte is 4 counts = 0.25 C, so single-byte decode
    // quantizes to 0.25 C intervals; sub-LSB values (0.25 C) alias toward 0.
    try assertApprox(@as(f32, 25.0), temperatureCFromMsbByteOnly(0x19), 1e-4);
    try assertApprox(@as(f32, -25.0), temperatureCFromMsbByteOnly(0xE7), 1e-4);
    try assertApprox(@as(f32, 0.0), temperatureCFromMsbByteOnly(0x00), 1e-4);
}

test "default observable: 21.0 C encodes to 0x1500" {
    const word = temperatureCToRegisterWord12(21.0);
    try assertEqual(@as(u16, 0x1500), word); // 21/0.0625 = 336 = 0x150
    try assertApprox(@as(f32, 21.0), temperatureCFromWord(word), 1e-4);
    try assertApprox(@as(f32, 21.0), temperatureCFromBytes(0x15, 0x00), 1e-4);
}

test "power-up default register reads 0 C until first conversion" {
    try assertEqual(@as(u16, 0x0000), temperatureCToRegisterWord12(0.0));
    try assertApprox(@as(f32, 0.0), temperatureCFromWord(0x0000), 1e-4);
    try assertEqual(@as(f32, 0.0), temperatureCFromMsbByteOnly(0x00));
}

test "fuzz: encode/decode roundtrips over full 12-bit count range" {
    try std.testing.fuzz({}, fuzzRoundtrip12, .{});
}

fn fuzzRoundtrip12(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    const count: i16 = @bitCast(smith.value(u16));
    const word = count12ToWord(count);
    try assertEqual(@as(u16, @bitCast(count)) & 0x0FFF, @as(u16, @bitCast(count12FromWord(word))) & 0x0FFF);
}

fn assertEqualSlicesBytes(expected: *const [2]u8, actual: *const [2]u8) !void {
    try assertEqual(expected[0], actual[0]);
    try assertEqual(expected[1], actual[1]);
}