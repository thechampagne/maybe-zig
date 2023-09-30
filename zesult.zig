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
