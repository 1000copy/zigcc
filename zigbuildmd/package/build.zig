 const std = @import("std");

    pub fn build(b: *std.Build) void {
        const args =  b.createModule(.{
                .source_file = .{ .path = "libs/args/args.zig" },
                .dependencies = &.{},
            });

            const interface = b.createModule(.{
                .source_file = .{ .path = "libs/interface.zig/interface.zig" },
                .dependencies = &.{},
            });

            const lola = b.createModule(.{
                .source_file = .{ .path = "src/library/main.zig" },
                .dependencies = &.{},
            });
        const pkgs = .{
            .args = args,

            .interface = interface,

            .lola = lola,
        };
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});
        const exe = b.addExecutable(.{
            .name = "test",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = target,
            .optimize = optimize,
        });
        exe.addModule("lola",pkgs.lola);
        exe.addModule("args",pkgs.args);
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

    }

// b.createModule(.{
//     .source_file = .{ .path = "src/library/main.zig" },
//     .dependencies = &.{},
// });