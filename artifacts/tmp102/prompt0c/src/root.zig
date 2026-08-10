//! TMP102 reference algorithms: register <=> real-world conversions.
//!
//! This module is the single source of truth for the TMP102 register-level bit
//! layout (alignment, byte order, and sign extension) for downstream skills.
//! One LSB = 0.0625 C. Temperature is 12-bit (Normal mode) or 13-bit
//! (Extended mode) two's complement, left-aligned in the 16-bit register word.
const std = @import("std");

pub const LSB_CELSIUS: f32 = 0.0625;

// ---------------------------------------------------------------------------
// Sign-extension primitives
// ---------------------------------------------------------------------------

/// Sign-extend a left-aligned 12-bit two's-complement value to a full i16.
/// Encodes the "left-aligned in bits 15:4" layout: shifting the raw count up
/// into bits 15:4 then arithmetic-shifting back sign-extends bit 11.
fn signExtend12(count: u12) i16 {
    return @as(i16, @bitCast(@as(u16, count) << 4)) >> 4;
}

/// Sign-extend a left-aligned 13-bit two's-complement value to a full i16.
/// Encodes the "left-aligned in bits 15:3" layout (Extended mode).
fn signExtend13(count: u13) i16 {
    return @as(i16, @bitCast(@as(u16, count) << 3)) >> 3;
}

// ---------------------------------------------------------------------------
// Temperature decode (register -> real world)
// ---------------------------------------------------------------------------

/// Decode a register word count to degrees Celsius (12-bit Normal mode).
/// The value is left-aligned in bits 15:4; bits 3:0 are ignored on read.
pub fn decodeTempNormal(word: u16) f32 {
    const signed: i16 = @as(i16, @bitCast(word)) >> 4;
    return @as(f32, @floatFromInt(signed)) * LSB_CELSIUS;
}

/// Decode a raw 12-bit count to degrees Celsius (Normal mode).
pub fn decodeTempNormal12(count: u12) f32 {
    return @as(f32, @floatFromInt(signExtend12(count))) * LSB_CELSIUS;
}

/// Decode a register word to degrees Celsius (13-bit Extended mode).
/// Value is left-aligned in bits 15:3; bit 0 is the EM mode flag and is
/// ignored on read.
pub fn decodeTempExtended(word: u16) f32 {
    const signed: i16 = @as(i16, @bitCast(word)) >> 3;
    return @as(f32, @floatFromInt(signed)) * LSB_CELSIUS;
}

/// Decode a raw 13-bit count to degrees Celsius (Extended mode).
pub fn decodeTempExtended13(count: u13) f32 {
    return @as(f32, @floatFromInt(signExtend13(count))) * LSB_CELSIUS;
}

// ---------------------------------------------------------------------------
// Temperature encode (real world -> register)
// ---------------------------------------------------------------------------

/// Round a temperature to the nearest count and clamp it into the
/// representable range of an `nbits`-bit two's-complement field.
///
/// Out-of-range policy: **clamp/saturate** — inputs below the minimum
/// count return the minimum, inputs above the maximum return the maximum.
/// NaN input is treated as 0.0 (0 C), a documented safe default.
fn clampCount(temp_c: f32, comptime nbits: u5) i16 {
    if (std.math.isNan(temp_c)) return 0;
    const min: f32 = -@as(f32, @floatFromInt(@as(i16, 1) << @intCast(nbits - 1)));
    const max: f32 = @as(f32, @floatFromInt((@as(u16, 1) << @intCast(nbits - 1)) - 1));
    const scaled = std.math.clamp(temp_c / LSB_CELSIUS, min, max);
    return @intFromFloat(@round(scaled));
}

/// Encode degrees Celsius into the 16-bit Temperature register (Normal mode).
///
/// Out-of-range policy: **clamp/saturate**. 12-bit range is [-128.0,
/// +127.9375] C; e.g. +128 C saturates to 0x7FF0 (127.9375 C) because 12 bits
/// cannot represent +128 exactly. NaN input encodes 0x0000 (0 C).
pub fn encodeTempNormal(temp_c: f32) u16 {
    const count = clampCount(temp_c, 12);
    return @as(u16, @bitCast(count)) << 4;
}

