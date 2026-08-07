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

    // Host-native unit-test step for the register-conversion helpers in
    // chip.zig. The stock asset build script shipped without a `test` step;
    // the skill mandates `zig build test` to pass, so we register one here.
    // chip.zig gates its Wokwi-ABI code behind `!builtin.is_test`, so the same
    // file compiles cleanly on the host for testing while still emitting the
    // WASM chip binary above.
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

