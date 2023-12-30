    const std = @import("std");
    pub fn build(b: *std.build.Builder) void {
         const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});
        const game = b.addExecutable(.{
            .name = "game",
            .root_source_file = .{ .path = "src/game.zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(game);
        const pack_tool = b.addExecutable(.{
            .name = "pack",
            .root_source_file = .{ .path = "tools/pack.zig" },
            .target = target,
            .optimize = optimize,
        });
        
        const precompilation = b.addRunArtifact(pack_tool);
        precompilation.addArtifactArg(game);
        precompilation.addArg("assets.zip");

        const pack_step = b.step("pack", "Packs the game and assets together");
        pack_step.dependOn(&precompilation.step);
    }