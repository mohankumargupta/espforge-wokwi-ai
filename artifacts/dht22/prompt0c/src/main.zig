const std = @import("std");

/// DHT22 (AM2302) data conversion functions and reference algorithms.
///
/// The sensor emits one 40-bit (5 byte) frame, MSB first:
///   byte0 = RH_INT, byte1 = RH_DEC, byte2 = T_INT, byte3 = T_DEC, byte4 = CHECK
///
/// Real-world values are formed as a full 16-bit word from integral-then-decimal
/// bytes and divided by 10 (resolution 0.1 %RH / 0.1 °C). The temperature word
/// uses sign/magnitude encoding: bit 15 is the sign, bits 14:0 the magnitude.

pub const Frame = struct {
    rh_int: u8,
    rh_dec: u8,
    t_int: u8,
    t_dec: u8,
    check: u8,
};

pub const Reading = struct {
    humidity_percent: f32,
    temperature_c: f32,
    checksum_ok: bool,
};

/// Form the humidity 16-bit word from its integral and decimal bytes.
/// bit layout: word = (RH_INT << 8) | RH_DEC, bytes transmitted MSB first.
pub fn humidityWord(hi: u8, lo: u8) u16 {
    return (@as(u16, hi) << 8) | lo;
}

/// Decode humidity bytes to %RH: full 16-bit word / 10.
/// Note: the register can represent up to 6553.5 %RH; the sensor's valid
/// operating range is 0–100 %RH but the decode formula is not clamped so the
/// raw bit content is always mapped faithfully.
pub fn humidityDecode(hi: u8, lo: u8) f32 {
    return @as(f32, @floatFromInt(humidityWord(hi, lo))) / 10.0;
}

/// Encode %RH to humidity (integral, decimal) bytes.
///
/// Out-of-range policy: clamp/saturate the input to the sensor's physical
/// operating range [0, 100] %RH, then round to the nearest 0.1 %RH (resolution).
pub fn humidityEncode(value: f32) struct { rh_int: u8, rh_dec: u8 } {
    const clamped = std.math.clamp(@as(f64, value), 0.0, 100.0);
    const word: u16 = @intFromFloat(@round(clamped * 10.0));
    return .{
        .rh_int = @intCast(word >> 8),
        .rh_dec = @intCast(word & 0xFF),
    };
}

/// Form the temperature 16-bit word from its integral and decimal bytes.
/// bit layout: word = (T_INT << 8) | T_DEC, bytes transmitted MSB first.
pub fn temperatureWord(hi: u8, lo: u8) u16 {
    return (@as(u16, hi) << 8) | lo;
}

/// Decode a raw temperature word to °C using sign/magnitude (bit 15 = sign).
pub fn temperatureDecodeRaw(raw: u16) f32 {
    if (raw & 0x8000 != 0) {
        return -@as(f32, @floatFromInt(raw & 0x7FFF)) / 10.0;
    }
    return @as(f32, @floatFromInt(raw)) / 10.0;
}

/// Decode temperature bytes to °C using sign/magnitude (bit 15 = sign).
/// Per the spec: temperature_C = (bit15 set) ? -(raw & 0x7FFF) / 10.0 : raw / 10.0
pub fn temperatureDecode(hi: u8, lo: u8) f32 {
    return temperatureDecodeRaw(temperatureWord(hi, lo));
}

/// Encode °C to temperature (integral, decimal) bytes using sign/magnitude.
///
/// Out-of-range policy: clamp/saturate the input to the sensor's physical
/// operating range [−40, +80] °C, then round to the nearest 0.1 °C.
/// Canonical zero is 0x0000; the sign/magnitude duplicate 0x8000 also decodes
/// to +0.0 but is never produced by this encoder.
pub fn temperatureEncode(value: f32) struct { t_int: u8, t_dec: u8 } {
    const clamped = std.math.clamp(@as(f64, value), -40.0, 80.0);
    if (clamped < 0.0) {
        const mag: u16 = @as(u16, @intFromFloat(@round(-clamped * 10.0))) & 0x7FFF;
        const word: u16 = 0x8000 | mag;
        return .{ .t_int = @intCast(word >> 8), .t_dec = @intCast(word & 0xFF) };
    }
    const word: u16 = @intFromFloat(@round(clamped * 10.0));
    return .{ .t_int = @intCast(word >> 8), .t_dec = @intCast(word & 0xFF) };
}

/// Checksum = low 8 bits of (RH_INT + RH_DEC + T_INT + T_DEC).
pub fn checksum(frame: *const Frame) u8 {
    const sum: u32 = @as(u32, frame.rh_int) + frame.rh_dec + frame.t_int + frame.t_dec;
    return @truncate(sum);
}

/// Returns true when frame.check equals the checksum of the four data bytes.
pub fn checksumValid(frame: *const Frame) bool {
    return frame.check == checksum(frame);
}

/// Decode a full 40-bit frame into real-world values + checksum validity.
pub fn decode(frame: *const Frame) Reading {
    return .{
        .humidity_percent = humidityDecode(frame.rh_int, frame.rh_dec),
        .temperature_c = temperatureDecode(frame.t_int, frame.t_dec),
        .checksum_ok = checksumValid(frame),
    };
}

