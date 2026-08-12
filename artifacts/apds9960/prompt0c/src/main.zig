const std = @import("std");

// APDS9960 data conversion functions and reference algorithms.
// Reference: Avago/Broadcom APDS-9960 datasheet (spec_apds9960.md) and the
// canonical test spec (test_spec_apds9960.md, ESPHome value/65535*100 and
// value/255*100 scaling).
//
// This file is the single source of truth for APDS9960 register-level bit
// layout (byte order, alignment, and sign/magnitude encoding). Any skill that
// later needs to encode or decode the same register values MUST reuse or port
// these exact functions rather than re-deriving the encoding independently.

// One ALS/color integration step (and one wait-time step), 2.78 ms per spec.
const LSB_STEP_MS: f32 = 2.78;
// Fixed proximity ADC conversion time in the tPROX formula (tCNVT = 796.6 us).
const T_CNVT_US: f32 = 796.6;
const RGBC_FULL_SCALE: u16 = 65535;
const PROX_FULL_SCALE: u16 = 255;

// ---- RGBC register pairs (Little-Endian) ----------------------------------

/// Assemble a Little-Endian RGBC 16-bit count from its two register bytes.
/// Bit layout: low byte is at the even address (CDATAL/RDATAL/...), high byte
/// at the odd address; `count = high << 8 | low`. Full 16-bit word.
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

// ---- RGBC / proximity percent scaling (ESPHome observable model) -----------

/// RGBC count (0..65535) -> percentage of full scale (value / 65535 * 100).
pub fn rgbcPercentFromCount(count: u16) f32 {
    return @as(f32, @floatFromInt(count)) / @as(f32, RGBC_FULL_SCALE) * 100.0;
}

/// Proximity count (0..255) -> percentage of full scale (value / 255 * 100).
pub fn proxPercentFromCount(count: u8) f32 {
    return @as(f32, @floatFromInt(count)) / @as(f32, PROX_FULL_SCALE) * 100.0;
}

/// ENCODE: percentage (0..100) -> RGBC 16-bit count. Inverse of
/// `rgbcPercentFromCount` (rounded to nearest count).
///
/// Out-of-range policy: **clamp/saturate** to the representable range. Input
/// below 0% clamps to count 0, above 100% clamps to count 65535. NaN clamps
/// to 0. `pct * 655.35` then rounds to the nearest integer count.
pub fn rgbcCountFromPercent(pct: f32) u16 {
    const clamped = if (std.math.isNan(pct)) 0.0 else std.math.clamp(pct, 0.0, 100.0);
    return @intFromFloat(std.math.round(clamped * 655.35));
}

/// ENCODE: percentage (0..100) -> proximity 8-bit count. Inverse of
/// `proxPercentFromCount` (rounded to nearest count).
///
/// Out-of-range policy: **clamp/saturate** to the representable range. Input
/// below 0% clamps to count 0, above 100% clamps to count 255. NaN clamps to
/// 0. `pct * 2.55` then rounds to the nearest integer count.
pub fn proxCountFromPercent(pct: f32) u8 {
    const clamped = if (std.math.isNan(pct)) 0.0 else std.math.clamp(pct, 0.0, 100.0);
    return @intFromFloat(std.math.round(clamped * 2.55));
}

// ---- ATIME / integration time / full-scale count ---------------------------

/// ATIME register -> ALS/color integration cycles (1..256).
/// Formula: CYCLES = 256 - ATIME.
pub fn atimeToCycles(atime: u8) u16 {
    return @as(u16, 256) - atime;
}

/// ATIME register -> ALS/color integration time in ms.
/// Formula: CYCLES * 2.78 ms (2.78 ms .. 712 ms).
pub fn atimeToIntegrationMs(atime: u8) f32 {
    return @as(f32, @floatFromInt(atimeToCycles(atime))) * LSB_STEP_MS;
}

