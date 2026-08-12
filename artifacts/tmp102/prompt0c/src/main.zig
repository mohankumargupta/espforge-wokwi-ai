const std = @import("std");

// TMP102 data conversion functions and reference algorithms.
// Reference: Texas Instruments TMP102 datasheet, 12-bit (Normal) and 13-bit
// (Extended) temperature formats. All temperature registers (Temperature,
// TLOW, THIGH) share the same two's-complement, left-aligned layout.

const LSB_CELSIUS: f32 = 0.0625;

// ---- decode primitives -----------------------------------------------------

/// Interpret a `bits`-wide two's-complement field (held in the low bits of
/// `value`) as a signed integer, sign-extended to i16.
///
/// This is the single sign-extension primitive used by every temperature
/// decode path. All worked-example tests derive their expected signed counts
/// through this function rather than by hand-computing a signed decimal.
pub fn signExtend(value: u16, comptime bits: u5) i16 {
    const shift: u5 = 16 - bits;
    return @as(i16, @bitCast(value << shift)) >> shift;
}

/// Decode a Normal-mode (12-bit) temperature register word.
/// Data occupies bits 15:4; bits 3:0 are ignored (always 0 in Normal mode).
pub fn decodeCount12(word: u16) i16 {
    return signExtend(word >> 4, 12);
}

/// Decode an Extended-mode (13-bit) temperature register word.
/// Data occupies bits 15:3; bit 0 is the EM format flag (ignored here).
pub fn decodeCount13(word: u16) i16 {
    return signExtend(word >> 3, 13);
}

/// Decode a temperature register word using the caller-chosen mode.
pub fn decodeCount(word: u16, extended: bool) i16 {
    return if (extended) decodeCount13(word) else decodeCount12(word);
}

/// Convert a signed two's-complement count to degrees Celsius (0.0625 °C/LSB).
pub fn countToCelsius(count: i16) f32 {
    return @as(f32, @floatFromInt(count)) * LSB_CELSIUS;
}

pub const Decoded = struct {
    celsius: f32,
    extended: bool,
};

/// Decode a temperature register word, auto-detecting the data format from
/// the Extended-mode flag (bit 0 of the word: 0 = Normal/12-bit, 1 = Extended/13-bit).
pub fn wordToCelsius(word: u16) Decoded {
    const extended = (word & 0x0001) != 0;
    const count = decodeCount(word, extended);
    return .{ .celsius = countToCelsius(count), .extended = extended };
}

// ---- encode functions ------------------------------------------------------
//
// Out-of-range policy for every encode function below: **clamp/saturate** to
// the nearest representable value. Inputs above/below the representable range
// are saturated to the max/min register code rather than wrapping or erroring.
// This matches the datasheet note that +128 °C cannot be represented in the
// 12-bit format (it saturates to 127.9375 °C).

const min_c12: f32 = -2048.0 * LSB_CELSIUS; // -128.0
const max_c12: f32 = 2047.0 * LSB_CELSIUS; // +127.9375
const min_c13: f32 = -4096.0 * LSB_CELSIUS; // -256.0
const max_c13: f32 = 4095.0 * LSB_CELSIUS; // +255.9375

/// Encode degrees Celsius into a Normal-mode (12-bit) temperature register
/// word (bits 15:4 = count, bits 3:0 = 0). Clamps to [-128.0, +127.9375].
pub fn celsiusToWord12(celsius: f32) u16 {
    const clamped = std.math.clamp(celsius, min_c12, max_c12);
    const count: i32 = @intFromFloat(@round(clamped / LSB_CELSIUS));
    const raw: u12 = @truncate(@as(u32, @bitCast(count)));
    return @as(u16, raw) << 4;
}

/// Encode degrees Celsius into an Extended-mode (13-bit) temperature register
/// word (bits 15:3 = count, bit 0 = 1 EM flag). Clamps to [-256.0, +255.9375].
pub fn celsiusToWord13(celsius: f32) u16 {
    const clamped = std.math.clamp(celsius, min_c13, max_c13);
    const count: i32 = @intFromFloat(@round(clamped / LSB_CELSIUS));
    const raw: u13 = @truncate(@as(u32, @bitCast(count)));
    return (@as(u16, raw) << 3) | 0x0001;
}

// ---- Configuration register decoders ---------------------------------------

/// Decode the CR1:CR0 field (Configuration bits 7:6, byte 2 LSB) to a
/// conversion rate in Hz.
pub fn conversionRateHz(config: u16) f32 {
    return switch ((config >> 6) & 0b11) {
        0b00 => 0.25,
        0b01 => 1.0,
        0b10 => 4.0,
        0b11 => 8.0,
        else => unreachable,
    };
}

/// Decode the F1:F0 field (Configuration bits 12:11) to the consecutive-fault
/// count required before ALERT asserts.
pub fn faultQueueCount(config: u16) u8 {
    return switch ((config >> 11) & 0b11) {
        0b00 => 1,
        0b01 => 2,
        0b10 => 4,
        0b11 => 6,
        else => unreachable,
    };
}

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("tmp102 conversion library built (zig 0.16). Run `zig build test` to run unit tests.\n", .{});
}

