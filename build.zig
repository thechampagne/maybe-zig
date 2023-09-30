const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("zesult", .{
        .source_file = .{ .path = "zesult.zig" },
        .dependencies = &[_]std.Build.ModuleDependency{},
    });
}
