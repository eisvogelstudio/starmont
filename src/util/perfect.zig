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

pub fn PerfectStringMap(comptime keys_input: []const []const u8) type {
    comptime {
        const n = keys_input.len;

        var key_list: [n][]const u8 = undefined;
        var values: [n]usize = undefined;
        var seed: u32 = 0;

        while (true) : (seed += 1) {
            var slots: [n]?usize = .{null} ** n;
            var collision = false;

            for (keys_input, 0..) |key, i| {
                const h = std.hash.Murmur3_32.hashWithSeed(key, seed) % n;
                if (slots[h] != null) {
                    collision = true;
                    break;
                }
                slots[h] = i;
            }

            if (!collision) {
                for (slots, 0..) |opt_i, i| {
                    if (opt_i) |idx| {
                        key_list[i] = keys_input[idx];
                        values[i] = idx;
                    }
                }
                break;
            }

            if (seed == std.math.maxInt(u32)) {
                @compileError("Failed to build perfect hash map");
            }
        }

        return struct {
            const Self = @This();
            pub const keys = key_list;
            pub const final_seed = seed;

            pub fn getId(key: []const u8) ?usize {
                const i = std.hash.Murmur3_32.hashWithSeed(key, final_seed) % n;
                if (std.mem.eql(u8, key, keys[i])) return values[i];
                return null;
            }

            pub fn has(key: []const u8) bool {
                return getId(key) != null;
            }

            pub fn getString(i: usize) []const u8 {
                return keys[i];
            }

            pub fn count() usize {
                return n;
            }
        };
    }
}

const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;

test "PerfectStringMap basic functionality" {
    const MyMap = PerfectStringMap(&[_][]const u8{
        "apple",
        "banana",
        "carrot",
    });

    try expect(MyMap.count() == 3);
    try expect(MyMap.has("apple"));
    try expect(MyMap.has("banana"));
    try expect(MyMap.has("carrot"));
    try expect(!MyMap.has("pear"));

    const id_apple = MyMap.getId("apple") orelse return error.TestFail;
    const id_banana = MyMap.getId("banana") orelse return error.TestFail;
    const id_carrot = MyMap.getId("carrot") orelse return error.TestFail;

    try expect(MyMap.getString(id_apple).len > 0);
    try expectEqualStrings("apple", MyMap.getString(id_apple));
    try expectEqualStrings("banana", MyMap.getString(id_banana));
    try expectEqualStrings("carrot", MyMap.getString(id_carrot));

    // IDs müssen eindeutig sein
    try expect(id_apple != id_banana);
    try expect(id_banana != id_carrot);
    try expect(id_apple != id_carrot);
}
