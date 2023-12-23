# 状态 12.23/2023

工作进展：

1. zig build explain 共三个部分，我已经翻译完成第一部分
2. 代码已经升级到0.11

下一步：
1. 可以发布第一部分，或者晚点全部做完，然后一起发布
2. 到时候是发给群主，还是github做PR？

# zigcc

译者改动过所有代码；因为版本变化（~0.7.0 - 0.11.0）

## 类型汇总

1.  standardReleaseOptions > standardOptimizeOption
        const mode = b.standardOptimizeOption(.{});
        // 译者reco
        // const mode = b.standardReleaseOptions();
2. addExecutable 参数变化

     // 译者reco
        const exe = b.addExecutable(.{
            .name = "upload-review",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = target,
            .optimize = mode,
        });
        // const exe = b.addExecutable("upload-review", "src/main.zig");
3. addCSourceFile参数变化
            // 译者reco
            exe.addCSourceFile(.{.file = std.build.LazyPath.relative("review-parser.c"), .flags = &.{}});
            // exe.addCSourceFile("review-parser.c", &[_][]const u8{});

3. package - module
            // 译者reco
            const ap = b.createModule(.{.source_file = .{ .path = "vendor/zig-args/args.zig" },.dependencies = &.{},});
            exe.addModule("args-parser",ap);
            // exe.addPackage(.{
            //     .name = "args-parser",
            //     .source = .{ .path = "vendor/zig-args/args.zig" },
            // });
4. 函数名称和参数变化 addIncludeDir - addIncludePath
            // 译者reco
            exe.addIncludePath(std.build.LazyPath.relative("vendor/libcurl/include"));
            // exe.addIncludeDir("vendor/libcurl/include");
5. 函数参数变化 addObjectFile
            exe.addObjectFile(std.build.LazyPath.relative("vendor/libcurl/lib/libcurl.a"));
            // exe.addObjectFile("vendor/libcurl/lib/libcurl.a");
6. 函数改变方式
            b.installArtifact(exe);
            // exe.install();
7. 函数名称和参数变化     addTest    
            
           const test_suite = b.addTest(
                .{
                // .name = "upload-review",
                .root_source_file = .{ .path = "src/tests.zig" },
                // .target = target,
                // .optimize = mode,
            });
            // const test_suite = b.addTest("src/tests.zig");
8. 使用函数变化            
            // 译者reco
            const bundle_app = b.addRunArtifact(deploy_tool);
            // const bundle_app = deploy_tool.run();
            