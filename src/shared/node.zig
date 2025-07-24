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

// ---------- local ----------
const core = @import("core/core.zig");
const visual = @import("visual/visual.zig");
// ---------------------------

pub const NodeLink = struct {
    file: []const u8 = "",
    offset: util.Vec2,
    rotation: util.Angle,
};

pub const NodeMeta = struct {
    name: []const u8 = "",
    dependencies: []const NodeLink = &[_]NodeLink{},
};

pub const Node = struct {
    allocator: std.mem.Allocator,
    sub_nodes: std.ArrayList(Node),
    visuals: std.ArrayList(visual.Prefab),
    cores: std.ArrayList(core.Prefab),

    pub fn init(allocator: std.mem.Allocator) Node {
        return Node{
            .allocator = allocator,
            .sub_nodes = std.ArrayList(Node).init(allocator),
            .visuals = std.ArrayList(visual.Prefab).init(allocator),
            .cores = std.ArrayList(core.Prefab).init(allocator),
        };
    }

    pub fn deinit(self: *Node) void {
        for (self.sub_nodes.items) |*node| {
            node.deinit();
        }

        for (self.visuals.items) |*vis| {
            vis.deinit();
        }

        self.sub_nodes.deinit();
        self.visuals.deinit();
        self.cores.deinit();
    }

    pub fn getVisual(self: *Node) visual.Prefab {
        return .{ .parts = self.visual.items };
    }

    pub fn getCore(self: *Node) core.Prefab {
        return .{ .colliders = self.cores.items };
    }
};
