//! DHT22 (AM2302) – digital temperature / relative-humidity sensor, single-bus.
//! Wokwi Custom Chip · Zig 0.16 (wasm32-freestanding, no_std)
//!
//! Implements the essentials needed by the canonical test spec
//! (test_spec_dht22.md): the single bidirectional DATA line with a timing-
//! accurate asynchronous response to the host start pulse:
//!
//!   host pulls DATA low >= 1 ms, releases it -> sensor answers with
//!   LOW 80 us, HIGH 80 us (response preamble), then one 40-bit frame
//!   (MSB first), each bit LOW 50 us + HIGH 70 us (1) / 28 us (0).
//!
//! The two live observables (temperature, humidity) are read from float
//! attributes on every start signal, so a chip.json slider change takes
//! effect on the next read.
//!
//! Frame byte encoding is ported VERBATIM from
//! artifacts/dht22/prompt0c/src/main.zig (data-conversions-complex-logic,
//! the single source of truth — see conversions_manifest.md).

const std = @import("std");
const builtin = @import("builtin");

// true in the wasm chip build, false in the host `zig build test` build.
const chip_mode = !builtin.is_test;

// ─── Wokwi API types (mirrors assets/wokwi_api.zig / wokwi-api.h) ────────────

const Pin = i32;
const TimerId = u32;

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

/// Passed to pinWatch; must stay alive (heap or global) for the simulation.
const PinWatchConfig = extern struct {
    user_data: ?*anyopaque,
    edge: u32,
    pin_change: *const fn (?*anyopaque, Pin, u32) callconv(.c) void,
};

/// Passed to timerInit; must stay alive (heap or global) for the simulation.
const TimerConfig = extern struct {
    user_data: ?*anyopaque,
    callback: *const fn (?*anyopaque) callconv(.c) void,
};

// ─── Wokwi Host-Function Imports (become WASM imports from "env") ─────────────

extern fn pinInit(name: [*:0]const u8, mode: u32) Pin;
extern fn pinMode(pin: Pin, mode: u32) void;
extern fn pinWrite(pin: Pin, value: u32) void;
extern fn pinWatch(pin: Pin, config: *const PinWatchConfig) bool;
extern fn attrInit(name: [*:0]const u8, default_value: f64) u32;
extern fn attrReadFloat(attr_id: u32) f64;
extern fn timerInit(config: *const TimerConfig) TimerId;
extern fn timerStart(timer: TimerId, micros: u32, repeat: bool) void;
extern fn getSimNanos() f64;

// ─── Single-wire protocol timing (spec_dht22.md, in microseconds) ────────────

// Host must hold DATA low for >= 1 ms for a valid start signal. ESPHome's DHT
// driver holds it for exactly 1000 us; the 900 us threshold tolerates rounding
// while still rejecting any short glitch.
const START_MIN_LOW_US: f64 = 900.0;
const RESPONSE_LOW_US: u32 = 80; // sensor response: low 80 us
const RESPONSE_HIGH_US: u32 = 80; // then high 80 us
const BIT_LOW_US: u32 = 50; // every data bit: low 50 us
const BIT_ONE_HIGH_US: u32 = 70; // high 70 us encodes bit "1"
const BIT_ZERO_HIGH_US: u32 = 28; // high 26-28 us encodes bit "0"

/// Transmission phase of the DATA-line state machine.
const Phase = enum(u8) {
    idle, // bus released, waiting for the host start pulse
    start_wait, // host holds DATA low (start signal in progress)
    resp_low, // sensor driving low (response preamble)
    resp_high, // sensor released high (response preamble)
    bit_low, // sensor driving low (current data bit)
    bit_high, // sensor released high (current data bit high pulse)
};

const PINS = struct {
    const data: [*:0]const u8 = "DATA";
};

// ─── Chip State ───────────────────────────────────────────────────────────────

