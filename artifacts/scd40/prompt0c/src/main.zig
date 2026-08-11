//! Data conversion functions and reference algorithms for the SCD40 CO2 sensor.
//!
//! Source of truth: artifacts/scd40/outputs/spec_scd40.md
//!
//! Bus domain model: each command carries 16-bit data words, transmitted
//! MSB-first (big-endian). Every payload data word is followed by a CRC-8
//! checksum. A raw 16-bit count IS the full register word (bits 15:0), no
//! alignment or shifting.
//!
//! Rounding policy for every real-world -> raw encoder: round to nearest
//! (half away from zero) then saturate to the [0, 0xffff] register range.
//! Exceptions are documented individually (see `serialToRaw` which returns an
//! error instead of saturating).

const std = @import("std");
const Io = std.Io;

// ---------------------------------------------------------------------------
// Linear scaling constants (from spec "Data Conversion")
// ---------------------------------------------------------------------------

const ZERO_POINT_TEMP_C: f64 = -45.0; // T[°C] = -45 + 175 * word / 65535
const TEMP_SPAN_C: f64 = 175.0;
const FULL_SCALE: f64 = 65535.0;
const RH_FULL_SCALE_PERCENT: f64 = 100.0;
const PA_PER_COUNT: u32 = 100; // ambient pressure[Pa] = word * 100
const FRC_ZERO_POINT: i32 = 0x8000; // FRC correction[ppm] = word - 0x8000

const MAX_CO2_PPM: u16 = 40000; // datasheet CO2 output range
const TEMP_UNIT_STEP_C: f64 = TEMP_SPAN_C / FULL_SCALE; // ~0.00267 °C / count
const RH_UNIT_STEP_PERCENT: f64 = RH_FULL_SCALE_PERCENT / FULL_SCALE;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Round a scaled value to the nearest integer count and clamp into the
/// representable 16-bit register range [0, 0xffff].
/// Out-of-range policy: saturate (below 0 -> 0x0000, above 65535 -> 0xffff).
fn quantize(value: f64) u16 {
    const r = @round(value);
    if (r >= FULL_SCALE) return 0xffff;
    if (r <= 0.0) return 0;
    return @intFromFloat(r);
}

// ---------------------------------------------------------------------------
// CRC-8 (Sensirion protocol checksum)
// ---------------------------------------------------------------------------

/// CRC-8 as used by every SCD4x data word: polynomial 0x31
/// (x^8 + x^5 + x^4 + 1), initial value 0xFF, no reflection, no final XOR.
/// Covers only the data bytes of the word it protects (command words carry no
/// CRC). Verified against datasheet Table 40: `crc8Word(0xbeef) == 0x92`.
pub fn crc8(data: []const u8) u8 {
    var crc: u8 = 0xff;
    for (data) |byte| {
        crc ^= byte;
        for (0..8) |_| {
            crc = if (crc & 0x80 != 0) (crc << 1) ^ 0x31 else crc << 1;
        }
    }
    return crc;
}

/// CRC-8 over the two big-endian bytes of a 16-bit data word.
pub fn crc8Word(word: u16) u8 {
    return crc8(&.{ @intCast(word >> 8), @intCast(word & 0xff) });
}

// ---------------------------------------------------------------------------
// read_measurement (0xec05): CO2 / temperature / humidity
// ---------------------------------------------------------------------------

/// Encode a CO2 concentration (ppm) into its raw 16-bit count.
/// The raw count IS the value (identity mapping, full 16-bit word).
/// Out-of-range policy: saturate — values outside [0, 0xffff] clamp to the
/// nearest representable count (datasheet range is 0..40000 ppm, always in
/// range for a u16 input).
pub fn co2ToRaw(ppm: u16) u16 {
    return ppm;
}

/// Decode a raw 16-bit count to CO2 concentration (ppm). Identity mapping.
pub fn co2FromRaw(word: u16) u16 {
    return word;
}

