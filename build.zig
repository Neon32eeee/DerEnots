const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const optimize = b.standardOptimizeOption(.{});

    // ← Вот здесь НЕ используем .linkage = .dynamic
    const wasm = b.addExecutable(.{
        .name = "game",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/beckend/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    wasm.initial_memory = 65536 * 100;
    wasm.rdynamic = true;

    wasm.entry = .disabled;
    wasm.rdynamic = true;

    b.installArtifact(wasm);
}
