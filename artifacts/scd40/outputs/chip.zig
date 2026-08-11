//! SCD40 – Sensirion photoacoustic CO2 sensor (I2C)
//! Wokwi Custom Chip · Zig 0.16 (No-std, wasm32-freestanding)
//!
//! Implements the essential command set needed to exercise the canonical test
//! specification (artifacts/scd40/outputs/test_spec_scd40.md): periodic
//! measurement plus the configuration/status commands the ESPHome driver
//! always issues at boot:
//!
//!   * 0x21b1 start_periodic_measurement   (send command)
//!   * 0xec05 read_measurement             (read 3 x 16-bit words + CRC)
//!   * 0x3f86 stop_periodic_measurement    (send command)
//!   * 0x241d set_temperature_offset       (write 1 word)
//!   * 0x2427 set_sensor_altitude          (write 1 word)
//!   * 0x2416 set_asc_enabled              (write 1 word)
//!   * 0xe4b8 get_data_ready_status        (read 1 word)
//!   * 0x3682 get_serial_number            (read 3 x 16-bit words + CRC)
//!   * 0x202f get_sensor_variant           (read 1 word; returns SCD40)
//!
//! Protocol model: command-based I2C (no register pointer). A 16-bit command
//! word is sent first; read commands are then answered by a separate read
//! transaction. Each payload data word is followed by a CRC-8 (poly 0x31,
//! init 0xff, no reflection/final-xor). Command words carry no CRC.
//!
//! Environmental observables are live attributes, user-editable while the
//! simulation runs: co2 (ppm), temperature (C), humidity (%). They are read
//! afresh on every `read_measurement` response, so the canonical test can
//! assert CO2=500 ppm, Temp=25.0 C, RH=37.0%.
//!
//! SPDX-License-Identifier: MIT

const std = @import("std");

// ---------------------------------------------------------------------------
// Wokwi API types
// ---------------------------------------------------------------------------

const Pin = i32;
const I2cDev = u32;

const PinMode = enum(u32) {
    input = 0,
    output = 1,
    input_pullup = 2,
    input_pulldown = 3,
};

/// Passed to i2cInit; the struct is copied by the host so stack lifetime is fine.
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

// ---------------------------------------------------------------------------
// Wokwi host-function imports (WASM imports from "env")
// ---------------------------------------------------------------------------

extern fn pinInit(name: [*:0]const u8, mode: u32) Pin;
extern fn attrInit(name: [*:0]const u8, default_value: u32) u32;
extern fn attrInitFloat(name: [*:0]const u8, default_value: f32) u32;
extern fn attrRead(attr_id: u32) u32;
extern fn attrReadFloat(attr_id: u32) f32;
extern fn i2cInit(config: *const I2cConfig) I2cDev;

// ---------------------------------------------------------------------------
// Device constants
// ---------------------------------------------------------------------------

/// SCD40 fixed 7-bit I2C address (no strapping/address pins exist on this part).
const I2C_ADDRESS: u32 = 0x62;

const CMD = struct {
    const start_periodic: u16 = 0x21b1;
    const read_measurement: u16 = 0xec05;
    const stop_periodic: u16 = 0x3f86;
    const set_temperature_offset: u16 = 0x241d;
    const get_temperature_offset: u16 = 0x2318;
    const set_sensor_altitude: u16 = 0x2427;
    const get_sensor_altitude: u16 = 0x2322;
    const ambient_pressure: u16 = 0xe000; // R/W bit differentiates set/get
    const perform_frc: u16 = 0x362f;
    const set_asc_enabled: u16 = 0x2416;
    const get_asc_enabled: u16 = 0x2313;
    const set_asc_target: u16 = 0x243a;
    const get_asc_target: u16 = 0x233f;
    const start_low_power_periodic: u16 = 0x21ac;
    const get_data_ready_status: u16 = 0xe4b8;
    const get_serial_number: u16 = 0x3682;
    const get_sensor_variant: u16 = 0x202f;
    const set_asc_initial_period: u16 = 0x2445;
    const get_asc_initial_period: u16 = 0x2340;
    const set_asc_standard_period: u16 = 0x244e;
    const get_asc_standard_period: u16 = 0x234b;
};

