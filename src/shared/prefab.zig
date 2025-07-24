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

// ---------- local ----------
const Collider = @import("core/physics/collider.zig").Collider;
const CorePrefab = @import("core/physics/prefab.zig").CorePrefab;
const VisualPart = @import("visual/prefab.zig").VisualPart;
const VisualPrefab = @import("visual/prefab.zig").VisualPrefab;
// ---------------------------

pub const PrefabManifest = struct {
    name: []const u8 = "",
    core: []const u8 = "",
    visual: []const u8 = "",
};

pub const Prefab = struct {
    visual: VisualPrefab = .{},
    core: CorePrefab = .{},
};

pub const PrefabData = struct {
    allocator: std.mem.Allocator,
    parts_list: std.ArrayList(VisualPart),
    colliders_list: std.ArrayList(Collider),

    pub fn init(allocator: std.mem.Allocator) PrefabData {
        return PrefabData{
            .allocator = allocator,
            .parts_list = std.ArrayList(VisualPart).init(allocator),
            .colliders_list = std.ArrayList(Collider).init(allocator),
        };
    }

    pub fn deinit(self: *PrefabData) void {
        for (self.parts_list.items) |part| {
            self.allocator.free(part.image_path);
        }
        self.parts_list.deinit();
        self.colliders_list.deinit();
    }

    pub fn toVisual(self: *PrefabData) VisualPrefab {
        return .{ .parts = self.parts_list.items };
    }

    pub fn toCore(self: *PrefabData) CorePrefab {
        return .{ .colliders = self.colliders_list.items };
    }

    pub fn toPrefab(self: *PrefabData) Prefab {
        return .{ .visual = self.toVisual(), .core = self.toCore() };
    }

    pub fn setFromPrefab(self: *PrefabData, prefab: Prefab) !void {
        for (self.parts_list.items) |p| self.allocator.free(p.image_path);
        self.parts_list.clearRetainingCapacity();
        self.colliders_list.clearRetainingCapacity();

        for (prefab.visual.parts) |part| {
            var copy = part;
            copy.image_path = try self.allocator.dupe(u8, part.image_path);
            try self.parts_list.append(copy);
        }

        try self.colliders_list.appendSlice(prefab.core.colliders);
    }
};
