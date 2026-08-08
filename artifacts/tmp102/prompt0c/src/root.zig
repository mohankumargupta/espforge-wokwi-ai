//! TMP102 data conversions and reference algorithms.
//!
//! This module is the **single source of truth** for the register-level bit
//! layout of the TMP102 temperature sensor (TI datasheet SBOS397; tables 6-2/6-3
//! and 6-8/6-9). Any downstream skill that encodes or decodes TMP102 register
//! words MUST reuse or port these exact functions rather than re-deriving the
//! bit layout.
//!
//! Register words are I2C **MSB-first** (big-endian). The 16-bit temperature
//! result is a signed, two's-complement value left-justified in the register
//! word; one LSB equals 0.0625 C.
const std = @import("std");

/// Conversion scale: 1 LSB = 0.0625 C.
pub const RESOLUTION: f32 = 0.0625;

// Register map addresses (pointer bytes).
pub const REG_TEMPERATURE: u8 = 0x00;
pub const REG_CONFIGURATION: u8 = 0x01;
pub const REG_LOW_LIMIT: u8 = 0x02;
pub const REG_HIGH_LIMIT: u8 = 0x03;

/// Power-up / general-call-reset value of the Configuration register.
/// Byte 1 = 0x60 (R1,R0 = 11 -> 12-bit), Byte 2 = 0xA0 (CR1,CR0 = 10 -> 4 Hz,
/// AL = 1 -> alert not asserted, EM = 0 -> normal mode).
pub const CONFIG_RESET: u16 = 0x60A0;

// ===========================================================================
// Byte order (register words are transmitted MSB-first over the I2C bus)
// ===========================================================================

/// Assemble a big-endian 16-bit register word from the two bytes read from the
/// bus, MSB-first (first byte read is the most significant byte).
pub fn bytesToWord(msb: u8, lsb: u8) u16 {
    return (@as(u16, msb) << 8) | @as(u16, lsb);
}

/// Split a 16-bit register word into the two big-endian bus bytes, MSB-first.
pub fn wordToBytes(reg: u16) [2]u8 {
    return .{ @truncate(@as(u32, reg) >> 8), @truncate(reg) };
}

/// Sign-extend the low N bits of `value` (N in 1..16) into a full i16.
/// Standard for reading N-bit two's-complement temperature counts.
pub fn signExtend(value: u16, comptime n: u5) i16 {
    const target: i16 = @bitCast(value);
    const shift: u5 = @intCast(16 - @as(u16, n));
    return target << shift >> shift;
}

// ===========================================================================
// Temperature conversions - Normal mode (12-bit, EM = 0)
//
// The 12-bit two's-complement value T11..T0 is LEFT-aligned in bits 15:4 and
// the lower nibble (bits 3:0) reads 0. Decode via an arithmetic shift so the
// sign bit (bit 15) sign-extends automatically:
//   temp_C = ((i16)reg >> 4) * 0.0625
// ===========================================================================

/// Decode a normal-mode (12-bit) temperature register word to degrees C.
pub fn decodeTempNormal(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 4)) * RESOLUTION;
}

/// Encode a temperature in degrees C to a normal-mode (12-bit) register word,
/// left-aligned at bits 15:4, rounded to the nearest 0.0625 C LSB. Clamps to
/// the 12-bit signed range [-128, 127.9375] C.
pub fn encodeTempNormal(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = std.math.clamp(raw, -2048, 2047);
    return @as(u16, @bitCast(@as(i16, @intCast(count)))) << 4;
}

// ===========================================================================
// Temperature conversions - Extended mode (13-bit, EM = 1)
//
// The 13-bit two's-complement value T12..T0 occupies bits 15:3 (left-aligned);
// bit 2:1 of the register word read 0 and bit 0 (D0 of byte 2) reads 1 as the
// extended-format marker. Decode via an arithmetic shift:
//   temp_C = ((i16)reg >> 3) * 0.0625
// The spec's "150 C = 0x0960" examples are the 13-bit COUNT, not a register
// word; the register word stores count << 3 (plus the bit-0 marker).
// ===========================================================================

pub fn decodeTempExtended(reg: u16) f32 {
    const count: i16 = @bitCast(reg);
    return @as(f32, @floatFromInt(count >> 3)) * RESOLUTION;
}

/// Encode a temperature (degrees C) to an extended-mode (13-bit) register word,
/// left-aligned at bits 15:3 with the extended marker set in bit 0. Round-
/// clamped to the 13-bit signed range [-256, 255.9375] C.
pub fn encodeTempExtended(value: f32) u16 {
    const raw: i32 = @intFromFloat(@round(value / RESOLUTION));
    const count = std.math.clamp(raw, -4096, 4095);
    const base: u16 = @as(u16, @bitCast(@as(i16, @intCast(count)))) << 3;
    // Bit 0 (D0 of byte 2) flags the extended data format and reads as 1.
    return base | 0x0001;
}

// ===========================================================================
// Configuration register (0x01) - field helpers
//
// Byte 1 (MSB):  OS R1 R0 F1 F0 POL TM SD   -> bits 15..8
// Byte 2 (LSB):  CR1 CR0 AL EM - - - -     -> bits 7..4 defined, 3..0 zero
// ===========================================================================

