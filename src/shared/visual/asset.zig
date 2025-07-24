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

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

pub const Asset = struct {
    allocator: *std.mem.Allocator,
    image_path: []const u8,
    position: util.Vec2 = util.Vec2.zero(),
    rotation: util.Angle = util.Angle.zero(),
    scale: util.Vec2 = util.Vec2.one(),
    pivot: util.Vec2 = .{ .x = 0.5, .y = 0.5 },

    pub fn init(allocator: *std.mem.Allocator, path: []const u8) !Asset {
        const copied_path = try allocator.dupe(u8, path);
        return Asset{
            .allocator = allocator,
            .image_path = copied_path,
        };
    }

    pub fn deinit(self: *Asset) void {
        self.allocator.free(self.image_path);
    }
};

pub const Prefab = struct {
    allocator: *std.mem.Allocator,
    assets: std.ArrayList(Asset),

    pub fn init(allocator: *std.mem.Allocator) Prefab {
        const arrlist = std.ArrayList(Prefab).init(allocator.*);
        return Prefab{
            .allocator = allocator,
            .assets = arrlist,
        };
    }

    pub fn deinit(self: *Prefab) void {
        for (self.assets.items) |*a| {
            a.deinit();
        }
        self.assets.deinit();
    }
};