/// Decode a raw temperature count to °C: `T = -45 + 175 * word / 65535`.
/// Raw 25.0 °C example: word[1] = 0x6667 (26215) -> 25.00019 °C.
pub fn tempFromRaw(word: u16) f64 {
    return ZERO_POINT_TEMP_C + TEMP_SPAN_C * @as(f64, word) / FULL_SCALE;
}

/// Encode a temperature (°C) into its raw 16-bit count.
/// Inverse of `tempFromRaw`. Round-to-nearest + saturate; the representable
/// span is -45..130 °C, so inputs below -45 -> 0x0000 and above 130 -> 0xffff.
/// Note: the datasheet worked example picks 0x6667 (=26215) for exactly 25.0 °C;
/// this encoder yields 26214 for 25.0 °C because 25.0 °C is not exactly
/// representable (both counts decode to 25.0 within a display rounding of 0.3 m°C).
pub fn tempToRaw(temp_c: f64) u16 {
    return quantize((temp_c - ZERO_POINT_TEMP_C) * FULL_SCALE / TEMP_SPAN_C);
}

/// Decode a raw humidity count to percent RH: `RH = 100 * word / 65535`.
/// Raw 37.0 % example: word[2] = 0x5eb9 (24249) -> 37.0012 %RH.
pub fn rhFromRaw(word: u16) f64 {
    return RH_FULL_SCALE_PERCENT * @as(f64, word) / FULL_SCALE;
}

/// Encode a percent-RH value into its raw 16-bit count.
/// Inverse of `rhFromRaw`. Round-to-nearest + saturate; input range is
/// 0..100 %RH, outside it clamps to 0x0000 / 0xffff.
/// Note: 37.0 % maps to 24248 here vs the datasheet's 24249 — both decode to
/// 37.0 within one display decimal.
pub fn rhToRaw(rh_percent: f64) u16 {
    return quantize(rh_percent * FULL_SCALE / RH_FULL_SCALE_PERCENT);
}

// ---------------------------------------------------------------------------
// Temperature offset (set/get_temperature_offset, 0x241d / 0x2318)
// ---------------------------------------------------------------------------

/// Decode a raw temperature-offset count to °C: `offset = word * 175 / 65535`.
/// Raw 6.2 °C example: 0x0912 (2322) -> 6.20004 °C.
pub fn tempOffsetFromRaw(word: u16) f64 {
    return TEMP_SPAN_C * @as(f64, word) / FULL_SCALE;
}

/// Encode a temperature offset (°C) into its raw 16-bit count.
/// Round-to-nearest + saturate; span is 0..175 °C, outside it clamps to
/// 0x0000 / 0xffff.
pub fn tempOffsetToRaw(offset_c: f64) u16 {
    return quantize(offset_c * FULL_SCALE / TEMP_SPAN_C);
}

// ---------------------------------------------------------------------------
// Sensor altitude (set/get_sensor_altitude, 0x2427 / 0x2322)
// ---------------------------------------------------------------------------

/// Decode a raw sensor-altitude count to meters: identity mapping.
/// Raw 1100 m example: 0x044c -> 1100; raw 1950 m: 0x079e -> 1950.
pub fn altitudeFromRaw(word: u16) u16 {
    return word;
}

/// Encode an altitude (m) into its raw 16-bit count. Identity mapping.
/// Out-of-range policy: saturate — values above 0xffff clamp to 0xffff.
pub fn altitudeToRaw(meters: u16) u16 {
    return meters;
}

// ---------------------------------------------------------------------------
// Ambient pressure (set/get_ambient_pressure, 0xe000)
// ---------------------------------------------------------------------------

/// Decode a raw pressure count to Pa: `pressure[Pa] = word * 100`.
/// Raw 987 (0x03db) -> 98700 Pa.
pub fn pressureFromRaw(word: u16) u32 {
    return @as(u32, word) * PA_PER_COUNT;
}

/// Encode a pressure (Pa) into its raw 16-bit count: `word = round(Pa / 100)`.
/// Inverse of `pressureFromRaw` to within 50 Pa. Round-to-nearest (half away
/// from zero), then saturate — >0xffff clamps to 0xffff.
pub fn pressureToRaw(pa: u32) u16 {
    return quantize(@as(f64, pa) / @as(f64, PA_PER_COUNT));
}

