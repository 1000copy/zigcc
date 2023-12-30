const std = @import("std");

    pub fn build(b: *std.build.Builder) void {
        const mode = b.standardOptimizeOption(.{});
        // 译者reco
        // const mode = b.standardReleaseOptions();
        
        const target = b.standardTargetOptions(.{});

        // Generates the lex-based parser
        const parser_gen = b.addSystemCommand(&[_][]const u8{
            "flex",
            "--outfile=review-parser.c",
            "review-parser.l",
        });

        // Our application
        // 译者reco
        const exe = b.addExecutable(.{
            .name = "upload-review",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = target,
            .optimize = mode,
        });
        // const exe = b.addExecutable("upload-review", "src/main.zig");
        {
            exe.step.dependOn(&parser_gen.step);
            // 译者reco
            exe.addCSourceFile(.{.file = std.build.LazyPath.relative("review-parser.c"), .flags = &.{}});
            // exe.addCSourceFile("review-parser.c", &[_][]const u8{});

            // add zig-args to parse arguments
            // 译者reco
            const ap = b.createModule(.{.source_file = .{ .path = "vendor/zig-args/args.zig" },.dependencies = &.{},});
            exe.addModule("args-parser",ap);
            // exe.addPackage(.{
            //     .name = "args-parser",
            //     .source = .{ .path = "vendor/zig-args/args.zig" },
            // });
            // 译者reco
            // add libcurl for uploading
            exe.addIncludePath(std.build.LazyPath.relative("vendor/libcurl/include"));
            // exe.addIncludeDir("vendor/libcurl/include");
            exe.addObjectFile(std.build.LazyPath.relative("vendor/libcurl/lib/libcurl.a"));
            // exe.addObjectFile("vendor/libcurl/lib/libcurl.a");

            // exe.optimize(mode);
            // exe.setTarget(target);
            exe.linkLibC();
            b.installArtifact(exe);
            // exe.install();
        }

        // Our test suite
        const test_step = b.step("test", "Runs the test suite");
            // 译者reco 
           const test_suite = b.addTest(
                .{
                // .name = "upload-review",
                .root_source_file = .{ .path = "src/tests.zig" },
                // .target = target,
                // .optimize = mode,
            });
            // const test_suite = b.addTest("src/tests.zig");
            test_suite.step.dependOn(&parser_gen.step);
            // 译者reco
            exe.addCSourceFile(.{.file = std.build.LazyPath.relative("review-parser.c"), .flags = &.{}});
            // test_suite.addCSourceFile("review-parser.c", &[_][]const u8{});

            // add libcurl for uploading
            exe.addIncludePath(std.build.LazyPath.relative("vendor/libcurl/include"));
            exe.addObjectFile(std.build.LazyPath.relative("vendor/libcurl/lib/libcurl.a"));
            // 译者reco
            // test_suite.addIncludeDir("vendor/libcurl/include");
            // test_suite.addObjectFile("vendor/libcurl/lib/libcurl.a");

            test_suite.linkLibC();

            test_step.dependOn(&test_suite.step);
        

        {   const deploy_step = b.step("deploy", "Creates an application bundle");
        
            // compile the app bundler
            const deploy_tool = b.addExecutable(.{
                .name = "deploy",
                .root_source_file = .{ .path = "tools/deploy.zig" },
                .target = target,
                .optimize = mode,
            });
            // 译者reco
            // const deploy_tool = b.addExecutable("deploy", "tools/deploy.zig");
            {
                deploy_tool.linkLibC();
                deploy_tool.linkSystemLibrary("libzip");
            }
            // 译者reco
            const bundle_app = b.addRunArtifact(deploy_tool);
            // const bundle_app = deploy_tool.run();
            bundle_app.addArg("app-bundle.zip");
            bundle_app.addArtifactArg(exe);
            bundle_app.addArg("resources/index.htm");
            bundle_app.addArg("resources/style.css");

            deploy_step.dependOn(&bundle_app.step);
        }
    }