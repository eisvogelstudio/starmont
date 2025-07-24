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

pub const NodeDTO = struct {
    name: []const u8 = "",
    dependencies: []const NodeLink = &[_]NodeLink{},
    sub_nodes: []const NodeDTO = &[_]NodeDTO{},
    visuals: []const visual.PrefabDTO = &[_]visual.PrefabDTO{},
    cores: []const core.PrefabDTO = &[_]core.PrefabDTO{},

    pub fn from(node: *const Node, allocator: std.mem.Allocator) !NodeDTO {
        const sub_dtos = try allocator.alloc(NodeDTO, node.sub_nodes.items.len);
        for (node.sub_nodes.items, 0..) |*sub, i| {
            sub_dtos[i] = try NodeDTO.from(sub, allocator);
        }

        const visual_dtos = try allocator.alloc(visual.PrefabDTO, node.visuals.items.len);
        for (node.visuals.items, 0..) |*v, i| {
            visual_dtos[i] = try visual.PrefabDTO.from(v, allocator);
        }

        const core_dtos = try allocator.alloc(core.PrefabDTO, node.cores.items.len);
        for (node.cores.items, 0..) |*c, i| {
            core_dtos[i] = try core.PrefabDTO.from(c, allocator);
        }

        return NodeDTO{
            .name = node.name,
            .dependencies = &[_]NodeLink{}, // TODO if needed
            .sub_nodes = sub_dtos,
            .visuals = visual_dtos,
            .cores = core_dtos,
        };
    }

    pub fn to(self: NodeDTO, allocator: std.mem.Allocator) !Node {
        var sub_nodes = std.ArrayList(Node).init(allocator);
        for (self.sub_nodes) |sub_dto| {
            try sub_nodes.append(try sub_dto.to(allocator));
        }

        var visuals = std.ArrayList(visual.Prefab).init(allocator);
        for (self.visuals) |v| {
            try visuals.append(try v.to(allocator));
        }

        var cores = std.ArrayList(core.Prefab).init(allocator);
        for (self.cores) |c| {
            try cores.append(try c.to(allocator));
        }

        return Node{
            .allocator = allocator,
            .sub_nodes = sub_nodes,
            .visuals = visuals,
            .cores = cores,
        };
    }
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

        for (self.cores.items) |*cor| {
            cor.deinit();
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