/// Encode real-world values into a full frame with the checksum filled in.
pub fn encode(humidity_percent: f32, temperature_c: f32) Frame {
    const h = humidityEncode(humidity_percent);
    const t = temperatureEncode(temperature_c);
    var frame = Frame{
        .rh_int = h.rh_int,
        .rh_dec = h.rh_dec,
        .t_int = t.t_int,
        .t_dec = t.t_dec,
        .check = 0,
    };
    frame.check = checksum(&frame);
    return frame;
}

pub fn main() void {
    const frame = encode(50.4, 25.0);
    const r = decode(&frame);
    std.debug.print("humidity: {d:.1} %RH, temperature: {d:.1} C, checksum_ok: {}\n", .{
        r.humidity_percent,
        r.temperature_c,
        r.checksum_ok,
    });
}

test "humidity decode worked vector 0x01 0xF8 -> 50.4 %RH" {
    try std.testing.expectEqual(@as(u16, 0x01F8), humidityWord(0x01, 0xF8));
    try std.testing.expectApproxEqRel(@as(f32, 50.4), humidityDecode(0x01, 0xF8), 0.0001);
}

test "temperature decode worked vector 0x00 0xFA -> 25.0 C" {
    try std.testing.expectEqual(@as(u16, 0x00FA), temperatureWord(0x00, 0xFA));
    try std.testing.expectApproxEqRel(@as(f32, 25.0), temperatureDecode(0x00, 0xFA), 0.0001);
}

test "temperature decode of spec's negative raw 0x80 0x00 -> 0.0 (sign/magnitude)" {
    // Spec worked-example table labels raw 0x8000 as -10.0 C, but its own decode
    // formula (bit15 => -(raw & 0x7FFF)/10) yields -(0x0000)/10 = 0.0. The decode
    // primitive is authoritative; see conversions_manifest.md for the discrepancy.
    const raw: u16 = 0x8000;
    const expected = temperatureDecodeRaw(raw);
    const actual = temperatureDecode(0x80, 0x00);
    try std.testing.expectApproxEqRel(expected, actual, 0.0001);
    try std.testing.expectApproxEqRel(@as(f32, 0.0), actual, 0.0001);
}

test "temperature encode -10.0 C -> 0x80 0x64, round trips" {
    const t = temperatureEncode(-10.0);
    try std.testing.expectEqual(@as(u8, 0x80), t.t_int);
    try std.testing.expectEqual(@as(u8, 0x64), t.t_dec);
    try std.testing.expectApproxEqRel(@as(f32, -10.0), temperatureDecode(t.t_int, t.t_dec), 0.0001);
}

test "humidity encode 50.4 -> 0x01 0xF8, round trips" {
    const h = humidityEncode(50.4);
    try std.testing.expectEqual(@as(u8, 0x01), h.rh_int);
    try std.testing.expectEqual(@as(u8, 0xF8), h.rh_dec);
    try std.testing.expectApproxEqRel(@as(f32, 50.4), humidityDecode(h.rh_int, h.rh_dec), 0.0001);
}

test "canonical zero: encode(0.0) -> 0x00 0x00, and 0x8000 decodes to 0.0 too" {
    const t = temperatureEncode(0.0);
    try std.testing.expectEqual(@as(u8, 0x00), t.t_int);
    try std.testing.expectEqual(@as(u8, 0x00), t.t_dec);
    try std.testing.expectApproxEqRel(@as(f32, 0.0), temperatureDecode(0x00, 0x00), 0.0001);
    try std.testing.expectApproxEqRel(@as(f32, 0.0), temperatureDecode(0x80, 0x00), 0.0001);
}

test "checksum: (0x01,0xF8,0x00,0xFA) beats low byte 0xF3" {
    var frame = Frame{ .rh_int = 0x01, .rh_dec = 0xF8, .t_int = 0x00, .t_dec = 0xFA, .check = 0xF3 };
    try std.testing.expectEqual(@as(u8, 0xF3), checksum(&frame));
    try std.testing.expect(checksumValid(&frame));
    frame.check ^= 0x01;
    try std.testing.expect(!checksumValid(&frame));
}

test "humidity encode clamps out-of-range input to [0,100] %RH" {
    const low = humidityEncode(-5.0);
    try std.testing.expectEqual(@as(u16, 0x0000), humidityWord(low.rh_int, low.rh_dec));
    const high = humidityEncode(150.0);
    try std.testing.expectEqual(@as(u16, 0x03E8), humidityWord(high.rh_int, high.rh_dec)); // 1000 -> 100.0
}

test "temperature encode clamps out-of-range input to [-40,80] C" {
    const hot = temperatureEncode(1500.0);
    try std.testing.expectApproxEqRel(@as(f32, 80.0), temperatureDecode(hot.t_int, hot.t_dec), 0.0001);
    const cold = temperatureEncode(-100.0);
    try std.testing.expectApproxEqRel(@as(f32, -40.0), temperatureDecode(cold.t_int, cold.t_dec), 0.0001);
}

test "full frame encode/decode round trip" {
    const frame = encode(50.4, 25.0);
    const r = decode(&frame);
    try std.testing.expectApproxEqRel(@as(f32, 50.4), r.humidity_percent, 0.0001);
    try std.testing.expectApproxEqRel(@as(f32, 25.0), r.temperature_c, 0.0001);
    try std.testing.expect(r.checksum_ok);
}