// ---------------------------------------------------------------------------
// Perform forced recalibration (0x362f): target input + correction result
// ---------------------------------------------------------------------------

/// Decode the FRC correction result: the returned word is a signed
/// two's-complement offset centered at 0x8000: `correction[ppm] = word - 0x8000`.
/// Raw -50 ppm example: 0x7fce -> -50.
pub fn frcCorrectionFromRaw(word: u16) i32 {
    return @as(i32, word) - FRC_ZERO_POINT;
}

/// True when the FRC word is the datasheet "FRC failed" sentinel 0xffff.
pub fn frcFailed(word: u16) bool {
    return word == 0xffff;
}

/// Encode an FRC target CO2 concentration (ppm) for the write side of
/// perform_forced_recalibration: identity mapping. Raw 480 ppm: 0x01e0.
pub fn frcTargetToRaw(ppm: u16) u16 {
    return ppm;
}

// ---------------------------------------------------------------------------
// ASC enable flag (set/get_automatic_self_calibration_enabled, 0x2416 / 0x2313)
// ---------------------------------------------------------------------------

/// Decode ASC enable: raw 0x0001 -> enabled, 0x0000 -> disabled.
/// Per datasheet any non-zero word means enabled, but the documented values
/// are exactly 0x0000 / 0x0001.
pub fn ascEnabledFromRaw(word: u16) bool {
    return word != 0;
}

/// Encode ASC enable: true -> 0x0001, false -> 0x0000.
pub fn ascEnabledToRaw(enabled: bool) u16 {
    return if (enabled) 0x0001 else 0x0000;
}

// ---------------------------------------------------------------------------
// ASC target (set/get_automatic_self_calibration_target, 0x243a / 0x233f)
// ---------------------------------------------------------------------------

/// Decode the ASC target CO2 concentration (ppm): identity mapping.
/// Raw 435 ppm: 0x01b3; raw 420 ppm: 0x01a4.
pub fn ascTargetFromRaw(word: u16) u16 {
    return word;
}

/// Encode the ASC target CO2 concentration (ppm): identity mapping.
pub fn ascTargetToRaw(ppm: u16) u16 {
    return ppm;
}

// ---------------------------------------------------------------------------
// ASC periods (set/get_..._initial/standard_period, 0x2445 / 0x2340 / 0x244e / 0x234b)
// ---------------------------------------------------------------------------

/// Decode an ASC period word to hours: identity mapping.
/// Raw 76 h: 0x004c; raw 156 h: 0x009c.
pub fn ascPeriodFromRaw(word: u16) u16 {
    return word;
}

/// Encode an ASC period (hours) into its raw 16-bit count: identity mapping.
pub fn ascPeriodToRaw(hours: u16) u16 {
    return hours;
}

// ---------------------------------------------------------------------------
// Serial number (get_serial_number, 0x3682)
// ---------------------------------------------------------------------------

/// The three 16-bit data words returned by get_serial_number (48 bits total).
pub const SerialWords = struct {
    w0: u16,
    w1: u16,
    w2: u16,
};

pub const SerialNumberError = error{ OutOfRange };

/// Decode a serial number from three big-endian words to a 48-bit integer:
/// `sn = w0 << 32 | w1 << 16 | w2`. Fits in u64 (max 0xFFFF_FFFF_FFFF).
pub fn serialFromRaw(w0: u16, w1: u16, w2: u16) u64 {
    return (@as(u64, w0) << 32) | (@as(u64, w1) << 16) | @as(u64, w2);
}

/// Encode a 48-bit serial number into three big-endian words.
/// Out-of-range policy: error — any value outside [0, 0xFFFF_FFFF_FFFF]
/// cannot be represented, so return `error.OutOfRange` rather than silently
/// truncating (a truncated serial would corrupt the device identity).
pub fn serialToRaw(value: u64) SerialNumberError!SerialWords {
    if (value > 0xffff_ffff_ffff) return error.OutOfRange;
    return .{
        .w0 = @intCast(value >> 32),
        .w1 = @intCast((value >> 16) & 0xffff),
        .w2 = @intCast(value & 0xffff),
    };
}

