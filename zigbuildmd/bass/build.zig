 const std = @import("std");

    pub fn build(b: *std.Build) void {
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});
         const use_platform_io = b.option(bool, "platform-io", "Uses the native api instead of the C wrapper") orelse true;
        const exe = b.addExecutable(.{
            .name = "example",
            .target = target,
            .optimize = optimize,
        });
         var sources = std.ArrayList([]const u8).init(b.allocator);

        // Search for all C/C++ files in `src` and add them
        {
            var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });

            var walker = try dir.walk(b.allocator);
            defer walker.deinit();

            const allowed_exts = [_][]const u8{ ".c", ".cpp", ".cxx", ".c++", ".cc" };
            while (try walker.next()) |entry| {
                const ext = std.fs.path.extension(entry.basename);
                const include_file = for (allowed_exts) |e| {
                    if (std.mem.eql(u8, ext, e))
                        break true;
                } else false;
                if (include_file) {
                    // we have to clone the path as walker.next() or walker.deinit() will override/kill it
                    try sources.append(b.dupe(entry.path));
                }
            }
        }

        exe.addCSourceFiles(.{
            .file = std.build.LazyPath.relative("print-main.c"), 
            .flags = &.{}
            });
        
         exe.linkLibC();

            b.installArtifact(exe);
            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }
            const run_step = b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
    }