/// ATIME register -> full-scale count (max raw count before saturation).
/// Formula: CountMAX = min(1024 * CYCLES + 1, 65535).
///
/// NOTE: the spec's inline formula line says "min(1025 x CYCLES, 65535)", but
/// its own worked-example table (0xF6 -> 10241, 0xDB -> 37889) only matches
/// `1024 * CYCLES + 1`. The worked examples are authoritative here; the
/// manifest records this discrepancy.
pub fn atimeToFullScale(atime: u8) u16 {
    const cycles: u32 = atimeToCycles(atime);
    const max_count: u32 = @min(1024 * cycles + 1, @as(u32, RGBC_FULL_SCALE));
    return @intCast(max_count);
}

// ---- WTIME / wait time -----------------------------------------------------

/// WTIME register -> wait steps (1..256). Formula: WAIT_STEPS = 256 - WTIME.
pub fn wtimeToSteps(wtime: u8) u16 {
    return @as(u16, 256) - wtime;
}

/// WTIME register (and CONFIG1 WLONG flag) -> wait time in ms.
/// Formula: WAIT_STEPS * 2.78 ms (WLONG = 0) or * 12 (WLONG = 1).
pub fn wtimeToWaitMs(wtime: u8, wlong: bool) f32 {
    const steps: f32 = @as(f32, @floatFromInt(wtimeToSteps(wtime)));
    const base = steps * LSB_STEP_MS;
    return if (wlong) base * 12.0 else base;
}

// ---- proximity / gesture offset registers (sign/magnitude) -----------------

/// Decode a sign/magnitude offset register byte (POFFSET_UR/DL, GOFFSET_U/D/L/R)
/// to a signed offset. Bit layout: bit 7 = sign (1 = negative), bits 6:0 =
/// magnitude (0..127). Result range [-127, +127]. The 0x80 encoding (negative
/// zero) decodes to 0; the register is an 8-bit word, offset field spans the
/// full byte.
pub fn offsetFromByte(reg: u8) i8 {
    const mag: i8 = @intCast(reg & 0x7F);
    return if ((reg & 0x80) != 0) -mag else mag;
}

/// ENCODE: signed offset -> sign/magnitude offset register byte.
/// Bit layout: bit 7 = sign (1 = negative), bits 6:0 = magnitude.
///
/// Out-of-range policy: **clamp/saturate** to the representable range
/// [-127, +127]. -128 (unrepresentable magnitude 128) clamps to -127 (0xFF);
/// values above +127 clamp to +127 (0x7F). 0 encodes as 0x00.
pub fn offsetToByte(offset: i32) u8 {
    const clamped = std.math.clamp(offset, -127, 127);
    const mag: u8 = @intCast(@abs(clamped));
    return if (clamped < 0) mag | 0x80 else mag;
}

// ---- proximity timing (PPULSE / PPLEN / tPROX) -----------------------------

/// PPULSE register field (bits 5:0) -> actual number of proximity/gesture LED
/// pulses. Formula: pulses = PPULSE + 1 (range 1..64).
pub fn pulseCount(ppulse_field: u6) u8 {
    return @as(u8, ppulse_field) + 1;
}

/// PPLEN/GPLEN field (bits 7:6) -> LED pulse length in us.
/// Decode: 0=4, 1=8, 2=16, 3=32 us.
pub fn pulseLengthUs(pplen_field: u2) u16 {
    return switch (pplen_field) {
        0 => 4,
        1 => 8,
        2 => 16,
        3 => 32,
    };
}

/// Proximity result time in ms.
/// Formula: tPROX = (tINIT + tCNVT + pulses * tACC) / 1000, with
/// tCNVT = 796.6 us (fixed, per spec). tINIT and tACC are functions of PPLEN
/// (per-pulse-length LED-on widths); the spec's Data Conversion section states
/// they are "per PPLEN" but does not tabulate them, so they are caller
/// parameters here. pulses is the decoded count from `pulseCount`.
pub fn proximityResultTimeMs(pulses: u8, t_init_us: u16, t_acc_us: u16) f32 {
    const total_us = @as(f32, @floatFromInt(t_init_us)) + T_CNVT_US +
        @as(f32, @floatFromInt(pulses)) * @as(f32, @floatFromInt(t_acc_us));
    return total_us / 1000.0;
}

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("apds9960 conversion library built (zig 0.16). Run `zig build test` to run unit tests.\n", .{});
}

// ---- tests -----------------------------------------------------------------

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