// ---------------------------------------------------------------------------
// get_data_ready_status (0xe4b8)
// ---------------------------------------------------------------------------

/// Decode data-ready status: bits 10:0 hold the DATA_READY flag; any
/// non-zero value means data is ready. Higher bits (11..15) are ignored.
/// Raw 0x8000 (LSB 11 bits = 0) -> not ready.
pub fn dataReady(word: u16) bool {
    return (word & 0x07ff) != 0;
}

// ---------------------------------------------------------------------------
// get_sensor_variant (0x202f)
// ---------------------------------------------------------------------------

/// Sensor variant decoded from bits 15:12 of the response word.
pub const Variant = enum {
    scd40,
    scd41,
    scd43,
    unknown,
};

/// Decode the sensor variant from response word bits 15:12.
/// 0 -> SCD40, 1 -> SCD41, 5 -> SCD43, anything else -> unknown.
/// Raw 0x0440 / 0x1440 / 0x5441 decode to scd40 / scd41 / scd43.
pub fn variantFromRaw(word: u16) Variant {
    return switch (word >> 12) {
        0 => .scd40,
        1 => .scd41,
        5 => .scd43,
        else => .unknown,
    };
}

pub fn main(init: std.process.Init) !void {
    std.debug.print("SCD40 data conversions / reference algorithms (run `zig build test`).\n", .{});
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;
    try stdout_writer.writeAll("CO2 seed 500ppm -> raw 0x01f4 (crc 0x");
    var buf: [32]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "{x:0>2}", .{crc8Word(co2ToRaw(500))}) catch unreachable;
    try stdout_writer.writeAll(s);
    try stdout_writer.writeAll(")\n");
    try stdout_writer.flush();
}

// ===========================================================================
// Tests
// ===========================================================================

fn expectNear(actual: f64, expected: f64, tol: f64) !void {
    try std.testing.expectApproxEqRel(actual, expected, tol);
}

fn expectWordNear(actual: u16, expected: u16) !void {
    const diff = if (actual > expected) actual - expected else expected - actual;
    try std.testing.expect(diff <= 1);
}

test "crc8 datasheet vectors (Table 40)" {
    try std.testing.expectEqual(@as(u8, 0x92), crc8Word(0xbeef));

    try std.testing.expectEqual(@as(u8, 0x33), crc8Word(0x01f4));
    try std.testing.expectEqual(@as(u8, 0xa2), crc8Word(0x6667));
    try std.testing.expectEqual(@as(u8, 0x3c), crc8Word(0x5eb9));
    try std.testing.expectEqual(@as(u8, 0x63), crc8Word(0x0912));
    try std.testing.expectEqual(@as(u8, 0x48), crc8Word(0x07e6));
    try std.testing.expectEqual(@as(u8, 0x09), crc8Word(0x079e));
    try std.testing.expectEqual(@as(u8, 0x42), crc8Word(0x044c));
    try std.testing.expectEqual(@as(u8, 0x42), crc8Word(0x03db));
    try std.testing.expectEqual(@as(u8, 0x7b), crc8Word(0x7fce));
    try std.testing.expectEqual(@as(u8, 0xb4), crc8Word(0x01e0));
    try std.testing.expectEqual(@as(u8, 0xb0), crc8Word(0x0001));
    try std.testing.expectEqual(@as(u8, 0x81), crc8Word(0x0000));
    try std.testing.expectEqual(@as(u8, 0x99), crc8Word(0x01b3));
    try std.testing.expectEqual(@as(u8, 0x4d), crc8Word(0x01a4));
    try std.testing.expectEqual(@as(u8, 0xa2), crc8Word(0x8000));
    try std.testing.expectEqual(@as(u8, 0xc1), crc8Word(0x004c));
    try std.testing.expectEqual(@as(u8, 0xc5), crc8Word(0x009c));
    try std.testing.expectEqual(@as(u8, 0x3f), crc8Word(0x0440));
    try std.testing.expectEqual(@as(u8, 0x51), crc8Word(0x1440));
    try std.testing.expectEqual(@as(u8, 0xe9), crc8Word(0x5441));
    try std.testing.expectEqual(@as(u8, 0x31), crc8Word(0xf896));
    try std.testing.expectEqual(@as(u8, 0xc2), crc8Word(0x9f07));
    try std.testing.expectEqual(@as(u8, 0x89), crc8Word(0x3bbe));
}

