const std = @import("std");

const LSB_CELSIUS: f32 = 0.0625;
const RAW_PER_CELSIUS: f32 = 16.0;

pub const Addr0 = enum(u2) { gnd = 0, vplus = 1, sda = 2, scl = 3 };
pub const PointerReg = enum(u2) { temperature = 0, config = 1, tlow = 2, thigh = 3 };
pub const ThermostatMode = enum(u1) { comparator = 0, interrupt = 1 };

pub const config_reset: u16 = 0x6080;
pub const tlow_reset_c: f32 = 75.0;
pub const thigh_reset_c: f32 = 80.0;

fn signExtend12(v: u12) i16 {
    return @as(i16, @bitCast(@as(u16, v) << 4)) >> 4;
}

fn signExtend13(v: u13) i16 {
    return @as(i16, @bitCast(@as(u16, v) << 3)) >> 3;
}

pub fn raw12ToCelsius(v: u12) f32 {
    return @as(f32, @floatFromInt(signExtend12(v))) * LSB_CELSIUS;
}

pub fn raw13ToCelsius(v: u13) f32 {
    return @as(f32, @floatFromInt(signExtend13(v))) * LSB_CELSIUS;
}

pub fn celsiusToRaw12(deg: f32) i12 {
    const raw: i32 = @intFromFloat(@round(deg * RAW_PER_CELSIUS));
    return @intCast(std.math.clamp(raw, std.math.minInt(i12), std.math.maxInt(i12)));
}

pub fn celsiusToRaw13(deg: f32) i13 {
    const raw: i32 = @intFromFloat(@round(deg * RAW_PER_CELSIUS));
    return @intCast(std.math.clamp(raw, std.math.minInt(i13), std.math.maxInt(i13)));
}

pub fn registerToCelsius(reg: u16) f32 {
    if (reg & 0x0001 == 0) {
        return raw12ToCelsius(@intCast(reg >> 4));
    } else {
        return raw13ToCelsius(@intCast(reg >> 3));
    }
}

pub fn celsiusToRegister12(deg: f32) u16 {
    const raw: i12 = celsiusToRaw12(deg);
    const bits: u12 = @bitCast(raw);
    return @as(u16, bits) << 4;
}

pub fn celsiusToRegister13(deg: f32) u16 {
    const raw: i13 = celsiusToRaw13(deg);
    const bits: u13 = @bitCast(raw);
    return (@as(u16, bits) << 3) | 0x0001;
}

pub fn registerToMilliC12(reg: u16) i32 {
    const raw: i16 = signExtend12(@intCast(reg >> 4));
    return @divTrunc(@as(i32, raw) * 1000, 16);
}

pub fn registerToMilliC13(reg: u16) i32 {
    const raw: i16 = signExtend13(@intCast(reg >> 3));
    return @divTrunc(@as(i32, raw) * 1000, 16);
}

pub fn milliCToRaw12(mc: i32) i12 {
    const raw: i32 = @divTrunc(mc * 16, 1000);
    return @intCast(std.math.clamp(raw, std.math.minInt(i12), std.math.maxInt(i12)));
}

pub fn milliCToRaw13(mc: i32) i13 {
    const raw: i32 = @divTrunc(mc * 16, 1000);
    return @intCast(std.math.clamp(raw, std.math.minInt(i13), std.math.maxInt(i13)));
}

pub fn i2cAddress(add0: Addr0) u8 {
    return 0x48 + @as(u8, @intFromEnum(add0));
}

pub fn decodePointer(p: u8) PointerReg {
    return @enumFromInt(p & 0x03);
}