const B_OS: u4 = 15; // One-shot start
const B_R1: u4 = 14; // Resolution MSB (read-only)
const B_R0: u4 = 13; // Resolution LSB (read-only)
const B_F1: u4 = 12; // Fault queue MSB
const B_F0: u4 = 11; // Fault queue LSB
const B_POL: u4 = 10; // ALERT polarity
const B_TM: u4 = 9; // Thermostat mode
const B_SD: u4 = 8; // Shutdown
const B_CR1: u4 = 7; // Conversion rate MSB
const B_CR0: u4 = 6; // Conversion rate LSB
const B_AL: u4 = 5; // Alert status (read-only)
const B_EM: u4 = 4; // Extended mode

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

/// Overtemperature-alert polarity (POL): false = active-low, true = active-high.
pub fn configPolarity(reg: u16) bool {
    return getBit(reg, B_POL);
}

/// Thermostat mode (TM): false = comparator, true = interrupt.
pub fn configThermostatMode(reg: u16) bool {
    return getBit(reg, B_TM);
}

/// Shutdown mode (SD): true = shutdown / low power.
pub fn configShutdown(reg: u16) bool {
    return getBit(reg, B_SD);
}

/// Extended mode (EM): true = 13-bit temperature result.
pub fn configExtendedMode(reg: u16) bool {
    return getBit(reg, B_EM);
}

/// Conversion-rate field (CR1:CR0) as a 2-bit index, bits 7:6.
/// 00->0.25 Hz, 01->1 Hz, 10->4 Hz (reset), 11->8 Hz.
pub fn conversionRateField(reg: u16) u2 {
    return @intCast((reg >> 6) & 0b11);
}

/// Conversion-rate field to conversions-per-second.
pub fn conversionRateHz(reg: u16) f32 {
    return switch (conversionRateField(reg)) {
        0b00 => 0.25,
        0b01 => 1.0,
        0b10 => 4.0,
        0b11 => 8.0,
    };
}

/// Fault-queue field (F1:F0), bits 12:11, as a 2-bit index.
/// 00->1, 01->2, 10->4, 11->6 consecutive faults.
pub fn faultQueueField(reg: u16) u2 {
    return @intCast((reg >> 11) & 0b11);
}

/// Fault-queue field to the number of consecutive temperature readings above
/// /below the limits that must occur before the ALERT output asserts.
pub fn faultQueueCount(reg: u16) u8 {
    return switch (faultQueueField(reg)) {
        0b00 => 1,
        0b01 => 2,
        0b10 => 4,
        0b11 => 6,
    };
}

// ===========================================================================
// Transport - I2C address selection (ADD0 pin)
// ===========================================================================

/// 7-bit slave addresses selected by the ADD0 pin strap.
pub const Add0Addr = struct {
    pub const gnd: u7 = 0x48; // ADD0 = GND (default)
    pub const vcc: u7 = 0x49; // ADD0 = V+
    pub const sda: u7 = 0x4A; // ADD0 = SDA
    pub const scl: u7 = 0x4B; // ADD0 = SCL
};

/// Number of the ADD0 strap (0 = GND .. 3 = SCL) for a slave address.
pub fn add0Index(add: u7) !usize {
    return switch (add) {
        0x48 => 0,
        0x49 => 1,
        0x4A => 2,
        0x4B => 3,
        else => error.InvalidAdd0,
    };
}

test "verify spec worked examples, normal mode" {
    try std.testing.expectApproxEqAbs(127.9375, decodeTempNormal(0x7FF0), 0.0001);
    try std.testing.expectApproxEqAbs(100.0, decodeTempNormal(0x6400), 0.0001);
    try std.testing.expectApproxEqAbs(80.0, decodeTempNormal(0x5000), 0.0001);
    try std.testing.expectApproxEqAbs(75.0, decodeTempNormal(0x4B00), 0.0001);
    try std.testing.expectApproxEqAbs(50.0, decodeTempNormal(0x3200), 0.0001);
    try std.testing.expectApproxEqAbs(25.0, decodeTempNormal(0x1900), 0.0001);
    try std.testing.expectApproxEqAbs(0.25, decodeTempNormal(0x0040), 0.0001);
    try std.testing.expectApproxEqAbs(0.0, decodeTempNormal(0x0000), 0.0001);
    try std.testing.expectApproxEqAbs(-0.25, decodeTempNormal(0xFFC0), 0.0001);
    try std.testing.expectApproxEqAbs(-25.0, decodeTempNormal(0xE700), 0.0001);
    try std.testing.expectApproxEqAbs(-55.0, decodeTempNormal(0xC900), 0.0001);
}