// ---------------------------------------------------------------------------
// Data conversions — ported VERBATIM from artifacts/scd40/prompt0c/src/main.zig
// (the canonical, unit-tested encoders/decoders). Do not re-derive.
// ---------------------------------------------------------------------------

const ZERO_POINT_TEMP_C: f64 = -45.0; // T[°C] = -45 + 175 * word / 65535
const TEMP_SPAN_C: f64 = 175.0;
const FULL_SCALE: f64 = 65535.0;
const RH_FULL_SCALE_PERCENT: f64 = 100.0;
const FRC_ZERO_POINT: i32 = 0x8000; // FRC correction[ppm] = word - 0x8000

/// Round a scaled value to the nearest integer count and clamp into the
/// representable 16-bit register range [0, 0xffff].
fn quantize(value: f64) u16 {
    const r = @round(value);
    if (r >= FULL_SCALE) return 0xffff;
    if (r <= 0.0) return 0;
    return @intFromFloat(r);
}

/// CRC-8 (Sensirion protocol checksum): polynomial 0x31, init 0xFF, no
/// reflection, no final XOR. Verified: `crc8Word(0xbeef) == 0x92`.
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

/// Encode a CO2 concentration (ppm) into its raw 16-bit count (identity).
pub fn co2ToRaw(ppm: u16) u16 {
    return ppm;
}

/// Decode a raw 16-bit count to CO2 concentration (ppm) (identity).
pub fn co2FromRaw(word: u16) u16 {
    return word;
}

/// Decode a raw temperature count to °C: `T = -45 + 175 * word / 65535`.
pub fn tempFromRaw(word: u16) f64 {
    return ZERO_POINT_TEMP_C + TEMP_SPAN_C * @as(f64, word) / FULL_SCALE;
}

/// Encode a temperature (°C) into its raw 16-bit count (round-to-nearest,
/// saturate below -45 °C -> 0x0000 and above 130 °C -> 0xffff).
pub fn tempToRaw(temp_c: f64) u16 {
    return quantize((temp_c - ZERO_POINT_TEMP_C) * FULL_SCALE / TEMP_SPAN_C);
}

/// Decode a raw humidity count to percent RH: `RH = 100 * word / 65535`.
pub fn rhFromRaw(word: u16) f64 {
    return RH_FULL_SCALE_PERCENT * @as(f64, word) / FULL_SCALE;
}

/// Encode a percent-RH value into its raw 16-bit count (round-to-nearest,
/// saturate outside 0..100).
pub fn rhToRaw(rh_percent: f64) u16 {
    return quantize(rh_percent * FULL_SCALE / RH_FULL_SCALE_PERCENT);
}

/// Decode a raw temperature-offset count to °C: `offset = word * 175 / 65535`.
pub fn tempOffsetFromRaw(word: u16) f64 {
    return TEMP_SPAN_C * @as(f64, word) / FULL_SCALE;
}

/// Encode a temperature offset (°C): round-to-nearest, saturate.
pub fn tempOffsetToRaw(offset_c: f64) u16 {
    return quantize(offset_c * FULL_SCALE / TEMP_SPAN_C);
}

/// Decode a raw sensor-altitude count to meters (identity).
pub fn altitudeFromRaw(word: u16) u16 {
    return word;
}

/// Encode an altitude (m) into its raw 16-bit count (identity).
pub fn altitudeToRaw(meters: u16) u16 {
    return meters;
}

/// Decode a raw pressure count to Pa: `pressure[Pa] = word * 100`.
pub fn pressureFromRaw(word: u16) u32 {
    return @as(u32, word) * 100;
}

/// Encode a pressure (Pa) into its raw 16-bit count: `word = round(Pa / 100)`.
pub fn pressureToRaw(pa: u32) u16 {
    return quantize(@as(f64, pa) / 100.0);
}

/// Decode the FRC correction result (signed, centered at 0x8000).
pub fn frcCorrectionFromRaw(word: u16) i32 {
    return @as(i32, word) - FRC_ZERO_POINT;
}

/// True when the FRC word is the datasheet "FRC failed" sentinel 0xffff.
pub fn frcFailed(word: u16) bool {
    return word == 0xffff;
}

/// Encode an FRC target CO2 concentration (ppm) for the write side (identity).
pub fn frcTargetToRaw(ppm: u16) u16 {
    return ppm;
}