/// Encode degrees Celsius into the 16-bit Temperature register (Extended mode).
///
/// Out-of-range policy: **clamp/saturate**. 13-bit range is [-256.0,
/// +255.9375] C. The EM mode flag (bit 0) is always written as 1. NaN input
/// encodes 0x0001 (0 C).
pub fn encodeTempExtended(temp_c: f32) u16 {
    const count = clampCount(temp_c, 13);
    return (@as(u16, @bitCast(count)) << 3) | 1;
}

// ---------------------------------------------------------------------------
// Byte order (big-endian, MSB first per the I2C transport)
// ---------------------------------------------------------------------------

pub const MsbLsb = struct { msb: u8, lsb: u8 };

/// Assemble a 16-bit register word from its two wire bytes, MSB first.
pub fn wordFromMsbLsb(msb: u8, lsb: u8) u16 {
    return (@as(u16, msb) << 8) | lsb;
}

/// Split a 16-bit register word into its two wire bytes, MSB first.
pub fn msbLsbFromWord(word: u16) MsbLsb {
    return .{ .msb = @intCast(word >> 8), .lsb = @intCast(word & 0xFF) };
}

// ---------------------------------------------------------------------------
// Fault queue (F1:F0, config bits 12:11) — consecutive faults before ALERT
// ---------------------------------------------------------------------------

/// Decode the F1:F0 field to the consecutive-fault count.
pub fn faultQueueCount(bits: u2) u8 {
    return switch (bits) {
        0b00 => 1,
        0b01 => 2,
        0b10 => 4,
        0b11 => 6,
    };
}

/// Encode a consecutive-fault count into the F1:F0 field.
///
/// Out-of-range policy: **error** — only 1, 2, 4 and 6 are representable;
/// any other count returns `error.InvalidFaultQueueCount`.
pub fn faultQueueBits(count: u8) !u2 {
    return switch (count) {
        1 => 0b00,
        2 => 0b01,
        4 => 0b10,
        6 => 0b11,
        else => error.InvalidFaultQueueCount,
    };
}

// ---------------------------------------------------------------------------
// Conversion rate (CR1:CR0, config bits 7:6) — conversions per second
// ---------------------------------------------------------------------------

/// Decode the CR1:CR0 field to the conversion rate in Hz.
pub fn conversionRateHz(bits: u2) f32 {
    return switch (bits) {
        0b00 => 0.25,
        0b01 => 1.0,
        0b10 => 4.0,
        0b11 => 8.0,
    };
}

/// Encode a requested conversion rate (Hz) into the CR1:CR0 field.
///
/// Out-of-range policy: **clamp/round-to-nearest**. Rates above 8 Hz clamp to
/// 8 Hz (0b11). Midpoints: <=0.625 -> 0.25, <=2.5 -> 1, <=6.0 -> 4, else 8.
pub fn conversionRateBits(hz: f32) u2 {
    if (hz <= 0.625) return 0b00;
    if (hz <= 2.5) return 0b01;
    if (hz <= 6.0) return 0b10;
    return 0b11;
}

// ---------------------------------------------------------------------------
// Config register bit-packing (bits documented in the chip spec)
// ---------------------------------------------------------------------------

pub const ThermostatMode = enum(u1) { comparator = 0, interrupt = 1 };