test "rgbc percent decode (canonical defaults -> %)" {
    try std.testing.expectApproxEqAbs(20.0, rgbcPercentFromCount(13107), 0.001);
    try std.testing.expectApproxEqAbs(15.0, rgbcPercentFromCount(9830), 0.001);
    try std.testing.expectApproxEqAbs(12.0, rgbcPercentFromCount(7864), 0.001);
    try std.testing.expectApproxEqAbs(9.0, rgbcPercentFromCount(5898), 0.001);
    try std.testing.expectApproxEqAbs(0.0, rgbcPercentFromCount(0), 0.001);
    try std.testing.expectApproxEqAbs(100.0, rgbcPercentFromCount(65535), 0.001);
}

test "rgbc percent encode -> canonical register bytes" {
    // Canonical decode table: 20.0% -> 0x3333 (0x33, 0x33); 15.0% -> 0x2666
    // (0x66, 0x26); 12.0% -> 0x1EB8 (0xB8, 0x1E); 9.0% -> 0x170A (0x0A, 0x17).
    try std.testing.expectEqual(@as(u16, 0x3333), rgbcCountFromPercent(20.0));
    try std.testing.expectEqual(@as(u16, 0x2666), rgbcCountFromPercent(15.0));
    try std.testing.expectEqual(@as(u16, 0x1EB8), rgbcCountFromPercent(12.0));
    try std.testing.expectEqual(@as(u16, 0x170A), rgbcCountFromPercent(9.0));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x33, .high = 0x33 }, rgbcToBytes(rgbcCountFromPercent(20.0)));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x66, .high = 0x26 }, rgbcToBytes(rgbcCountFromPercent(15.0)));
    try std.testing.expectEqual(RgbcBytes{ .low = 0xB8, .high = 0x1E }, rgbcToBytes(rgbcCountFromPercent(12.0)));
    try std.testing.expectEqual(RgbcBytes{ .low = 0x0A, .high = 0x17 }, rgbcToBytes(rgbcCountFromPercent(9.0)));
    try std.testing.expectEqual(@as(u16, 0x0000), rgbcCountFromPercent(0.0));
    try std.testing.expectEqual(@as(u16, 0xFFFF), rgbcCountFromPercent(100.0));
}

test "rgbc percent encode out-of-range clamps" {
    try std.testing.expectEqual(@as(u16, 0x0000), rgbcCountFromPercent(-5.0));
    try std.testing.expectEqual(@as(u16, 0xFFFF), rgbcCountFromPercent(150.0));
    try std.testing.expectEqual(@as(u16, 0x0000), rgbcCountFromPercent(std.math.nan(f32)));
}

test "proximity percent decode/encode (canonical default)" {
    // 18 / 255 * 100 = 7.0588 -> published as 7.1 at precision 1.
    try std.testing.expectApproxEqAbs(7.1, proxPercentFromCount(18), 0.05);
    try std.testing.expectApproxEqAbs(0.0, proxPercentFromCount(0), 0.001);
    try std.testing.expectApproxEqAbs(100.0, proxPercentFromCount(255), 0.001);
    try std.testing.expectEqual(@as(u8, 18), proxCountFromPercent(7.1));
    try std.testing.expectEqual(@as(u8, 0x00), proxCountFromPercent(0.0));
    try std.testing.expectEqual(@as(u8, 0xFF), proxCountFromPercent(100.0));
    // out-of-range clamps
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
    // 37 * 2.78 = 102.86 ms; spec table rounds to 103 ms.
    try std.testing.expectApproxEqAbs(103.0, atimeToIntegrationMs(0xDB), 0.5);
    // 256 * 2.78 = 711.68 ms; spec table rounds to 712 ms.
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
    // WLONG = 1: 711.68 * 12 = 8540.16 ms = 8.54016 s; spec table rounds to 8.54 s.
    try std.testing.expectApproxEqAbs(8540.16, wtimeToWaitMs(0x00, true), 0.01);
}

