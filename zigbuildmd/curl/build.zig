
    const std = @import("std");

    pub fn build(b: *std.Build) void {
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});
        const exe = b.addExecutable(.{
            .name = "example",
            // 这块调试了很久。最后的结论是根本不要写
            // .root_source_file = .{ .path = undefined },
            .target = target,
            .optimize = optimize,
        });
        exe.addCSourceFile(.{
            .file = std.build.LazyPath.relative("main.c"), 
            .flags = &.{}
            });
        exe.linkLibC();
        //  不是libcurl而是curl。这个也是调试了不太久的时间
        exe.linkSystemLibrary("curl");

     
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