pub const Config = struct {
    os: bool,
    resolution: u2,
    fault_queue: u2,
    pol: bool,
    tm: bool,
    sd: bool,
    cr: u2,
    al: bool,
    em: bool,

    pub fn decode(reg: u16) Config {
        return .{
            .os = (reg >> 15) & 1 == 1,
            .resolution = @intCast((reg >> 13) & 0x3),
            .fault_queue = @intCast((reg >> 11) & 0x3),
            .pol = (reg >> 10) & 1 == 1,
            .tm = (reg >> 9) & 1 == 1,
            .sd = (reg >> 8) & 1 == 1,
            .cr = @intCast((reg >> 6) & 0x3),
            .al = (reg >> 5) & 1 == 1,
            .em = (reg >> 4) & 1 == 1,
        };
    }

    pub fn encode(self: Config) u16 {
        var reg: u16 = 0;
        if (self.os) reg |= 0x8000;
        reg |= @as(u16, self.resolution) << 13;
        reg |= @as(u16, self.fault_queue) << 11;
        if (self.pol) reg |= 0x0400;
        if (self.tm) reg |= 0x0200;
        if (self.sd) reg |= 0x0100;
        reg |= @as(u16, self.cr) << 6;
        if (self.al) reg |= 0x0020;
        if (self.em) reg |= 0x0010;
        return reg;
    }
};

pub fn conversionRateHz(cr: u2) f32 {
    return switch (cr) {
        0b00 => 0.25,
        0b01 => 1.0,
        0b10 => 4.0,
        0b11 => 8.0,
    };
}

pub fn faultQueueCount(fq: u2) u8 {
    return switch (fq) {
        0b00 => 1,
        0b01 => 2,
        0b10 => 4,
        0b11 => 6,
    };
}

pub fn resolutionBits(r: u2) u4 {
    return switch (r) {
        0b00 => 9,
        0b01 => 10,
        0b10 => 11,
        0b11 => 12,
    };
}

pub const AlertTracker = struct {
    mode: ThermostatMode,
    fault_queue: u2,
    alert: bool = false,
    armed: bool = true,
    above_high: u8 = 0,
    below_low: u8 = 0,

    pub fn init(mode: ThermostatMode, fault_queue: u2) AlertTracker {
        return .{ .mode = mode, .fault_queue = fault_queue };
    }

    pub fn queueCount(self: AlertTracker) u8 {
        return faultQueueCount(self.fault_queue);
    }

    pub fn onConversion(self: *AlertTracker, temp_c: f32, tlow_c: f32, thigh_c: f32) void {
        const n = self.queueCount();
        if (temp_c >= thigh_c) {
            self.above_high +|= 1;
            self.below_low = 0;
            const trigger = switch (self.mode) {
                .comparator => true,
                .interrupt => self.armed,
            };
            if (trigger and self.above_high >= n) {
                self.alert = true;
                self.above_high = 0;
                if (self.mode == .interrupt) self.armed = false;
            }
        } else if (temp_c <= tlow_c) {
            self.below_low +|= 1;
            self.above_high = 0;
            switch (self.mode) {
                .comparator => {
                    if (self.alert and self.below_low >= n) {
                        self.alert = false;
                        self.below_low = 0;
                    }
                },
                .interrupt => {
                    if (!self.armed and self.below_low >= n) {
                        self.armed = true;
                        self.below_low = 0;
                    }
                },
            }
        } else {
            self.above_high = 0;
            self.below_low = 0;
        }
    }

    pub fn onReadTemperature(self: *AlertTracker) void {
        if (self.mode == .interrupt and self.alert) {
            self.alert = false;
        }
    }

    pub fn alertPinLevel(self: AlertTracker, pol: bool) bool {
        return if (pol) self.alert else !self.alert;
    }
};

pub fn main() !void {
    std.debug.print("TMP102 data-conversion reference. Run `zig build test`.\n", .{});
}