const ChipState = struct {
    data_pin: Pin = 0,
    timer: TimerId = 0,

    phase: Phase = .idle,
    low_start_nanos: f64 = 0, // sim time the host start pulse began (falling edge)
    bit_index: u8 = 0, // 0..39, MSB first over the 5-byte frame

    // The 40-bit response frame: RH_INT, RH_DEC, T_INT, T_DEC, CHECK.
    frame: [5]u8 = .{ 0, 0, 0, 0, 0 },

    // Attribute ids for the live observable controls (environmental).
    attr_temperature: u32 = 0,
    attr_humidity: u32 = 0,

    // Callback configs must outlive their registration (global state).
    watch_config: PinWatchConfig = undefined,
    timer_config: TimerConfig = undefined,
};

// Global static state instead of dynamic allocation
var global_chip: ChipState = undefined;

// ─── Canonical conversions (PORTED verbatim from prompt0c/src/main.zig) ──────

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

/// Decode humidity bytes to %RH: full 16-bit word / 10. Resolution 0.1 %RH.
/// Not clamped: raw bit content is always mapped faithfully.
pub fn humidityDecode(hi: u8, lo: u8) f32 {
    return @as(f32, @floatFromInt(humidityWord(hi, lo))) / 10.0;
}

/// Encode %RH to humidity (integral, decimal) bytes.
/// Out-of-range policy: clamp/saturate to [0, 100] %RH, round to 0.1 %RH.
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
pub fn temperatureDecode(hi: u8, lo: u8) f32 {
    return temperatureDecodeRaw(temperatureWord(hi, lo));
}

/// Encode °C to temperature (integral, decimal) bytes using sign/magnitude.
/// Out-of-range policy: clamp/saturate to [-40, +80] °C, round to 0.1 °C.
/// Canonical zero encodes as 0x0000; 0x8000 (sign/magnitude -0) never emitted.
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

// ─── chip_init (exported as "chipInit" – called once by Wokwi at startup) ────

comptime {
    if (chip_mode) {
        @export(&chipInit, .{ .name = "chipInit" });
    }
}

fn chipInit() callconv(.c) void {
    const chip = &global_chip;
    chip.* = ChipState{};

    // ── Live observable controls (environmental inputs) ─────────────────
    // Defaults match the canonical observable defaults (test_spec_dht22.md):
    // temperature 25.0 C, humidity 50.4 %. attrReadFloat re-reads on every
    // start signal so a chip.json slider change is observed on the next read.
    chip.attr_temperature = attrInit("temperature", 25.0);
    chip.attr_humidity = attrInit("humidity", 50.4);

    // ── DATA: single bidirectional line; internal pull-up keeps the bus ──
    // high in the idle state (diagram.json has no external pull-up resistor).
    chip.data_pin = pinInit(PINS.data, @intFromEnum(PinMode.input_pullup));

    chip.watch_config = .{
        .user_data = chip,
        .edge = @intFromEnum(Edge.both),
        .pin_change = onDataChange,
    };
    _ = pinWatch(chip.data_pin, &chip.watch_config);

    chip.timer_config = .{
        .user_data = chip,
        .callback = onTimerEvent,
    };
    chip.timer = timerInit(&chip.timer_config);
}

// ─── Data-line state machine ─────────────────────────────────────────────────

/// Called on every DATA edge while idle/start_wait: tracks the host's start
/// pulse and, on its release, launches the response. Edges that occur while
/// the sensor itself is transmitting (Wokwi delivers our own pin writes back
/// through the watch) are ignored via the phase guard.
fn onDataChange(user_data: ?*anyopaque, pin: Pin, value: u32) callconv(.c) void {
    _ = pin;
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    if (chip.phase != .idle and chip.phase != .start_wait) return;

    if (value == @intFromEnum(PinValue.low)) {
        // Falling edge: (re-)start the host start-pulse window.
        chip.low_start_nanos = getSimNanos();
        chip.phase = .start_wait;
    } else {
        // Rising edge: the host released the bus. If the low phase lasted
        // >= 1 ms it was a valid start signal; answer with the response.
        if (chip.phase == .start_wait) {
            const elapsed_us = (getSimNanos() - chip.low_start_nanos) / 1000.0;
            if (elapsed_us >= START_MIN_LOW_US) {
                beginResponse(chip);
            } else {
                chip.phase = .idle; // too short / glitch: ignore
            }
        }
    }
}