// ---- tests -----------------------------------------------------------------

test "signExtend primitive" {
    try std.testing.expectEqual(@as(i16, 800), signExtend(0x320, 12));
    try std.testing.expectEqual(@as(i16, -400), signExtend(0xE70, 12));
    try std.testing.expectEqual(@as(i16, -4), signExtend(0xFFC, 12));
    try std.testing.expectEqual(@as(i16, 2047), signExtend(0x7FF, 12));
    try std.testing.expectEqual(@as(i16, -2048), signExtend(0x800, 12));
    try std.testing.expectEqual(@as(i16, 400), signExtend(0x190, 13));
    try std.testing.expectEqual(@as(i16, -400), signExtend(0x1E70, 13));
    try std.testing.expectEqual(@as(i16, 4095), signExtend(0xFFF, 13));
    try std.testing.expectEqual(@as(i16, -4096), signExtend(0x1000, 13));
}

test "decodeCount12 spec worked examples (Normal 12-bit)" {
    // Expected signed counts are derived by calling the sign-extend primitive
    // on the raw 12-bit count from the spec table, not hand-computed.
    try std.testing.expectEqual(signExtend(0x7FF, 12), decodeCount12(0x7FF0));
    try std.testing.expectEqual(signExtend(0x640, 12), decodeCount12(0x6400));
    try std.testing.expectEqual(signExtend(0x500, 12), decodeCount12(0x5000));
    try std.testing.expectEqual(signExtend(0x4B0, 12), decodeCount12(0x4B00));
    try std.testing.expectEqual(signExtend(0x320, 12), decodeCount12(0x3200));
    try std.testing.expectEqual(signExtend(0x190, 12), decodeCount12(0x1900));
    try std.testing.expectEqual(signExtend(0x004, 12), decodeCount12(0x0040));
    try std.testing.expectEqual(signExtend(0x000, 12), decodeCount12(0x0000));
    try std.testing.expectEqual(signExtend(0xFFC, 12), decodeCount12(0xFFC0));
    try std.testing.expectEqual(signExtend(0xE70, 12), decodeCount12(0xE700));
    try std.testing.expectEqual(signExtend(0xC90, 12), decodeCount12(0xC900));
}

test "decodeCount13 spec worked examples (Extended 13-bit)" {
    // Word = raw 13-bit count left-aligned in bits 15:3, bit 0 = 1 (EM flag).
    try std.testing.expectEqual(signExtend(0x0960, 13), decodeCount13(0x4B01));
    try std.testing.expectEqual(signExtend(0x0800, 13), decodeCount13((@as(u16, 0x0800) << 3) | 0x0001));
    try std.testing.expectEqual(signExtend(0x0640, 13), decodeCount13((@as(u16, 0x0640) << 3) | 0x0001));
    try std.testing.expectEqual(signExtend(0x0190, 13), decodeCount13((@as(u16, 0x0190) << 3) | 0x0001));
    try std.testing.expectEqual(signExtend(0x0000, 13), decodeCount13(0x0001));
    try std.testing.expectEqual(signExtend(0x1FFC, 13), decodeCount13((@as(u16, 0x1FFC) << 3) | 0x0001));
    try std.testing.expectEqual(signExtend(0x1E70, 13), decodeCount13((@as(u16, 0x1E70) << 3) | 0x0001));
    try std.testing.expectEqual(signExtend(0x1C90, 13), decodeCount13((@as(u16, 0x1C90) << 3) | 0x0001));
}

test "countToCelsius scale" {
    try std.testing.expectApproxEqAbs(50.0, countToCelsius(800), 0.0001);
    try std.testing.expectApproxEqAbs(-25.0, countToCelsius(-400), 0.0001);
    try std.testing.expectApproxEqAbs(0.25, countToCelsius(4), 0.0001);
    try std.testing.expectApproxEqAbs(-0.25, countToCelsius(-4), 0.0001);
    try std.testing.expectApproxEqAbs(127.9375, countToCelsius(2047), 0.0001);
    try std.testing.expectApproxEqAbs(0.0, countToCelsius(0), 0.0001);
}