test "spec conversion examples 12-bit" {
    try std.testing.expectEqual(@as(i12, 800), celsiusToRaw12(50.0));
    try std.testing.expectEqual(@as(i12, 400), celsiusToRaw12(25.0));
    try std.testing.expectEqual(@as(i12, 4), celsiusToRaw12(0.25));
    try std.testing.expectEqual(@as(i12, -400), celsiusToRaw12(-25.0));
    try std.testing.expectEqual(@as(i12, -4), celsiusToRaw12(-0.25));
    try std.testing.expectEqual(@as(u12, 0x320), @as(u12, @bitCast(celsiusToRaw12(50.0))));
    try std.testing.expectEqual(@as(u12, 0x190), @as(u12, @bitCast(celsiusToRaw12(25.0))));
    try std.testing.expectEqual(@as(u12, 0x004), @as(u12, @bitCast(celsiusToRaw12(0.25))));
    try std.testing.expectEqual(@as(u12, 0xE70), @as(u12, @bitCast(celsiusToRaw12(-25.0))));
    try std.testing.expectEqual(@as(u12, 0xFFC), @as(u12, @bitCast(celsiusToRaw12(-0.25))));
}

test "raw12ToCelsius decodes two's complement" {
    try std.testing.expectApproxEqAbs(@as(f32, 50.0), raw12ToCelsius(0x320), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 25.0), raw12ToCelsius(0x190), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0.25), raw12ToCelsius(0x004), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -25.0), raw12ToCelsius(0xE70), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -0.25), raw12ToCelsius(0xFFC), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), raw12ToCelsius(0x000), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 127.9375), raw12ToCelsius(0x7FF), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -128.0), raw12ToCelsius(0x800), 1e-6);
}

test "celsiusToRegister12 left-aligns into register" {
    try std.testing.expectEqual(@as(u16, 0x3200), celsiusToRegister12(50.0));
    try std.testing.expectEqual(@as(u16, 0x4B00), celsiusToRegister12(75.0));
    try std.testing.expectEqual(@as(u16, 0x5000), celsiusToRegister12(80.0));
    try std.testing.expectEqual(@as(u16, 0x0040), celsiusToRegister12(0.25));
    try std.testing.expectEqual(@as(u16, 0xE700), celsiusToRegister12(-25.0));
    try std.testing.expectEqual(@as(u16, 0xFFC0), celsiusToRegister12(-0.25));
    try std.testing.expectEqual(@as(u16, 0), celsiusToRegister12(0.0));
}

test "registerToCelsius round trips and normal/extended detection" {
    try std.testing.expectApproxEqAbs(@as(f32, 50.0), registerToCelsius(0x3200), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -25.0), registerToCelsius(0xE700), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), registerToCelsius(0x0000), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 75.0), registerToCelsius(0x4B00), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 80.0), registerToCelsius(0x5000), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 50.0), registerToCelsius(0x1901), 1e-6);
}

test "extended 13-bit conversions" {
    try std.testing.expectEqual(@as(u16, 0x1901), celsiusToRegister13(50.0));
    try std.testing.expectEqual(@as(u16, 0x0A81), celsiusToRegister13(21.0));
    try std.testing.expectEqual(@as(u16, 0xF381), celsiusToRegister13(-25.0));
    try std.testing.expectApproxEqAbs(@as(f32, 50.0), raw13ToCelsius(0x320), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -25.0), raw13ToCelsius(0x1E70), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 50.0), registerToCelsius(0x1901), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 21.0), registerToCelsius(0x0A81), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -25.0), registerToCelsius(0xF381), 1e-6);
}

test "integer millidegree conversions" {
    try std.testing.expectEqual(@as(i32, 50000), registerToMilliC12(0x3200));
    try std.testing.expectEqual(@as(i32, -25000), registerToMilliC12(0xE700));
    try std.testing.expectEqual(@as(i32, 50000), registerToMilliC13(0x1901));
    try std.testing.expectEqual(@as(i32, -25000), registerToMilliC13(0xF381));
    try std.testing.expectEqual(@as(u16, 0x3200), celsiusToRegister12(@as(f32, @floatFromInt(registerToMilliC12(0x3200))) / 1000.0));
    try std.testing.expectEqual(@as(i12, -400), milliCToRaw12(-25000));
    try std.testing.expectEqual(@as(i13, -400), milliCToRaw13(-25000));
}

