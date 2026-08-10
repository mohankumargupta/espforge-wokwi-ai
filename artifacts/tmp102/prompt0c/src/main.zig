const std = @import("std");
const Io = std.Io;

const prompt0c = @import("prompt0c");

pub fn main(init: std.process.Init) !void {
    _ = init;
    // Prints worked examples to stderr, unbuffered, ignoring potential errors.
    std.debug.print("TMP102 data conversions\n", .{});
    std.debug.print("  +100 C Normal  -> word 0x{x:0>4} (decode back: {d})\n", .{
        prompt0c.encodeTempNormal(100.0),
        prompt0c.decodeTempNormal(prompt0c.encodeTempNormal(100.0)),
    });
    std.debug.print("  -25 C Normal   -> word 0x{x:0>4} (decode back: {d})\n", .{
        prompt0c.encodeTempNormal(-25.0),
        prompt0c.decodeTempNormal(prompt0c.encodeTempNormal(-25.0)),
    });
    std.debug.print("  +150 C Extend  -> word 0x{x:0>4} (decode back: {d})\n", .{
        prompt0c.encodeTempExtended(150.0),
        prompt0c.decodeTempExtended(prompt0c.encodeTempExtended(150.0)),
    });
    std.debug.print("  0x6400 msb/lsb -> {x:0>2} {x:0>2} (big-endian)\n", .{
        prompt0c.msbLsbFromWord(0x6400).msb,
        prompt0c.msbLsbFromWord(0x6400).lsb,
    });
}

test "config reset roundtrip through prompt0c module" {
    const cfg = prompt0c.Config.fromWord(0x60A0);
    try std.testing.expectEqual(prompt0c.ThermostatMode.comparator, cfg.thermostat_mode);
}

test "fuzz: encode then decode is a stable fixed point" {
    try std.testing.fuzz({}, fuzzRoundTrip, .{});
}

fn fuzzRoundTrip(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    while (!smith.eos()) {
        const bits: u32 = smith.value(u32);
        const temp: f32 = @bitCast(bits);
        // Idempotence: re-encoding a decoded value reproduces the same word.
        const word = prompt0c.encodeTempExtended(temp);
        const decoded = prompt0c.decodeTempExtended(word);
        try std.testing.expectEqual(word, prompt0c.encodeTempExtended(decoded));
    }
}