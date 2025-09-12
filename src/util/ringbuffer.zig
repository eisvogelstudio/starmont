// ─────────────────────────────────────────────────────────────────────
//  Starmont - Version 0.1.0
//  Copyright (C) 2025 Eisvogel Studio
//  Contact: eisvogelstudio@protonmail.com
//  Repository: https://github.com/eisvogelstudio/starmont
//
//  Author: Felix Koppe (fkoppe@web.de)
//
//  All rights reserved. This source code is publicly accessible for
//  reference purposes. Forking and cloning for personal, non-commercial
//  use is permitted, but modification, redistribution, or commercial
//  use without explicit written permission is strictly prohibited.
//
//  See LICENSE for details.
// ─────────────────────────────────────────────────────────────────────

// ---------- zig ----------
const std = @import("std");
// -------------------------

pub fn RingBuffer(comptime T: type) type {
    return struct {
        const Self = @This();

        alloc: std.mem.Allocator,
        buf: []T = &[_]T{},
        head: usize = 0,
        len: usize = 0,

        pub fn init(alloc: std.mem.Allocator, initial_capacity: usize) !Self {
            var self = Self{ .alloc = alloc };
            if (initial_capacity > 0) {
                try self.growTo(nextPow2(initial_capacity));
            }
            return self;
        }

        pub fn deinit(self: *Self) void {
            if (self.buf.len != 0) self.alloc.free(self.buf);
            self.* = undefined;
        }

        pub fn clear(self: *Self) void {
            self.head = 0;
            self.len = 0;
        }

        pub fn capacity(self: *const Self) usize {
            return self.buf.len;
        }
        pub fn count(self: *const Self) usize {
            return self.len;
        }
        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }

        pub fn pushBack(self: *Self, value: T) !void {
            try self.ensureUnused(1);
            const tail = (self.head + self.len) % self.buf.len;
            self.buf[tail] = value;
            self.len += 1;
        }

        pub fn pushSlice(self: *Self, values: []const T) !void {
            if (values.len == 0) return;
            try self.ensureUnused(values.len);
            const tail = (self.head + self.len) % self.buf.len;
            const first = @min(values.len, self.buf.len - tail);
            std.mem.copy(T, self.buf[tail .. tail + first], values[0..first]);
            const rest = values.len - first;
            if (rest > 0) {
                std.mem.copy(T, self.buf[0..rest], values[first..]);
            }
            self.len += values.len;
        }

        pub fn popFront(self: *Self) ?T {
            if (self.len == 0) return null;
            const v = self.buf[self.head];
            self.head = (self.head + 1) % self.buf.len;
            self.len -= 1;
            return v;
        }

        pub fn peekFront(self: *const Self) ?*const T {
            if (self.len == 0) return null;
            return &self.buf[self.head];
        }

        pub fn ensureUnused(self: *Self, additional: usize) !void {
            const need = self.len + additional;
            if (need <= self.buf.len) return;
            const target = nextPow2(@max(need, self.buf.len * 2));
            try self.growTo(target);
        }

        fn growTo(self: *Self, new_cap: usize) !void {
            std.debug.assert(new_cap >= self.len and new_cap != 0);
            var new_buf = try self.alloc.alloc(T, new_cap);

            if (self.len > 0) {
                const head = self.head;
                const cap = self.buf.len;

                const first = @min(self.len, if (cap == 0) self.len else cap - head);
                if (first > 0) {
                    std.mem.copy(T, new_buf[0..first], self.buf[head .. head + first]);
                }
                const rest = self.len - first;
                if (rest > 0) {
                    std.mem.copy(T, new_buf[first .. first + rest], self.buf[0..rest]);
                }
            }

            if (self.buf.len != 0) self.alloc.free(self.buf);
            self.buf = new_buf;
            self.head = 0;
        }

        fn nextPow2(x: usize) usize {
            var v: usize = if (x < 1) 1 else x;
            v -= 1;
            v |= v >> 1;
            v |= v >> 2;
            v |= v >> 4;
            v |= v >> 8;
            v |= v >> 16;
            if (@sizeOf(usize) == 8) {
                v |= v >> 32;
            }
            return v + 1;
        }
    };
}