test "i2c address from ADD0 pin" {
    try std.testing.expectEqual(@as(u8, 0x48), i2cAddress(.gnd));
    try std.testing.expectEqual(@as(u8, 0x49), i2cAddress(.vplus));
    try std.testing.expectEqual(@as(u8, 0x4A), i2cAddress(.sda));
    try std.testing.expectEqual(@as(u8, 0x4B), i2cAddress(.scl));
}

test "pointer register decode uses P1:P0" {
    try std.testing.expectEqual(PointerReg.temperature, decodePointer(0x00));
    try std.testing.expectEqual(PointerReg.config, decodePointer(0x01));
    try std.testing.expectEqual(PointerReg.tlow, decodePointer(0x02));
    try std.testing.expectEqual(PointerReg.thigh, decodePointer(0x03));
    try std.testing.expectEqual(PointerReg.thigh, decodePointer(0xFF));
}

test "config register reset and field decode" {
    const reset = Config.decode(config_reset);
    try std.testing.expect(!reset.os);
    try std.testing.expectEqual(@as(u2, 0b11), reset.resolution);
    try std.testing.expectEqual(@as(u2, 0b00), reset.fault_queue);
    try std.testing.expect(!reset.pol);
    try std.testing.expect(!reset.tm);
    try std.testing.expect(!reset.sd);
    try std.testing.expectEqual(@as(u2, 0b10), reset.cr);
    try std.testing.expect(!reset.al);
    try std.testing.expect(!reset.em);
    try std.testing.expectEqual(@as(u16, 0x6080), reset.encode());

    const em_alert = Config.decode(0x60B0);
    try std.testing.expect(em_alert.al);
    try std.testing.expect(em_alert.em);
    try std.testing.expectEqual(@as(u2, 0b10), em_alert.cr);

    const shutdown = Config.decode(0x6180);
    try std.testing.expect(shutdown.sd);
    try std.testing.expectEqual(@as(u2, 0b10), shutdown.cr);
    try std.testing.expectEqual(@as(u16, 0x6180), shutdown.encode());
}

test "config field decoders" {
    try std.testing.expectApproxEqAbs(@as(f32, 0.25), conversionRateHz(0b00), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 1.0), conversionRateHz(0b01), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 4.0), conversionRateHz(0b10), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 8.0), conversionRateHz(0b11), 1e-6);
    try std.testing.expectEqual(@as(u8, 1), faultQueueCount(0b00));
    try std.testing.expectEqual(@as(u8, 2), faultQueueCount(0b01));
    try std.testing.expectEqual(@as(u8, 4), faultQueueCount(0b10));
    try std.testing.expectEqual(@as(u8, 6), faultQueueCount(0b11));
    try std.testing.expectEqual(@as(u4, 9), resolutionBits(0b00));
    try std.testing.expectEqual(@as(u4, 10), resolutionBits(0b01));
    try std.testing.expectEqual(@as(u4, 11), resolutionBits(0b10));
    try std.testing.expectEqual(@as(u4, 12), resolutionBits(0b11));
}

test "comparator mode alert with fault queue" {
    var t = AlertTracker.init(.comparator, 0b10);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(!t.alert);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(t.alert);
    try std.testing.expect(!t.alertPinLevel(false));
    try std.testing.expect(t.alertPinLevel(true));

    t.onConversion(70.0, tlow_reset_c, thigh_reset_c);
    t.onConversion(70.0, tlow_reset_c, thigh_reset_c);
    t.onConversion(70.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(t.alert);
    t.onConversion(70.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(!t.alert);
}

test "comparator single-fault queue" {
    var t = AlertTracker.init(.comparator, 0b00);
    t.onConversion(21.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(!t.alert);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(t.alert);
    t.onConversion(70.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(!t.alert);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(t.alert);
}

test "interrupt mode alert latches until register read and re-arms" {
    var t = AlertTracker.init(.interrupt, 0b00);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(t.alert);
    t.onReadTemperature();
    try std.testing.expect(!t.alert);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(!t.alert);
    t.onConversion(70.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(!t.alert);
    t.onConversion(85.0, tlow_reset_c, thigh_reset_c);
    try std.testing.expect(t.alert);
}