/// Launch the 80/80 us response preamble followed by the 40-bit data frame.
fn beginResponse(chip: *ChipState) void {
    buildFrame(chip);
    chip.bit_index = 0;
    chip.phase = .resp_low;
    pullLow(chip);
    timerStart(chip.timer, RESPONSE_LOW_US, false);
}

/// Build the 40-bit frame from the current observable attributes.
fn buildFrame(chip: *ChipState) void {
    const humidity: f32 = @floatCast(attrReadFloat(chip.attr_humidity));
    const temperature: f32 = @floatCast(attrReadFloat(chip.attr_temperature));
    const value = encode(humidity, temperature);
    chip.frame[0] = value.rh_int;
    chip.frame[1] = value.rh_dec;
    chip.frame[2] = value.t_int;
    chip.frame[3] = value.t_dec;
    chip.frame[4] = value.check;
}

/// Drive DATA low (open-drain sink).
fn pullLow(chip: *ChipState) void {
    pinMode(chip.data_pin, @intFromEnum(PinMode.output));
    pinWrite(chip.data_pin, @intFromEnum(PinValue.low));
}

/// Release DATA: the internal pull-up drives the bus high (open-drain idle).
fn releaseLine(chip: *ChipState) void {
    pinMode(chip.data_pin, @intFromEnum(PinMode.input_pullup));
}

/// The data bit currently being transmitted (MSB first, bit 0 = MSB of byte0).
fn currentBit(chip: *const ChipState) u8 {
    const byte = chip.frame[chip.bit_index / 8];
    const shift: u3 = @intCast(7 - (chip.bit_index % 8));
    return (byte >> shift) & 1;
}

/// Advances the transmission phase; the high-pulse width encodes each bit.
fn onTimerEvent(user_data: ?*anyopaque) callconv(.c) void {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    switch (chip.phase) {
        .resp_low => {
            // Repeat the measured high pulse of the response preamble.
            chip.phase = .resp_high;
            releaseLine(chip);
            timerStart(chip.timer, RESPONSE_HIGH_US, false);
        },
        .resp_high => {
            // Response preamble done; start the first data bit.
            chip.phase = .bit_low;
            pullLow(chip);
            timerStart(chip.timer, BIT_LOW_US, false);
        },
        .bit_low => {
            // Release; the high duration encodes the current bit.
            chip.phase = .bit_high;
            releaseLine(chip);
            const is_one = currentBit(chip) != 0;
            timerStart(chip.timer, if (is_one) BIT_ONE_HIGH_US else BIT_ZERO_HIGH_US, false);
        },
        .bit_high => {
            chip.bit_index += 1;
            if (chip.bit_index < 40) {
                chip.phase = .bit_low;
                pullLow(chip);
                timerStart(chip.timer, BIT_LOW_US, false);
            } else {
                finishResponse(chip);
            }
        },
        else => {},
    }
}

/// All 40 bits sent: release the bus and return to the idle state.
fn finishResponse(chip: *ChipState) void {
    chip.phase = .idle;
    releaseLine(chip);
}

// ─── Tests (host `zig build test` only; not built into the wasm chip) ────────
//
// These assert the exact canonical frame bytes for the observable defaults
// (test_spec_dht22.md) against the values recorded in conversions_manifest.md,
// plus the MSB-first bit order ESPHome reads off the wire. They run on the
// native host via build.zig's test step; the wasm chip build never includes
// them (chip_mode gates the ABI).