test "read_measurement decode vectors" {
    // CO2: raw count == ppm (identity).
    try std.testing.expectEqual(@as(u16, 500), co2FromRaw(0x01f4));

    // Temp: raw 0x6667 -> 25.0 °C (spec worked example).
    try expectNear(tempFromRaw(0x6667), 25.0, 1e-3);

    // RH: raw 0x5eb9 -> 37.0 %RH (spec worked example).
    try expectNear(rhFromRaw(0x5eb9), 37.0, 1e-3);
}

test "read_measurement encode round-trip" {
    // 500 ppm is exactly representable.
    try std.testing.expectEqual(@as(u16, 500), co2ToRaw(500));

    // 25.0 °C: datasheet emits 0x6667; encoder is within one count of it and
    // round-trips to 25.0.
    const t_word = tempToRaw(25.0);
    try expectWordNear(t_word, 0x6667);
    try expectNear(tempFromRaw(t_word), 25.0, 1e-3);

    // 37.0 %RH: datasheet emits 0x5eb9; encoder within one count and round-trips.
    const rh_word = rhToRaw(37.0);
    try expectWordNear(rh_word, 0x5eb9);
    try expectNear(rhFromRaw(rh_word), 37.0, 1e-3);
}

test "temperature offset vectors" {
    // decode 0x0912 -> 6.2 °C.
    try expectNear(tempOffsetFromRaw(0x0912), 6.2, 1e-3);
    // encode 6.2 °C -> 0x0912 (and 5.4 °C -> 0x07e6 ± 1 count).
    try expectWordNear(tempOffsetToRaw(6.2), 0x0912);
    try expectWordNear(tempOffsetToRaw(5.4), 0x07e6);
    // round trip
    try expectNear(tempOffsetFromRaw(tempOffsetToRaw(6.2)), 6.2, 1e-3);
}

test "sensor altitude vectors" {
    try std.testing.expectEqual(@as(u16, 1950), altitudeFromRaw(0x079e));
    try std.testing.expectEqual(@as(u16, 1100), altitudeFromRaw(0x044c));
    try std.testing.expectEqual(@as(u16, 1950), altitudeToRaw(1950));
}

test "ambient pressure vectors" {
    try std.testing.expectEqual(@as(u32, 98700), pressureFromRaw(0x03db));
    try std.testing.expectEqual(@as(u16, 987), pressureToRaw(98700));
    try std.testing.expectEqual(@as(u16, 987), pressureToRaw(98710));
}

test "forced recalibration vectors" {
    try std.testing.expectEqual(@as(i32, -50), frcCorrectionFromRaw(0x7fce));
    try std.testing.expectEqual(@as(i32, 32767), frcCorrectionFromRaw(0xffff));
    try std.testing.expect(frcFailed(0xffff));
    try std.testing.expect(!frcFailed(0x7fce));
    try std.testing.expectEqual(@as(u16, 480), frcTargetToRaw(480));
}

test "ASC enable vectors" {
    try std.testing.expect(ascEnabledFromRaw(0x0001));
    try std.testing.expect(!ascEnabledFromRaw(0x0000));
    try std.testing.expectEqual(@as(u16, 0x0001), ascEnabledToRaw(true));
    try std.testing.expectEqual(@as(u16, 0x0000), ascEnabledToRaw(false));
}

