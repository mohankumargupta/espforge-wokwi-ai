const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .abi = .none, // WebAssembly doesn't have a traditional ABI
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const exe = b.addExecutable(.{
        .name = "chip",
        .root_module = b.createModule(.{
            .root_source_file = b.path("chip.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.export_table = true;
    exe.rdynamic = true;
    exe.entry = .disabled;

    const install_step = b.addUpdateSourceFiles();
    install_step.addCopyFileToSource(exe.getEmittedBin(), "chip.wasm");
    b.getInstallStep().dependOn(&install_step.step);

    // Host-native unit-test step for chip.zig's register-encoding/decoding
    // helper functions. The chip itself must build for wasm32-freestanding,
    // which cannot run `zig build test` on the host — so this step compiles
    // the SAME chip.zig file for the native host target instead.
    //
    // chip.zig MUST gate all Wokwi-ABI code (extern fn imports, the exported
    // chipInit, and any pin/i2c/spi callbacks) behind a comptime flag so that
    // it compiles cleanly on the host with no unresolved wasm imports:
    //
    //     const builtin = @import("builtin");
    //     const chip_mode = !builtin.is_test;
    //
    //     comptime {
    //         if (chip_mode) {
    //             @export(&chipInit, .{ .name = "chipInit" });
    //         }
    //     }
    //
    //     fn chipInit() callconv(.c) void { ... }  // wasm-only, unreferenced in test builds+    //
    // With that gate in place, this same file exposes its pure conversion
    // functions and `test { ... }` blocks to the host test runner, while the
    // wasm chip.wasm build above remains untouched.
    const chip_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("chip.zig"),
            .target = b.resolveTargetQuery(.{}),
        }),
    });
    const run_chip_tests = b.addRunArtifact(chip_tests);
    const test_step = b.step("test", "Run chip.zig unit tests");
    test_step.dependOn(&run_chip_tests.step);



    // const mode = b.standardReleaseOptions();
    // const target: std.zig.CrossTarget = .{ .cpu_arch = .wasm32, .os_tag = .freestanding };

    // const lib = b.addSharedLibrary("chip_zig", "src/lib.zig", .unversioned);
    // lib.setTarget(target);
    // lib.setBuildMode(mode);
    // lib.addPackagePath("wokwi", "wokwi/wokwi_chip_ll.zig");
    // lib.export_table = true;
    // lib.install();
}

