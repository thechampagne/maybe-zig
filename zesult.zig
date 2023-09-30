pub fn Option(comptime T: type) type {
    return union(enum) {
        some: T,
        none,

        const Self = @This();

        pub inline fn None() Self {
            return .{ .none = {}}; 
        }

        pub inline fn Some(value: T) Self {
            return .{ .some = value}; 
        }

        pub fn isSome(self: Self) bool {
            switch(self) {
                .some => return true,
                else => return false
            }
        }

        pub fn isSomeAnd(self: Self, f: *const fn(T) bool) bool {
            switch(self) {
                .some => |v| return f(v),
                else => return false
            }
        }

        pub fn isNone(self: Self) bool {
            switch(self) {
                .none => return true,
                else => return false
            }
        }

        pub fn expect(self: Self, msg: []const u8) T {
            switch(self) {
                .some => |v| return v,
                else => @panic(msg)
            }
        }

        pub fn unwrap(self: Self) T {
            switch(self) {
                .some => |v| return v,
                else => @panic("called `Option.unwrap()` on a `none` value")
            }
        }

        pub fn unwrapOr(self: Self, default: T) T {
            switch(self) {
                .some => |v| return v,
                else => return default
            }
        }
        
    };
}

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
