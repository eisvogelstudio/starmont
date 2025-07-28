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
    path: []const u8,
    position: util.Vec2 = util.Vec2.zero(),
    rotation: util.Angle = util.Angle.zero(),
    scale: util.Vec2 = util.Vec2.one(),
    pivot: util.Vec2 = .{ .x = 0.5, .y = 0.5 },

    pub fn init(gpa: *std.mem.Allocator, path: []const u8) !Asset {
        const asset = Asset{
            .path = try gpa.dupe(u8, path),
        };

        return asset;
    }

    pub fn copy(self: Asset, allocator: *std.mem.Allocator) !Asset {
        return Asset{
            .path = try allocator.dupe(u8, self.path),
            .position = self.position,
            .rotation = self.rotation,
            .scale = self.scale,
            .pivot = self.pivot,
        };
    }

    pub fn deinit(self: *Asset, gpa: *std.mem.Allocator) void {
        gpa.free(self.path);
    }
};

pub const PrefabDTO = struct {
    assets: []Asset,

    pub fn copy(self: PrefabDTO, gpa: *std.mem.Allocator) !PrefabDTO {
        const n = self.assets.len;
        var new_assets = try gpa.alloc(Asset, n);

        for (self.assets, 0..) |asset, i| {
            new_assets[i] = Asset{
                .path = try gpa.dupe(u8, asset.path),
                .position = asset.position,
                .rotation = asset.rotation,
                .scale = asset.scale,
                .pivot = asset.pivot,
            };
        }

        return PrefabDTO{ .assets = new_assets };
    }

    pub fn free(self: PrefabDTO, gpa: *std.mem.Allocator) void {
        for (self.assets) |*asset| {
            asset.deinit(gpa);
        }

        gpa.free(self.assets);
    }

    pub fn fromPrefab(prefab: *const Prefab, gpa: std.mem.Allocator) !PrefabDTO {
        var dto = PrefabDTO{
            .assets = try gpa.alloc(Asset, prefab.assets.items.len),
        };

        for (prefab.assets.items, 0..) |asset, i| {
            dto.assets[i] = try asset.copy(&gpa);
        }

        return dto;
    }

    pub fn toPrefab(self: PrefabDTO, allocator: *std.mem.Allocator) !Prefab {
        var prefab = Prefab.init(allocator);
        for (self.assets) |asset| {
            try prefab.assets.append(asset);
        }

        return prefab;
    }
};

pub const Prefab = struct {
    gpa: *std.mem.Allocator,
    assets: std.ArrayList(Asset),

    pub fn init(gpa: *std.mem.Allocator) Prefab {
        const arrlist = std.ArrayList(Asset).init(gpa.*);
        return Prefab{
            .gpa = gpa,
            .assets = arrlist,
        };
    }

    pub fn deinit(self: *Prefab) void {
        //for (self.assets.items) |*a| {
        //a.deinit(self.gpa);
        //}
        self.assets.deinit();
    }

    pub fn addAsset(self: *Prefab, asset: Asset) !void {
        try self.assets.append(asset);
    }
};