/// Decode ASC enable: any non-zero word means enabled.
pub fn ascEnabledFromRaw(word: u16) bool {
    return word != 0;
}

/// Encode ASC enable: true -> 0x0001, false -> 0x0000.
pub fn ascEnabledToRaw(enabled: bool) u16 {
    return if (enabled) 0x0001 else 0x0000;
}

/// Decode the ASC target CO2 concentration (ppm, identity).
pub fn ascTargetFromRaw(word: u16) u16 {
    return word;
}

/// Encode the ASC target CO2 concentration (ppm, identity).
pub fn ascTargetToRaw(ppm: u16) u16 {
    return ppm;
}

/// Decode an ASC period word to hours (identity).
pub fn ascPeriodFromRaw(word: u16) u16 {
    return word;
}

/// Encode an ASC period (hours) into its raw 16-bit count (identity).
pub fn ascPeriodToRaw(hours: u16) u16 {
    return hours;
}

/// The three 16-bit data words returned by get_serial_number (48 bits total).
pub const SerialWords = struct {
    w0: u16,
    w1: u16,
    w2: u16,
};

pub const SerialNumberError = error{OutOfRange};

/// Decode a serial number from three big-endian words to a 48-bit integer.
pub fn serialFromRaw(w0: u16, w1: u16, w2: u16) u64 {
    return (@as(u64, w0) << 32) | (@as(u64, w1) << 16) | @as(u64, w2);
}

/// Encode a 48-bit serial number into three big-endian words.
pub fn serialToRaw(value: u64) SerialNumberError!SerialWords {
    if (value > 0xffff_ffff_ffff) return error.OutOfRange;
    return .{
        .w0 = @intCast(value >> 32),
        .w1 = @intCast((value >> 16) & 0xffff),
        .w2 = @intCast(value & 0xffff),
    };
}

/// Decode data-ready status: bits 10:0 hold the DATA_READY flag.
pub fn dataReady(word: u16) bool {
    return (word & 0x07ff) != 0;
}

/// Sensor variant decoded from bits 15:12 of the response word.
pub const Variant = enum {
    scd40,
    scd41,
    scd43,
    unknown,
};

/// Decode the sensor variant from response word bits 15:12.
pub fn variantFromRaw(word: u16) Variant {
    return switch (word >> 12) {
        0 => .scd40,
        1 => .scd41,
        5 => .scd43,
        else => .unknown,
    };
}

// ---------------------------------------------------------------------------
// Chip state
// ---------------------------------------------------------------------------

/// Fixed wiring-derived configuration words (defaults per datasheet / the
/// ESPHome YAML under test: no offset, no altitude, ASC disabled).
/// Stored when the corresponding set_* command is written; buffered config is
/// volatile (persist_settings, excluded from the canonical test, is not
/// implemented — settings always reset on power-up).
const Config = struct {
    temperature_offset: u16 = 0x0000, // set_temperature_offset (0x241d)
    sensor_altitude: u16 = 0x0000, // set_sensor_altitude (0x2427)
    asc_enabled: u16 = 0x0000, // set_asc_enabled (0x2416)
    asc_target: u16 = 0x01a4, // set_asc_target (0x243a); 420 ppm default
    ambient_pressure: u16 = 0x03ed, // 0xe000 write; 1013 hPa default
    asc_initial_period: u16 = 0x004c, // 76 h default
    asc_standard_period: u16 = 0x009c, // 156 h default
    serial: SerialWords = .{ .w0 = 0xf896, .w1 = 0x9f07, .w2 = 0x3bbe }, // datasheet example
};

const ChipState = struct {
    i2c: I2cDev = 0,

    // Live environmental attributes (user-editable sliders)
    attr_co2: u32 = 0,
    attr_temperature: u32 = 0,
    attr_humidity: u32 = 0,

    // Write-transaction (command parsing) state
    cmd: u16 = 0, // last command word; persists across write->read phases
    cmd_bytes: u8 = 0,
    expects_arg: bool = false, // write-type commands expect a data word + CRC
    arg_word: u16 = 0,
    arg_bytes: u8 = 0,

    // Read-transaction response buffer (max: 3 words + 3 CRCs = 9 bytes)
    resp: [9]u8 = [_]u8{0} ** 9,
    resp_len: u8 = 0,
    resp_idx: u8 = 0,

    config: Config = .{},
};

