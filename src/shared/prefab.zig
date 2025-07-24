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

pub const PrefabData = struct {
    parts_list: std.ArrayList(VisualPart),
    colliders_list: std.ArrayList(Collider),

    pub fn init(allocator: std.mem.Allocator) PrefabData {
        return PrefabData{
            .parts_list = std.ArrayList(VisualPart).init(allocator),
            .colliders_list = std.ArrayList(Collider).init(allocator),
        };
    }

    pub fn deinit(self: *PrefabData) void {
        self.parts_list.deinit();
        self.colliders_list.deinit();
    }

    pub fn toVisual(self: *PrefabData) VisualPrefab {
        return .{ .parts = self.parts_list.items };
    }

    pub fn toCore(self: *PrefabData) CorePrefab {
        return .{ .colliders = self.colliders_list.items };
    }
};
