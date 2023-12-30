    const std = @import("std");
    pub fn build(b: *std.build.Builder) !void {
        var sources = std.ArrayList([]const u8).init(b.allocator);

        // Search for all C/C++ files in `src` and add them
        {
            // 此处有改动，也是因为API的变化，也需要看std的代码才可以
            // var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
            var dir = try std.fs.cwd().openIterableDir(".", .{ .access_sub_paths = true });

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
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});
        const exe = b.addExecutable(.{
            .name = "example",
            // 这块调试了很久。最后的结论是根本不要写
            // .root_source_file = .{ .path = undefined },
            .target = target,
            .optimize = optimize,
        });
        exe.addCSourceFiles(sources.items, &.{});
        exe.linkLibC();
        b.installArtifact(exe);
    }
    