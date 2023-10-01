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

        pub fn unwrapOrElse(self: Self, f: *const fn() T) T {
            switch(self) {
                .some => |v| return v,
                else => return f()
            }
        }

        pub fn unwrapUnchecked(self: Self) T {
            return self.some;
        }

        pub fn map(self: Self, U: anytype, f: *const fn(T) U) Option(U) {
            switch(self) {
                .some => |v| return Option(U).Some(f(v)),
                else => return Option(U).None()
            }
        }

        pub fn inspect(self: *const Self, f: *const fn(*const T) void) Self {
            switch(self.*) {
                .some => |*v| f(v),
                else => {}
            }
            return self.*;
        }

        pub fn mapOr(self: Self, U: anytype, default: U, f: *const fn(T) U) U {
            switch(self) {
                .some => |v| return f(v),
                else => return default
            }
        }

        pub fn mapOrElse(self: Self, U: anytype, default: *const fn() U, f: *const fn(T) U) U {
            switch(self) {
                .some => |v| return f(v),
                else => return default()
            }
        }

        pub fn @"and"(self: Self, U: anytype, optb: Option(U)) Option(U) {
            switch(self) {
                .some => return optb,
                else => return Option(U).None()
            }
        }

        pub fn andThen(self: Self, U: anytype, f: *const fn(T) Option(U)) Option(U) {
            switch(self) {
                .some => |v| return f(v),
                else => return Option(U).None()
            }
        }

        pub fn filter(self: *const Self, f: *const fn(*const T) bool) Self {
            switch(self.*) {
                .some => |*v| if (f(v)) return self.* else self.None(),
                else => return self.*
            }
        }

        pub fn @"or"(self: Self, optb: Option(T)) Option(T) {
            switch(self) {
                .some => self,
                else => return optb
            }
        }

        pub fn orElse(self: Self, f: *const fn() Option(T)) Option(T) {
            switch(self) {
                .some => self,
                else => return f()
            }
        }
    };
}