test "wordToCelsius spec worked examples with mode auto-detection" {
    try std.testing.expectApproxEqAbs(100.0, wordToCelsius(0x6400).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(80.0, wordToCelsius(0x5000).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(75.0, wordToCelsius(0x4B00).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(50.0, wordToCelsius(0x3200).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(25.0, wordToCelsius(0x1900).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(0.25, wordToCelsius(0x0040).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(-0.25, wordToCelsius(0xFFC0).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(-25.0, wordToCelsius(0xE700).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(-55.0, wordToCelsius(0xC900).celsius, 0.0001);
    // +128 in 12-bit saturates to 127.9375 (spec note)
    try std.testing.expectApproxEqAbs(127.9375, wordToCelsius(0x7FF0).celsius, 0.0001);
    try std.testing.expectApproxEqAbs(150.0, wordToCelsius(0x4B01).celsius, 0.0001);
    // EM flag detection
    try std.testing.expectEqual(false, wordToCelsius(0x3200).extended);
    try std.testing.expectEqual(true, wordToCelsius(0x4B01).extended);
}

test "celsiusToWord12 spec worked examples" {
    try std.testing.expectEqual(@as(u16, 0x7FF0), celsiusToWord12(127.9375));
    try std.testing.expectEqual(@as(u16, 0x6400), celsiusToWord12(100.0));
    try std.testing.expectEqual(@as(u16, 0x5000), celsiusToWord12(80.0));
    try std.testing.expectEqual(@as(u16, 0x4B00), celsiusToWord12(75.0));
    try std.testing.expectEqual(@as(u16, 0x3200), celsiusToWord12(50.0));
    try std.testing.expectEqual(@as(u16, 0x1900), celsiusToWord12(25.0));
    try std.testing.expectEqual(@as(u16, 0x0040), celsiusToWord12(0.25));
    try std.testing.expectEqual(@as(u16, 0x0000), celsiusToWord12(0.0));
    try std.testing.expectEqual(@as(u16, 0xFFC0), celsiusToWord12(-0.25));
    try std.testing.expectEqual(@as(u16, 0xE700), celsiusToWord12(-25.0));
    try std.testing.expectEqual(@as(u16, 0xC900), celsiusToWord12(-55.0));
    // +128 cannot be represented in 12-bit -> saturates to 127.9375
    try std.testing.expectEqual(@as(u16, 0x7FF0), celsiusToWord12(128.0));
}

test "celsiusToWord12 out-of-range clamps" {
    try std.testing.expectEqual(@as(u16, 0x8000), celsiusToWord12(-200.0));
    try std.testing.expectEqual(@as(u16, 0x7FF0), celsiusToWord12(200.0));
}

test "celsiusToWord13 spec worked examples" {
    try std.testing.expectEqual(@as(u16, 0x4B01), celsiusToWord13(150.0));
    try std.testing.expectEqual(@as(u16, 0x4001), celsiusToWord13(128.0));
    try std.testing.expectEqual(@as(u16, 0x0C81), celsiusToWord13(25.0));
    try std.testing.expectEqual(@as(u16, 0x0001), celsiusToWord13(0.0));
    try std.testing.expectEqual(@as(u16, 0xFFE1), celsiusToWord13(-0.25));
    try std.testing.expectEqual(@as(u16, 0xF381), celsiusToWord13(-25.0));
    try std.testing.expectEqual(@as(u16, 0xE481), celsiusToWord13(-55.0));
}

test "celsiusToWord13 out-of-range clamps" {
    try std.testing.expectEqual(@as(u16, 0x7FF9), celsiusToWord13(300.0));
    try std.testing.expectEqual(@as(u16, 0x8001), celsiusToWord13(-300.0));
}

test "round trip 12-bit over all codes" {
    var raw: u16 = 0;
    while (raw < 0x1000) : (raw += 1) {
        const word = raw << 4;
        const d = wordToCelsius(word);
        try std.testing.expectEqual(false, d.extended);
        try std.testing.expectEqual(word, celsiusToWord12(d.celsius));
    }
}

test "round trip 13-bit over all codes" {
    var raw: u16 = 0;
    while (raw < 0x2000) : (raw += 1) {
        const word = (raw << 3) | 0x0001;
        const d = wordToCelsius(word);
        try std.testing.expectEqual(true, d.extended);
        try std.testing.expectEqual(word, celsiusToWord13(d.celsius));
    }
}

test "conversionRateHz decoding" {
    // Reset config 0x60A0: byte 2 = 0xA0 -> CR1:CR0 = 10 -> 4 Hz default
    try std.testing.expectApproxEqAbs(4.0, conversionRateHz(0x60A0), 0.001);
    try std.testing.expectApproxEqAbs(0.25, conversionRateHz(0x0000), 0.001);
    try std.testing.expectApproxEqAbs(1.0, conversionRateHz(0x0040), 0.001);
    try std.testing.expectApproxEqAbs(4.0, conversionRateHz(0x0080), 0.001);
    try std.testing.expectApproxEqAbs(8.0, conversionRateHz(0x00C0), 0.001);
}

test "faultQueueCount decoding" {
    // Reset config 0x60A0: F1:F0 = 00 -> 1 fault
    try std.testing.expectEqual(@as(u8, 1), faultQueueCount(0x60A0));
    try std.testing.expectEqual(@as(u8, 1), faultQueueCount(0x0000));
    try std.testing.expectEqual(@as(u8, 2), faultQueueCount(0x0800));
    try std.testing.expectEqual(@as(u8, 4), faultQueueCount(0x1000));
    try std.testing.expectEqual(@as(u8, 6), faultQueueCount(0x1800));
}