// Global static state instead of dynamic allocation (per Wokwi chips model).
var global_chip: ChipState = undefined;

// ---------------------------------------------------------------------------
// chip_init (exported as "chipInit" – called once by Wokwi at startup)
// ---------------------------------------------------------------------------

fn chipInit() callconv(.c) void {
    const chip = &global_chip;
    chip.* = ChipState{};

    // Environmental observables — the only inputs exposed as live controls.
    // Defaults mirror the canonical test spec (and diagram.json attrs).
    chip.attr_co2 = attrInit("co2", 500);
    chip.attr_temperature = attrInitFloat("temperature", 25.0);
    chip.attr_humidity = attrInitFloat("humidity", 37.0);

    // I2C slave — fixed 7-bit address 0x62 (SCD40 has no address pins).
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

// Export only in chip (non-test) builds. Keeping the Wokwi-ABI code out of
// the host test binary lets `zig build test` exercise the conversion helpers.
const builtin = @import("builtin");
const chip_mode = !builtin.is_test;

comptime {
    if (chip_mode) {
        @export(&chipInit, .{ .name = "chipInit" });
    }
}

// ---------------------------------------------------------------------------
// Command classification
// ---------------------------------------------------------------------------

/// True for commands that carry a 16-bit data word (+ CRC) after the cmd word.
fn expectsArg(cmd: u16) bool {
    return switch (cmd) {
        CMD.set_temperature_offset,
        CMD.set_sensor_altitude,
        CMD.ambient_pressure, // 0xe000 write direction (set_ambient_pressure)
        CMD.perform_frc,
        CMD.set_asc_enabled,
        CMD.set_asc_target,
        CMD.set_asc_initial_period,
        CMD.set_asc_standard_period,
        => true,
        else => false,
    };
}

/// Commit a written data word to the volatile config shadow.
fn storeArg(chip: *ChipState) void {
    switch (chip.cmd) {
        CMD.set_temperature_offset => chip.config.temperature_offset = chip.arg_word,
        CMD.set_sensor_altitude => chip.config.sensor_altitude = chip.arg_word,
        CMD.ambient_pressure => chip.config.ambient_pressure = chip.arg_word,
        CMD.set_asc_enabled => chip.config.asc_enabled = chip.arg_word,
        CMD.set_asc_target => chip.config.asc_target = chip.arg_word,
        CMD.set_asc_initial_period => chip.config.asc_initial_period = chip.arg_word,
        CMD.set_asc_standard_period => chip.config.asc_standard_period = chip.arg_word,
        CMD.perform_frc => {}, // forced recalibration is excluded from the test
        else => {},
    }
}

// ---------------------------------------------------------------------------
// I2C callbacks
// ---------------------------------------------------------------------------

fn onI2cConnect(user_data: ?*anyopaque, address: u32, read: bool) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    if (address != I2C_ADDRESS) return false; // NACK

    if (read) {
        // Begin a read phase — build the response for the command that was
        // written in the preceding transaction. Live attrs are sampled now,
        // so slider changes are picked up on the next read.
        buildResponse(chip);
    } else {
        // Fresh write transaction: every write transaction carries a command.
        chip.cmd = 0;
        chip.cmd_bytes = 0;
        chip.expects_arg = false;
        chip.arg_word = 0;
        chip.arg_bytes = 0;
    }
    return true; // ACK
}

fn onI2cWrite(user_data: ?*anyopaque, byte: u8) callconv(.c) bool {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));

    if (chip.cmd_bytes < 2) {
        // Assembling the 16-bit command word (MSB first).
        if (chip.cmd_bytes == 0) chip.cmd = 0;
        chip.cmd = (chip.cmd << 8) | @as(u16, byte);
        chip.cmd_bytes += 1;
        if (chip.cmd_bytes == 2) chip.expects_arg = expectsArg(chip.cmd);
    } else if (chip.expects_arg and chip.arg_bytes < 2) {
        // Assembling the 16-bit data word (MSB first).
        chip.arg_word = (chip.arg_word << 8) | @as(u16, byte);
        chip.arg_bytes += 1;
    } else if (chip.expects_arg) {
        // Trailing CRC-8 byte of the data word; commit the config write.
        storeArg(chip);
        chip.expects_arg = false;
        chip.arg_word = 0;
        chip.arg_bytes = 0;
    }
    return true; // ACK
}