test "encode normal mode round-trips spec worked examples" {
    try std.testing.expectEqual(@as(u16, 0x7FF0), encodeTempNormal(127.9375));
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

test "decode/encode extended (13-bit) mode" {
    // 0x4B01 = count 2400 (0x0960) << 3 | 1  ->  2400 * 0.0625 = 150 C
    try std.testing.expectApproxEqAbs(150.0, decodeTempExtended(0x4B01), 0.0001);
    try std.testing.expectEqual(@as(u16, 0x4B01), encodeTempExtended(150.0));

    // 0x0801 = count 2048 (0x0800) << 3 | 1  -> 128 C
    try std.testing.expectApproxEqAbs(128.0, decodeTempExtended(0x4001), 0.0001);
    try std.testing.expectEqual(@as(u16, 0x4001), encodeTempExtended(128.0));

    // -55 C -> count -880 = 0x1C90 in 13 bits -> word 0xE480, marker -> 0xE481
    try std.testing.expectApproxEqAbs(-55.0, decodeTempExtended(0xE481), 0.0001);
    try std.testing.expectEqual(@as(u16, 0xE481), encodeTempExtended(-55.0));

    // decode is independent of the extended bit-0 marker
    try std.testing.expectApproxEqAbs(150.0, decodeTempExtended(0x4B00), 0.0001);
}

test "extended mode clamps at 13-bit signed range" {
    try std.testing.expectEqual(@as(u16, 0x7FF9), encodeTempExtended(255.9375));
    try std.testing.expectEqual(@as(u16, 0x8001), encodeTempExtended(-256.0));
}

test "config register reset value and bit-field accessors" {
    try std.testing.expectEqual(@as(u16, 0x60A0), CONFIG_RESET);

    // Byte 1: OS R1 R0 F1 F0 POL TM SD
    try std.testing.expect(getBit(CONFIG_RESET, 14)); // R1 = 1 (12-bit)
    try std.testing.expect(getBit(CONFIG_RESET, 13)); // R0 = 1
    try std.testing.expect(!configPolarity(CONFIG_RESET));
    try std.testing.expect(!configThermostatMode(CONFIG_RESET));
    try std.testing.expect(!configShutdown(CONFIG_RESET));
    try std.testing.expect(!configExtendedMode(CONFIG_RESET));

    // Byte 2: CR1 CR0 AL EM
    try std.testing.expectEqual(@as(u2, 0b10), conversionRateField(CONFIG_RESET));
    try std.testing.expectApproxEqAbs(4.0, conversionRateHz(CONFIG_RESET), 0.0001);
    try std.testing.expect(getBit(CONFIG_RESET, 5)); // AL reads 1 when not asserted
}

test "configuration field setters and conversions" {
    var reg = CONFIG_RESET;

    reg = setBit(reg, B_SD, true);
    try std.testing.expect(configShutdown(reg));

    reg = setBit(reg, B_EM, true);
    try std.testing.expect(configExtendedMode(reg));

    reg = setBit(reg, B_POL, true);
    try std.testing.expect(configPolarity(reg));

    reg = setBit(reg, B_TM, true);
    try std.testing.expect(configThermostatMode(reg));

    // fault queue map: F1:F0 00->1 01->2 10->4 11->6
    try std.testing.expectEqual(@as(u8, 1), faultQueueCount(0x0000));
    try std.testing.expectEqual(@as(u8, 2), faultQueueCount(setBit(0, B_F0, true)));
    try std.testing.expectEqual(@as(u8, 4), faultQueueCount(setBit(0, B_F1, true)));
    try std.testing.expectEqual(@as(u8, 6), faultQueueCount(0x1800)); // F1,F0 = 11

    // conversion rate map: 00->0.25 01->1 10->4 11->8
    try std.testing.expectApproxEqAbs(0.25, conversionRateHz(0x0000), 0.0001);
    try std.testing.expectApproxEqAbs(1.0, conversionRateHz(0x0040), 0.0001);
    try std.testing.expectApproxEqAbs(4.0, conversionRateHz(0x0080), 0.0001);
    try std.testing.expectApproxEqAbs(8.0, conversionRateHz(0x00C0), 0.0001);
}

test "ADD0 address straps" {
    try std.testing.expectEqual(@as(u7, 0x48), Add0Addr.gnd);
    try std.testing.expectEqual(@as(u7, 0x49), Add0Addr.vcc);
    try std.testing.expectEqual(@as(u7, 0x4A), Add0Addr.sda);
    try std.testing.expectEqual(@as(u7, 0x4B), Add0Addr.scl);
    try std.testing.expectEqual(@as(usize, 0), try add0Index(0x48));
    try std.testing.expectEqual(@as(usize, 3), try add0Index(0x4B));
    try std.testing.expectError(error.InvalidAdd0, add0Index(0x55));
}

test "byte order helpers round-trip" {
    try std.testing.expectEqual(@as(u16, 0x6400), bytesToWord(0x64, 0x00));
    try std.testing.expectEqual([2]u8{ 0x64, 0x00 }, wordToBytes(0x6400));
}

test "signExtend of 12- and 13-bit counts" {
    try std.testing.expectEqual(@as(i16, 400), signExtend(0x190, 12));
    try std.testing.expectEqual(@as(i16, -400), signExtend(0xE70, 12));
    try std.testing.expectEqual(@as(i16, 2400), signExtend(0x960, 13));
    try std.testing.expectEqual(@as(i16, -880), signExtend(0x1C90, 13));
}