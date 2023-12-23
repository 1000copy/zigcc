
    const std = @import("std");

    pub fn build(b: *std.build.Builder) void {
        _ = b.step("step-name", "This is what is shown in help");
    }