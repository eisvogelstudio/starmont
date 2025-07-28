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
        @setEvalBranchQuota(10_000);
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
                if (std.mem.eql(u8, key, keys[i])) return i;
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
    const TestMap = PerfectStringMap(&[_][]const u8{
        "apple",
        "banana",
        "pear",
    });

    try expect(TestMap.count() == 3);
    try expect(TestMap.has("apple"));
    try expect(TestMap.has("banana"));
    try expect(TestMap.has("pear"));
    try expect(!TestMap.has("carrot"));

    const id_apple = TestMap.getId("apple") orelse return error.TestFail;
    const id_banana = TestMap.getId("banana") orelse return error.TestFail;
    const id_pear = TestMap.getId("pear") orelse return error.TestFail;

    try expect(TestMap.getString(id_apple).len > 0);
    try expectEqualStrings("apple", TestMap.getString(id_apple));
    try expectEqualStrings("banana", TestMap.getString(id_banana));
    try expectEqualStrings("pear", TestMap.getString(id_pear));

    // IDs müssen eindeutig sein
    try expect(id_apple != id_banana);
    try expect(id_banana != id_pear);
    try expect(id_apple != id_pear);
}