test "ASC target and period vectors" {
    try std.testing.expectEqual(@as(u16, 435), ascTargetFromRaw(0x01b3));
    try std.testing.expectEqual(@as(u16, 420), ascTargetFromRaw(0x01a4));
    try std.testing.expectEqual(@as(u16, 435), ascTargetToRaw(435));
    try std.testing.expectEqual(@as(u16, 76), ascPeriodFromRaw(0x004c));
    try std.testing.expectEqual(@as(u16, 156), ascPeriodFromRaw(0x009c));
    try std.testing.expectEqual(@as(u16, 76), ascPeriodToRaw(76));
    try std.testing.expectEqual(@as(u16, 156), ascPeriodToRaw(156));
}

test "serial number vectors" {
    const expected: u64 = 273_325_796_834_238;
    try std.testing.expectEqual(expected, serialFromRaw(0xf896, 0x9f07, 0x3bbe));

    const words = try serialToRaw(expected);
    try std.testing.expectEqual(@as(u16, 0xf896), words.w0);
    try std.testing.expectEqual(@as(u16, 0x9f07), words.w1);
    try std.testing.expectEqual(@as(u16, 0x3bbe), words.w2);

    // round trip
    try std.testing.expectEqual(expected, serialFromRaw(words.w0, words.w1, words.w2));
}

test "serial number out-of-range errors" {
    try std.testing.expectError(error.OutOfRange, serialToRaw(0x0001_0000_0000_0000));
    try std.testing.expectError(error.OutOfRange, serialToRaw(std.math.maxInt(u64)));
}

test "data ready status vectors" {
    try std.testing.expect(!dataReady(0x8000)); // bits 10:0 all zero -> not ready
    try std.testing.expect(dataReady(0x0400)); // bit 10 set -> ready
    try std.testing.expect(dataReady(0x0001)); // bit 0 set -> ready
    try std.testing.expect(!dataReady(0x0800)); // bit 11 set, bits 10:0 zero -> not ready
}

test "sensor variant vectors" {
    try std.testing.expectEqual(Variant.scd40, variantFromRaw(0x0440));
    try std.testing.expectEqual(Variant.scd41, variantFromRaw(0x1440));
    try std.testing.expectEqual(Variant.scd43, variantFromRaw(0x5441));
    try std.testing.expectEqual(Variant.unknown, variantFromRaw(0x4440));
}

test "encode saturating overflow/out-of-range policy" {
    // temperature below -45 °C -> 0x0000, above 130 °C -> 0xffff
    try std.testing.expectEqual(@as(u16, 0x0000), tempToRaw(-100.0));
    try std.testing.expectEqual(@as(u16, 0xffff), tempToRaw(1.0e6));
    // RH outside [0,100] -> 0x0000 / 0xffff
    try std.testing.expectEqual(@as(u16, 0x0000), rhToRaw(-5.0));
    try std.testing.expectEqual(@as(u16, 0xffff), rhToRaw(150.0));
    // temperature offset outside [0,175] -> 0x0000 / 0xffff
    try std.testing.expectEqual(@as(u16, 0x0000), tempOffsetToRaw(-3.0));
    try std.testing.expectEqual(@as(u16, 0xffff), tempOffsetToRaw(300.0));
    // pressure: <50 Pa -> 0, >6.5535 MPa -> saturated
    try std.testing.expectEqual(@as(u16, 0x0000), pressureToRaw(0));
    try std.testing.expectEqual(@as(u16, 0x0000), pressureToRaw(49));
    try std.testing.expectEqual(@as(u16, 0xffff), pressureToRaw(0xffff * 100));
    // altitude identity saturates at type bounds (u16 cannot hold >0xffff)
    try std.testing.expectEqual(@as(u16, 0xffff), altitudeToRaw(0xffff));
}

test "fuzz: temp encode/decode round-trips within one count" {
    try std.testing.fuzz({}, fuzzTempRoundTrip, .{});
}

fn fuzzTempRoundTrip(ctx: void, smith: *std.testing.Smith) !void {
    _ = ctx;
    const count = smith.value(u16);
    const back = tempToRaw(tempFromRaw(count));
    const diff = if (back > count) back - count else count - back;
    try std.testing.expect(diff <= 1);
}