fn onI2cRead(user_data: ?*anyopaque) callconv(.c) u8 {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    if (chip.resp_idx < chip.resp_len) {
        defer chip.resp_idx += 1;
        return chip.resp[chip.resp_idx];
    }
    return 0;
}

fn onI2cDisconnect(user_data: ?*anyopaque) callconv(.c) void {
    const chip: *ChipState = @ptrCast(@alignCast(user_data));
    chip.resp_idx = 0;
    chip.resp_len = 0;
}

// ---------------------------------------------------------------------------
// Response construction
// ---------------------------------------------------------------------------

inline fn pushWord(chip: *ChipState, word: u16) void {
    chip.resp[chip.resp_len] = @intCast(word >> 8);
    chip.resp_len += 1;
    chip.resp[chip.resp_len] = @intCast(word & 0xff);
    chip.resp_len += 1;
    chip.resp[chip.resp_len] = crc8Word(word);
    chip.resp_len += 1;
}

fn buildResponse(chip: *ChipState) void {
    chip.resp_idx = 0;
    chip.resp_len = 0;

    switch (chip.cmd) {
        CMD.read_measurement => blk: {
            const co2_attr = attrRead(chip.attr_co2);
            pushWord(chip, co2ToRaw(@intCast(@min(co2_attr, 0xffff))));
            pushWord(chip, tempToRaw(attrReadFloat(chip.attr_temperature)));
            pushWord(chip, rhToRaw(attrReadFloat(chip.attr_humidity)));
            break :blk;
        },
        CMD.get_serial_number => blk: {
            pushWord(chip, chip.config.serial.w0);
            pushWord(chip, chip.config.serial.w1);
            pushWord(chip, chip.config.serial.w2);
            break :blk;
        },
        CMD.get_data_ready_status,
        CMD.get_temperature_offset,
        CMD.get_sensor_altitude,
        CMD.get_asc_enabled,
        CMD.get_asc_target,
        CMD.get_asc_initial_period,
        CMD.get_asc_standard_period,
        CMD.ambient_pressure, // 0xe000 read direction (get_ambient_pressure)
        CMD.get_sensor_variant,
        => pushWord(chip, readWordFor(chip)),
        else => pushWord(chip, 0x0000),
    }
}

fn readWordFor(chip: *ChipState) u16 {
    return switch (chip.cmd) {
        CMD.get_data_ready_status => 0x0001, // bits 10:0 non-zero -> data ready
        CMD.get_temperature_offset => chip.config.temperature_offset,
        CMD.get_sensor_altitude => chip.config.sensor_altitude,
        CMD.get_asc_enabled => chip.config.asc_enabled,
        CMD.get_asc_target => chip.config.asc_target,
        CMD.get_asc_initial_period => chip.config.asc_initial_period,
        CMD.get_asc_standard_period => chip.config.asc_standard_period,
        CMD.ambient_pressure => chip.config.ambient_pressure,
        CMD.get_sensor_variant => 0x0440, // bits 15:12 = 0 -> SCD40
        else => 0x0000,
    };
}

// ===========================================================================
// Tests — assert the ported encoders/decoders against the conversions
// manifest worked examples (and the three observable defaults from the test
// spec: CO2=500 ppm, Temp=25 C, RH=37%).
// ===========================================================================

fn expectNear(actual: f64, expected: f64, tol: f64) !void {
    try std.testing.expectApproxEqRel(actual, expected, tol);
}

fn expectWordNear(actual: u16, expected: u16) !void {
    const diff = if (actual > expected) actual - expected else expected - actual;
    try std.testing.expect(diff <= 1);
}

test "crc8 datasheet vectors (Table 40, conversions manifest)" {
    try std.testing.expectEqual(@as(u8, 0x92), crc8Word(0xbeef));

    try std.testing.expectEqual(@as(u8, 0x33), crc8Word(0x01f4));
    try std.testing.expectEqual(@as(u8, 0xa2), crc8Word(0x6667));
    try std.testing.expectEqual(@as(u8, 0x3c), crc8Word(0x5eb9));
    try std.testing.expectEqual(@as(u8, 0xa2), crc8Word(0x8000));
    try std.testing.expectEqual(@as(u8, 0x3f), crc8Word(0x0440));
    try std.testing.expectEqual(@as(u8, 0x31), crc8Word(0xf896));
    try std.testing.expectEqual(@as(u8, 0xc2), crc8Word(0x9f07));
    try std.testing.expectEqual(@as(u8, 0x89), crc8Word(0x3bbe));
}