test "offset sign/magnitude worked examples" {
    try std.testing.expectEqual(@as(i8, 127), offsetFromByte(0x7F));
    try std.testing.expectEqual(@as(i8, -1), offsetFromByte(0x81));
    try std.testing.expectEqual(@as(i8, -127), offsetFromByte(0xFF));
    try std.testing.expectEqual(@as(i8, 0), offsetFromByte(0x00));
    // 0x80 (negative zero) canonicalizes to 0.
    try std.testing.expectEqual(@as(i8, 0), offsetFromByte(0x80));
}

test "offset sign/magnitude encode + clamps" {
    try std.testing.expectEqual(@as(u8, 0x7F), offsetToByte(127));
    try std.testing.expectEqual(@as(u8, 0x81), offsetToByte(-1));
    try std.testing.expectEqual(@as(u8, 0xFF), offsetToByte(-127));
    try std.testing.expectEqual(@as(u8, 0x00), offsetToByte(0));
    try std.testing.expectEqual(@as(u8, 0x41), offsetToByte(65));
    // out-of-range clamps
    try std.testing.expectEqual(@as(u8, 0x7F), offsetToByte(128));
    try std.testing.expectEqual(@as(u8, 0x7F), offsetToByte(127));
    try std.testing.expectEqual(@as(u8, 0xFF), offsetToByte(-128));
    try std.testing.expectEqual(@as(u8, 0xFF), offsetToByte(-200));
}

test "offset round trip over all register bytes except negative-zero" {
    var reg: u16 = 0;
    while (reg < 256) : (reg += 1) {
        const b: u8 = @intCast(reg);
        if (b == 0x80) continue; // duplicate encoding of 0, not canonical
        try std.testing.expectEqual(b, offsetToByte(offsetFromByte(b)));
    }
}

test "pulse count and length decodes" {
    try std.testing.expectEqual(@as(u8, 8), pulseCount(0x07)); // PPULSE=0x87 -> 8 pulses
    try std.testing.expectEqual(@as(u8, 1), pulseCount(0x00));
    try std.testing.expectEqual(@as(u8, 64), pulseCount(0x3F));
    try std.testing.expectEqual(@as(u16, 4), pulseLengthUs(0));
    try std.testing.expectEqual(@as(u16, 8), pulseLengthUs(1));
    try std.testing.expectEqual(@as(u16, 16), pulseLengthUs(2));
    try std.testing.expectEqual(@as(u16, 32), pulseLengthUs(3));
}

test "proximity result time formula" {
    // 8 pulses, tINIT=0, tACC=0 -> 796.6 us = 0.7966 ms.
    try std.testing.expectApproxEqAbs(0.7966, proximityResultTimeMs(8, 0, 0), 0.0001);
    // 8 pulses, tACC=8 us, tINIT=4 us -> (4 + 796.6 + 64)/1000 = 0.8646 ms.
    try std.testing.expectApproxEqAbs(0.8646, proximityResultTimeMs(8, 4, 8), 0.0001);
}

test "fuzz: RGBC percent round trip within one count" {
    try std.testing.fuzz({}, fuzzRgbcRoundTrip, .{});
}

fn fuzzRgbcRoundTrip(ctx: void, smith: *std.testing.Smith) !void {
    _ = ctx;
    const count = smith.value(u16);
    const back = rgbcCountFromPercent(rgbcPercentFromCount(count));
    const diff = if (back > count) back - count else count - back;
    try std.testing.expect(diff <= 1);
}

test "fuzz: proximity percent round trip within one count" {
    try std.testing.fuzz({}, fuzzProxRoundTrip, .{});
}

fn fuzzProxRoundTrip(ctx: void, smith: *std.testing.Smith) !void {
    _ = ctx;
    const count = smith.value(u8);
    const back = proxCountFromPercent(proxPercentFromCount(count));
    const diff = if (back > count) back - count else count - back;
    try std.testing.expect(diff <= 1);
}

test "fuzz: offset round trip within one count" {
    try std.testing.fuzz({}, fuzzOffsetRoundTrip, .{});
}

fn fuzzOffsetRoundTrip(ctx: void, smith: *std.testing.Smith) !void {
    _ = ctx;
    const offset = smith.value(i8);
    const back = offsetFromByte(offsetToByte(offset));
    const diff = @abs(@as(i16, back) - @as(i16, offset));
    try std.testing.expect(diff <= 1);
}