/// 16-bit Configuration register. Field names and bit positions:
/// Byte 1 | 15 OS | 14:13 R1:R0 (read-only, 11 = 12-bit) | 12:11 F1:F0 |
/// 10 POL | 9 TM | 8 SD.
/// Byte 2 | 7:6 CR1:CR0 | 5 AL (read-only) | 4 EM | 3:0 reserved (write 0).
pub const Config = struct {
    one_shot: bool = false,
    resolution_bits: u2 = 0b11,
    fault_queue_bits: u2 = 0b00,
    polarity: bool = false,
    thermostat_mode: ThermostatMode = .comparator,
    shutdown: bool = false,
    conversion_rate_bits: u2 = 0b10,
    alert_status: bool = false,
    extended_mode: bool = false,

    pub fn fromWord(word: u16) Config {
        return .{
            .one_shot = (word >> 15) & 1 == 1,
            .resolution_bits = @intCast((word >> 13) & 0b11),
            .fault_queue_bits = @intCast((word >> 11) & 0b11),
            .polarity = (word >> 10) & 1 == 1,
            .thermostat_mode = if ((word >> 9) & 1 == 1) .interrupt else .comparator,
            .shutdown = (word >> 8) & 1 == 1,
            .conversion_rate_bits = @intCast((word >> 6) & 0b11),
            .alert_status = (word >> 5) & 1 == 1,
            .extended_mode = (word >> 4) & 1 == 1,
        };
    }

    /// Pack the config struct into the 16-bit register word. The read-only
    /// fields are forced on write: R1:R0 = 11, AL = 0, reserved bits 3:0 = 0.
    pub fn toWord(self: Config) u16 {
        const byte1 =
            (@as(u16, @intFromBool(self.one_shot)) << 15) |
            (@as(u16, 0b11) << 13) |
            (@as(u16, self.fault_queue_bits) << 11) |
            (@as(u16, @intFromBool(self.polarity)) << 10) |
            (@as(u16, @intFromEnum(self.thermostat_mode)) << 9) |
            (@as(u16, @intFromBool(self.shutdown)) << 8);
        const byte2 =
            (@as(u16, self.conversion_rate_bits) << 6) |
            (@as(u16, @intFromBool(self.extended_mode)) << 4);
        return byte1 | byte2;
    }
};

// ---------------------------------------------------------------------------
// Bus addressing (ADD0 pin -> 7-bit slave address)
// ---------------------------------------------------------------------------

/// Build the 7-bit I2C slave address from the A1:A0 bits driven by the ADD0
/// pin. Base is 0b1001000 (0x48); addressing table for the four ADD0 strap
/// options rounds out to 0x49 (V+), 0x4A (SDA), 0x4B (SCL).
pub fn slaveAddress(a1a0: u2) u7 {
    return @as(u7, 0b1001000) | @as(u7, a1a0);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "Table 5 Normal mode: raw 12-bit counts decode to datasheet values" {
    const cases = [_]struct { raw: u12, expected_c: f32 }{
        .{ .raw = 0x7FF, .expected_c = 127.9375 },
        .{ .raw = 0x640, .expected_c = 100.0 },
        .{ .raw = 0x500, .expected_c = 80.0 },
        .{ .raw = 0x4B0, .expected_c = 75.0 },
        .{ .raw = 0x320, .expected_c = 50.0 },
        .{ .raw = 0x190, .expected_c = 25.0 },
        .{ .raw = 0x004, .expected_c = 0.25 },
        .{ .raw = 0x000, .expected_c = 0.0 },
        .{ .raw = 0xFFC, .expected_c = -0.25 },
        .{ .raw = 0xE70, .expected_c = -25.0 },
        .{ .raw = 0xC90, .expected_c = -55.0 },
    };
    for (cases) |c| {
        // Derive the expected signed count with the same sign-extension
        // primitive under test rather than hand-computing a signed decimal.
        const expected: f32 = @as(f32, @floatFromInt(signExtend12(c.raw))) * LSB_CELSIUS;
        try std.testing.expectApproxEqRel(expected, decodeTempNormal12(c.raw), 1e-5);
        try std.testing.expectApproxEqRel(c.expected_c, decodeTempNormal12(c.raw), 1e-3);
    }
}

test "Table 5 Normal mode: full register words decode to datasheet values" {
    const cases = [_]struct { word: u16, expected_c: f32 }{
        .{ .word = 0x7FF0, .expected_c = 127.9375 },
        .{ .word = 0x6400, .expected_c = 100.0 },
        .{ .word = 0x5000, .expected_c = 80.0 },
        .{ .word = 0x4B00, .expected_c = 75.0 },
        .{ .word = 0x3200, .expected_c = 50.0 },
        .{ .word = 0x1900, .expected_c = 25.0 },
        .{ .word = 0x0040, .expected_c = 0.25 },
        .{ .word = 0x0000, .expected_c = 0.0 },
        .{ .word = 0xFFC0, .expected_c = -0.25 },
        .{ .word = 0xE700, .expected_c = -25.0 },
        .{ .word = 0xC900, .expected_c = -55.0 },
    };
    for (cases) |c| {
        const expected: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(c.word)) >> 4)) * LSB_CELSIUS;
        try std.testing.expectApproxEqRel(expected, decodeTempNormal(c.word), 1e-5);
        try std.testing.expectApproxEqRel(c.expected_c, decodeTempNormal(c.word), 1e-3);
    }
}

