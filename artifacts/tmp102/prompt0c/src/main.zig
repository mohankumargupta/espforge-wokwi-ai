const std = @import("std");
const Io = std.Io;

const tmp102 = @import("prompt0c");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();
    _ = arena;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), init.io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try stdout_writer.print("TMP102 data-conversion reference\n", .{});
    try stdout_writer.print("  reset config:  0x{x}\n", .{tmp102.CONFIG_RESET});
    try stdout_writer.print("  0x1900 -> {d} C (normal)\n", .{tmp102.decodeTempNormal(0x1900)});
    try stdout_writer.print("  25 C    -> 0x{x} (normal)\n", .{tmp102.encodeTempNormal(25.0)});
    try stdout_writer.print("  -55 C   -> 0x{x} (extended)\n", .{tmp102.encodeTempExtended(-55.0)});
    try stdout_writer.print("  4 Hz rate field: 0b{b:0>2}\n", .{tmp102.conversionRateField(tmp102.CONFIG_RESET)});

    try stdout_writer.flush();
}

test {
    std.testing.refAllDecls(@This());
}