test "humidity decode worked vector 0x01 0xF8 -> 50.4 %RH" {
    try std.testing.expectEqual(@as(u16, 0x01F8), humidityWord(0x01, 0xF8));
    try std.testing.expectApproxEqRel(@as(f32, 50.4), humidityDecode(0x01, 0xF8), 0.0001);
}

test "temperature decode worked vector 0x00 0xFA -> 25.0 C" {
    try std.testing.expectEqual(@as(u16, 0x00FA), temperatureWord(0x00, 0xFA));
    try std.testing.expectApproxEqRel(@as(f32, 25.0), temperatureDecode(0x00, 0xFA), 0.0001);
}

test "temperature decode of spec's negative raw 0x80 0x00 -> 0.0 (sign/magnitude)" {
    // Spec worked-example table labels raw 0x8000 as -10.0 C, but its own
    // decode formula (bit15 => -(raw & 0x7FFF)/10) yields -(0x0000)/10 = 0.0.
    // The decode primitive is authoritative (see conversions_manifest.md).
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

test "canonical defaults -> exact 40-bit frame bytes (test_spec_dht22.md)" {
    // temperature 25.0 C -> T bytes 0x00 0xFA; humidity 50.4 % -> RH bytes
    // 0x01 0xF8; checksum low byte of (0x01+0xF8+0x00+0xFA) = 0xF3.
    // Full frame byte stream (MSB first): 0x01 0xF8 0x00 0xFA 0xF3.
    const frame = encode(50.4, 25.0);
    try std.testing.expectEqual(@as(u8, 0x01), frame.rh_int);
    try std.testing.expectEqual(@as(u8, 0xF8), frame.rh_dec);
    try std.testing.expectEqual(@as(u8, 0x00), frame.t_int);
    try std.testing.expectEqual(@as(u8, 0xFA), frame.t_dec);
    try std.testing.expectEqual(@as(u8, 0xF3), frame.check);
    try std.testing.expect(checksumValid(&frame));

    const r = decode(&frame);
    try std.testing.expectApproxEqRel(@as(f32, 50.4), r.humidity_percent, 0.0001);
    try std.testing.expectApproxEqRel(@as(f32, 25.0), r.temperature_c, 0.0001);
    try std.testing.expect(r.checksum_ok);
}

test "frame serializes MSB first across all 40 bits" {
    // ESPHome samples each bit's high pulse and shifts MSB-first into the
    // five data bytes; assert the exact bit stream for the canonical frame.
    var chip = ChipState{};
    chip.frame = .{ 0x01, 0xF8, 0x00, 0xFA, 0xF3 };
    var bits: [40]u8 = undefined;
    for (0..40) |i| {
        chip.bit_index = @intCast(i);
        bits[i] = currentBit(&chip);
    }

    // byte0 0x01 -> 0000 0001
    try std.testing.expectEqual(@as(u8, 0), bits[0]);
    try std.testing.expectEqual(@as(u8, 0), bits[6]);
    try std.testing.expectEqual(@as(u8, 1), bits[7]);
    // byte1 0xF8 -> 1111 1000
    try std.testing.expectEqual(@as(u8, 1), bits[8]);
    try std.testing.expectEqual(@as(u8, 1), bits[11]);
    try std.testing.expectEqual(@as(u8, 0), bits[15]);
    // byte2 0x00 -> 0000 0000
    try std.testing.expectEqual(@as(u8, 0), bits[16]);
    try std.testing.expectEqual(@as(u8, 0), bits[23]);
    // byte3 0xFA -> 1111 1010
    try std.testing.expectEqual(@as(u8, 1), bits[24]);
    try std.testing.expectEqual(@as(u8, 0), bits[29]);
    try std.testing.expectEqual(@as(u8, 1), bits[30]);
    try std.testing.expectEqual(@as(u8, 0), bits[31]);
    // byte4 0xF3 -> 1111 0011
    try std.testing.expectEqual(@as(u8, 1), bits[32]);
    try std.testing.expectEqual(@as(u8, 0), bits[36]);
    try std.testing.expectEqual(@as(u8, 1), bits[39]);
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