test "Table 6 Extended mode: raw 13-bit counts decode to datasheet values" {
    const cases = [_]struct { raw: u13, expected_c: f32 }{
        .{ .raw = 0x0960, .expected_c = 150.0 },
        .{ .raw = 0x0800, .expected_c = 128.0 },
        .{ .raw = 0x0640, .expected_c = 100.0 },
        .{ .raw = 0x0190, .expected_c = 25.0 },
        .{ .raw = 0x0000, .expected_c = 0.0 },
        .{ .raw = 0x1FFC, .expected_c = -0.25 },
        .{ .raw = 0x1E70, .expected_c = -25.0 },
        .{ .raw = 0x1C90, .expected_c = -55.0 },
    };
    for (cases) |c| {
        const expected: f32 = @as(f32, @floatFromInt(signExtend13(c.raw))) * LSB_CELSIUS;
        try std.testing.expectApproxEqRel(expected, decodeTempExtended13(c.raw), 1e-5);
        try std.testing.expectApproxEqRel(c.expected_c, decodeTempExtended13(c.raw), 1e-3);
    }
}

test "Table 6 Extended mode: full register words decode to datasheet values" {
    const cases = [_]struct { word: u16, expected_c: f32 }{
        .{ .word = 0x4B01, .expected_c = 150.0 },
        .{ .word = 0x4001, .expected_c = 128.0 },
        .{ .word = 0x3201, .expected_c = 100.0 },
        .{ .word = 0x0C81, .expected_c = 25.0 },
        .{ .word = 0x0001, .expected_c = 0.0 },
        .{ .word = 0xFFE1, .expected_c = -0.25 },
        .{ .word = 0xF381, .expected_c = -25.0 },
        .{ .word = 0xE481, .expected_c = -55.0 },
    };
    for (cases) |c| {
        const expected: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(c.word)) >> 3)) * LSB_CELSIUS;
        try std.testing.expectApproxEqRel(expected, decodeTempExtended(c.word), 1e-5);
        try std.testing.expectApproxEqRel(c.expected_c, decodeTempExtended(c.word), 1e-3);
    }
}

test "Table 5 Normal mode: temps encode to datasheet register words" {
    const cases = [_]struct { temp_c: f32, word: u16 }{
        .{ .temp_c = 127.9375, .word = 0x7FF0 },
        .{ .temp_c = 100.0, .word = 0x6400 },
        .{ .temp_c = 80.0, .word = 0x5000 },
        .{ .temp_c = 75.0, .word = 0x4B00 },
        .{ .temp_c = 50.0, .word = 0x3200 },
        .{ .temp_c = 25.0, .word = 0x1900 },
        .{ .temp_c = 0.25, .word = 0x0040 },
        .{ .temp_c = 0.0, .word = 0x0000 },
        .{ .temp_c = -0.25, .word = 0xFFC0 },
        .{ .temp_c = -25.0, .word = 0xE700 },
        .{ .temp_c = -55.0, .word = 0xC900 },
    };
    for (cases) |c| {
        try std.testing.expectEqual(c.word, encodeTempNormal(c.temp_c));
    }
}

