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

test "mapOr" {
    const function = struct {
        fn map(x: []const u8) usize {
            return x.len;
        }
    };

    const a = Option([]const u8).Some("foo");
    try @import("std").testing.expectEqual(a.mapOr(usize, 42, function.map), 3);

    const b = Option([]const u8).None();
    try @import("std").testing.expectEqual(b.mapOr(usize, 42, function.map), 42);
}

test "mapOrElse" {
    const function = struct {
        fn map(x: []const u8) usize {
            return x.len;
        }

        fn @"else"() usize {
            return 2 * 21;
        }
    };

    const a = Option([]const u8).Some("foo");
    try @import("std").testing.expectEqual(a.mapOrElse(usize, function.@"else", function.map), 3);

    const b = Option([]const u8).None();
    try @import("std").testing.expectEqual(b.mapOrElse(usize, function.@"else", function.map), 42);
}

test "and" {
    {
        const a = Option(u32).Some(2);
        const b = Option([]const u8).None();
        try @import("std").testing.expectEqual(a.@"and"([]const u8, b), Option([]const u8).None());
    }
    
    {
        const a = Option(u32).None();
        const b = Option([]const u8).Some("foo");
        try @import("std").testing.expectEqual(a.@"and"([]const u8, b), Option([]const u8).None());
    }

    {
        const a = Option(u32).Some(2);
        const b = Option([]const u8).Some("foo");
        try @import("std").testing.expectEqual(a.@"and"([]const u8, b), Option([]const u8).Some("foo"));
    }

    {
        const a = Option(u32).None();
        const b = Option([]const u8).None();
        try @import("std").testing.expectEqual(a.@"and"([]const u8, b), Option([]const u8).None());
    }
}

test "andThen" {
    const function = struct {
        fn andThen(x: u32) Option([]const u8) {
            if (x > 2) {
                return Option([]const u8).None();
            } else {
                return Option([]const u8).Some("ok");
            }
        }
    };

    try @import("std").testing.expectEqual(Option(u32).Some(2).andThen([]const u8, function.andThen), Option([]const u8).Some("ok"));
    
    try @import("std").testing.expectEqual(Option(u32).Some(1_000_000).andThen([]const u8, function.andThen), Option([]const u8).None());

    try @import("std").testing.expectEqual(Option(u32).None().andThen([]const u8, function.andThen), Option([]const u8).None());
}

test "filter" {
    const function = struct {
        fn isEven(x: *const u32) bool {
            return x.* % 2 == 0;
        }
    };

    try @import("std").testing.expectEqual(Option(u32).None().filter(function.isEven), Option(u32).None());

    try @import("std").testing.expectEqual(Option(u32).Some(3).filter(function.isEven), Option(u32).None());
    
    try @import("std").testing.expectEqual(Option(u32).Some(4).filter(function.isEven), Option(u32).Some(4));
}

test "or" {
    {
        const a = Option(u32).Some(2);
        const b = Option(u32).None();
        try @import("std").testing.expectEqual(a.@"or"(b), Option(u32).Some(2));
    }

    {
        const a = Option(u32).None();
        const b =  Option(u32).Some(100);
        try @import("std").testing.expectEqual(a.@"or"(b), Option(u32).Some(100));
    }

    {
        const a = Option(u32).Some(2);
        const b =  Option(u32).Some(100);
        try @import("std").testing.expectEqual(a.@"or"(b), Option(u32).Some(2));
    }

    {
        const a = Option(u32).None();
        const b =  Option(u32).None();
        try @import("std").testing.expectEqual(a.@"or"(b), Option(u32).None());
    }
}

test "orElse" {
    const function = struct {
        fn vikings() Option([]const u8) {
            return Option([]const u8).Some("vikings");
        }

        fn nobody() Option([]const u8) {
            return Option([]const u8).None();
        }
    };

    try @import("std").testing.expectEqual(Option([]const u8).Some("barbarians").orElse(function.vikings), Option([]const u8).Some("barbarians"));
    
    try @import("std").testing.expectEqual(Option([]const u8).None().orElse(function.vikings), Option([]const u8).Some("vikings"));

    try @import("std").testing.expectEqual(Option([]const u8).None().orElse(function.nobody), Option([]const u8).None());
}