test "read_measurement decode vectors (observable defaults)" {
    // CO2 default 500 ppm: raw count == ppm.
    try std.testing.expectEqual(@as(u16, 500), co2FromRaw(0x01f4));

    // Temperature default 25.0 C: raw 0x6667 -> 25.0 C (spec worked example).
    try expectNear(tempFromRaw(0x6667), 25.0, 1e-3);

    // Humidity default 37.0 %: raw 0x5eb9 -> 37.0 %RH (spec worked example).
    try expectNear(rhFromRaw(0x5eb9), 37.0, 1e-3);
}

test "read_measurement encode round-trip (observable defaults)" {
    // 500 ppm is exactly representable.
    try std.testing.expectEqual(@as(u16, 500), co2ToRaw(500));

    // 25.0 C: datasheet emits 0x6667; encoder within one count, round-trips.
    const t_word = tempToRaw(25.0);
    try expectWordNear(t_word, 0x6667);
    try expectNear(tempFromRaw(t_word), 25.0, 1e-3);

    // 37.0 %RH: datasheet emits 0x5eb9; encoder within one count, round-trips.
    const rh_word = rhToRaw(37.0);
    try expectWordNear(rh_word, 0x5eb9);
    try expectNear(rhFromRaw(rh_word), 37.0, 1e-3);
}

test "temperature offset vectors" {
    try expectNear(tempOffsetFromRaw(0x0912), 6.2, 1e-3);
    try expectWordNear(tempOffsetToRaw(6.2), 0x0912);
    try expectWordNear(tempOffsetToRaw(5.4), 0x07e6);
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
    try std.testing.expectEqual(@as(u16, 76), ascPeriodFromRaw(0x004c));
    try std.testing.expectEqual(@as(u16, 156), ascPeriodFromRaw(0x009c));
}

test "serial number vectors" {
    const expected: u64 = 273_325_796_834_238;
    try std.testing.expectEqual(expected, serialFromRaw(0xf896, 0x9f07, 0x3bbe));

    const words = try serialToRaw(expected);
    try std.testing.expectEqual(@as(u16, 0xf896), words.w0);
    try std.testing.expectEqual(@as(u16, 0x9f07), words.w1);
    try std.testing.expectEqual(@as(u16, 0x3bbe), words.w2);
}

test "serial number out-of-range errors" {
    try std.testing.expectError(error.OutOfRange, serialToRaw(0x0001_0000_0000_0000));
    try std.testing.expectError(error.OutOfRange, serialToRaw(std.math.maxInt(u64)));
}

test "data ready status vectors" {
    try std.testing.expect(!dataReady(0x8000)); // bits 10:0 zero -> not ready
    try std.testing.expect(dataReady(0x0001)); // bit 0 set -> ready
    try std.testing.expect(dataReady(0x0400)); // bit 10 set -> ready
    try std.testing.expect(!dataReady(0x0800)); // bit 11 only -> not ready
}

test "sensor variant vectors" {
    try std.testing.expectEqual(Variant.scd40, variantFromRaw(0x0440));
    try std.testing.expectEqual(Variant.scd41, variantFromRaw(0x1440));
    try std.testing.expectEqual(Variant.scd43, variantFromRaw(0x5441));
    try std.testing.expectEqual(Variant.unknown, variantFromRaw(0x4440));
}

test "encode saturating overflow/out-of-range policy" {
    try std.testing.expectEqual(@as(u16, 0x0000), tempToRaw(-100.0));
    try std.testing.expectEqual(@as(u16, 0xffff), tempToRaw(1.0e6));
    try std.testing.expectEqual(@as(u16, 0x0000), rhToRaw(-5.0));
    try std.testing.expectEqual(@as(u16, 0xffff), rhToRaw(150.0));
    try std.testing.expectEqual(@as(u16, 0xffff), pressureToRaw(0xffff * 100));
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