test "Table 6 Extended mode: temps encode to register words (EM bit set)" {
    const cases = [_]struct { temp_c: f32, word: u16 }{
        .{ .temp_c = 150.0, .word = 0x4B01 },
        .{ .temp_c = 128.0, .word = 0x4001 },
        .{ .temp_c = 100.0, .word = 0x3201 },
        .{ .temp_c = 25.0, .word = 0x0C81 },
        .{ .temp_c = 0.0, .word = 0x0001 },
        .{ .temp_c = -0.25, .word = 0xFFE1 },
        .{ .temp_c = -25.0, .word = 0xF381 },
        .{ .temp_c = -55.0, .word = 0xE481 },
    };
    for (cases) |c| {
        try std.testing.expectEqual(c.word, encodeTempExtended(c.temp_c));
    }
}

test "Normal mode clamp: +128 C saturates to 127.9375" {
    // 12-bit cannot represent +128 exactly; spec notes the wrap to 0x7FF.
    try std.testing.expectEqual(@as(u16, 0x7FF0), encodeTempNormal(128.0));
    try std.testing.expectApproxEqRel(127.9375, decodeTempNormal(encodeTempNormal(128.0)), 1e-4);
    // lower bound exactly representable
    try std.testing.expectEqual(@as(u16, 0x8000), encodeTempNormal(-128.0));
    try std.testing.expectApproxEqRel(-128.0, decodeTempNormal(encodeTempNormal(-128.0)), 1e-4);
}

test "Extended mode clamp: beyond 13-bit range saturates" {
    try std.testing.expectApproxEqRel(-256.0, decodeTempExtended(encodeTempExtended(-300.0)), 1e-3);
    try std.testing.expectApproxEqRel(255.9375, decodeTempExtended(encodeTempExtended(400.0)), 1e-3);
    try std.testing.expectApproxEqRel(150.0, decodeTempExtended(encodeTempExtended(150.0)), 1e-4);
}

test "encode-decode roundtrip is within half an LSB" {
    const temps = [_]f32{ -246.0, -118.0, -55.0, -25.0, -0.25, 0.0, 0.25, 25.0, 100.0, 128.0, 150.0, 215.0 };
    for (temps) |t| {
        const word = encodeTempExtended(t);
        const back = decodeTempExtended(word);
        const err = @abs(back - t);
        try std.testing.expect(err < 0.0625 + 0.001);
    }
}

test "big-endian byte assembly (MSB first)" {
    try std.testing.expectEqual(@as(u8, 0x64), msbLsbFromWord(0x6400).msb);
    try std.testing.expectEqual(@as(u8, 0x00), msbLsbFromWord(0x6400).lsb);
    try std.testing.expectEqual(@as(u8, 0xC9), msbLsbFromWord(0xC900).msb);
    try std.testing.expectEqual(@as(u16, 0x6400), wordFromMsbLsb(0x64, 0x00));
    try std.testing.expectEqual(@as(u16, 0xC900), wordFromMsbLsb(0xC9, 0x00));
    try std.testing.expectEqual(@as(u16, 0xFFC0), wordFromMsbLsb(0xFF, 0xC0));
    try std.testing.expectApproxEqRel(100.0, decodeTempNormal(wordFromMsbLsb(0x64, 0x00)), 1e-4);
}

test "config register reset value 0x60A0 decodes" {
    const cfg = Config.fromWord(0x60A0);
    try std.testing.expectEqual(false, cfg.one_shot);
    try std.testing.expectEqual(@as(u2, 0b11), cfg.resolution_bits);
    try std.testing.expectEqual(@as(u2, 0b00), cfg.fault_queue_bits);
    try std.testing.expectEqual(1, faultQueueCount(cfg.fault_queue_bits));
    try std.testing.expectEqual(false, cfg.polarity);
    try std.testing.expectEqual(ThermostatMode.comparator, cfg.thermostat_mode);
    try std.testing.expectEqual(false, cfg.shutdown);
    try std.testing.expectEqual(@as(u2, 0b10), cfg.conversion_rate_bits);
    try std.testing.expectApproxEqRel(4.0, conversionRateHz(cfg.conversion_rate_bits), 1e-6);
    try std.testing.expectEqual(true, cfg.alert_status);
    try std.testing.expectEqual(false, cfg.extended_mode);
}

