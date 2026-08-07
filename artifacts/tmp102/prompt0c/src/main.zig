const std = @import("std");
const tmp102 = @import("prompt0c");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [256]u8 = undefined;
    var out = std.Io.File.Writer.init(.stdout(), io, &buf);
    const w = &out.interface;

    // Demonstrate the canonical conversions for 21.0 C.
    const reg: u16 = tmp102.encodeTempNormal(21.0);
    const bytes = tmp102.wordToBytes(reg);
    const rc: f32 = tmp102.decodeTempNormal(reg);
    try w.print("21.0 C -> register 0x{X:0>4} (bytes {X:0>2} {X:0>2}), decoded {d:.2} C\n", .{
        reg,
        bytes[0],
        bytes[1],
        rc,
    });
    try w.flush();
}