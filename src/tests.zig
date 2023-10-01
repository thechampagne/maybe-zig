const Option = @import("maybe.zig").Option;

test "isSome" {
    const a: Option(u32) = .{ .some = 2};
    try @import("std").testing.expectEqual(a.isSome(), true);
    
    const b: Option(u32) = .{ .none = {}};
    try @import("std").testing.expectEqual(b.isSome(), false);
}

test "isSomeAnd" {
    const function = struct {
        fn predicate(x: u32) bool {
            return x > 1;
        }
    };
    
    const a: Option(u32) = .{ .some = 2};
    try @import("std").testing.expectEqual(a.isSomeAnd(function.predicate), true);
    
    const b: Option(u32) = .{ .some = 0};
    try @import("std").testing.expectEqual(b.isSomeAnd(function.predicate), false);

    const c: Option(u32) = .{ .none = {}};
    try @import("std").testing.expectEqual(c.isSomeAnd(function.predicate), false);
}

test "isNone" {
    const a: Option(u32) = .{ .some = 2};
    try @import("std").testing.expectEqual(a.isNone(), false);
    
    const b: Option(u32) = .{ .none = {}};
    try @import("std").testing.expectEqual(b.isNone(), true);
}

test "expect" {
    const a: Option([]const u8) = .{ .some = "value"};
    try @import("std").testing.expectEqual(a.expect("fruits are healthy"), "value");
}

test "unwrap" {
    const a: Option([]const u8) = .{ .some = "air"};
    try @import("std").testing.expectEqual(a.unwrap(), "air");
}

test "unwrapOr" {
    try @import("std").testing.expectEqual(Option([]const u8).Some("car").unwrapOr("bike"), "car");
    
    try @import("std").testing.expectEqual(Option([]const u8).None().unwrapOr("bike"), "bike");
}

test "unwrapOrElse" {
    const function = struct {
        fn orElse() u32 {
            return 2 * 10;
        }
    };
    
    try @import("std").testing.expectEqual(Option(u32).Some(4).unwrapOrElse(function.orElse), 4);

    try @import("std").testing.expectEqual(Option(u32).None().unwrapOrElse(function.orElse), 20);
}

test "unwrapUnchecked" {
    const a: Option([]const u8) = .{ .some = "air"};
    try @import("std").testing.expectEqual(a.unwrapUnchecked(), "air");
}

test "map" {
    const function = struct {
        fn map(x: []const u8) usize {
            return x.len;
        }
    };

    const a: Option([]const u8) = .{ .some = "Hello, World!"};
    try @import("std").testing.expectEqual(a.map(usize, function.map), Option(usize).Some(13));

    const b: Option([]const u8) = .{ .none = {}};
    try @import("std").testing.expectEqual(b.map(usize, function.map), Option(usize).None());
}

test "inspect" {
    const function = struct {
        fn inspect(x: *const u32) void {
            @import("std").debug.print("got: {}\n", .{x.*});
        }
    };

    _ = Option(u32).Some(4).inspect(function.inspect);

    _ = Option(u32).None().inspect(function.inspect);
}