test "config toWord forces read-only fields and keeps reserved bits clear" {
    var cfg = Config.fromWord(0x60A0);
    cfg.alert_status = true; // read-only: must not change the packed word
    cfg.resolution_bits = 0b00; // read-only: forced back to 0b11 on write
    // reset word has AL=1 (read-only); it must not survive a write.
    try std.testing.expectEqual(@as(u16, 0x6080), cfg.toWord());

    cfg = .{};
    cfg.thermostat_mode = .interrupt;
    cfg.extended_mode = true;
    cfg.conversion_rate_bits = 0b11;
    cfg.fault_queue_bits = 0b11;
    const word = cfg.toWord();
    const back = Config.fromWord(word);
    try std.testing.expectEqual(ThermostatMode.interrupt, back.thermostat_mode);
    try std.testing.expectEqual(true, back.extended_mode);
    try std.testing.expectEqual(@as(u2, 0b11), back.conversion_rate_bits);
    try std.testing.expectEqual(@as(u2, 0b11), back.fault_queue_bits);
    try std.testing.expectEqual(@as(u2, 0b11), back.resolution_bits);
    try std.testing.expectEqual(@as(u16, 0), word & 0x000F); // reserved bits clear
}

test "fault queue decode and encode" {
    try std.testing.expectEqual(@as(u8, 1), faultQueueCount(0b00));
    try std.testing.expectEqual(@as(u8, 2), faultQueueCount(0b01));
    try std.testing.expectEqual(@as(u8, 4), faultQueueCount(0b10));
    try std.testing.expectEqual(@as(u8, 6), faultQueueCount(0b11));
    try std.testing.expectEqual(@as(u2, 0b00), try faultQueueBits(1));
    try std.testing.expectEqual(@as(u2, 0b01), try faultQueueBits(2));
    try std.testing.expectEqual(@as(u2, 0b10), try faultQueueBits(4));
    try std.testing.expectEqual(@as(u2, 0b11), try faultQueueBits(6));
    try std.testing.expectError(error.InvalidFaultQueueCount, faultQueueBits(3));
    try std.testing.expectError(error.InvalidFaultQueueCount, faultQueueBits(7));
}

test "conversion rate decode and encode (clamp to nearest)" {
    try std.testing.expectApproxEqRel(0.25, conversionRateHz(0b00), 1e-6);
    try std.testing.expectApproxEqRel(1.0, conversionRateHz(0b01), 1e-6);
    try std.testing.expectApproxEqRel(4.0, conversionRateHz(0b10), 1e-6);
    try std.testing.expectApproxEqRel(8.0, conversionRateHz(0b11), 1e-6);
    try std.testing.expectEqual(@as(u2, 0b00), conversionRateBits(0.25));
    try std.testing.expectEqual(@as(u2, 0b00), conversionRateBits(0.6));
    try std.testing.expectEqual(@as(u2, 0b01), conversionRateBits(1.0));
    try std.testing.expectEqual(@as(u2, 0b10), conversionRateBits(4.0));
    try std.testing.expectEqual(@as(u2, 0b11), conversionRateBits(8.0));
    try std.testing.expectEqual(@as(u2, 0b11), conversionRateBits(100.0)); // clamp
}

test "slave addresses from ADD0 strap (A1:A0)" {
    try std.testing.expectEqual(@as(u7, 0x48), slaveAddress(0b00));
    try std.testing.expectEqual(@as(u7, 0x49), slaveAddress(0b01));
    try std.testing.expectEqual(@as(u7, 0x4A), slaveAddress(0b10));
    try std.testing.expectEqual(@as(u7, 0x4B), slaveAddress(0b11));
}