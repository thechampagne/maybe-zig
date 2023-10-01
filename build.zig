const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("maybe", .{
        .source_file = .{ .path = "src/maybe.zig" },
        .dependencies = &[_]std.Build.ModuleDependency{},
    });
}
