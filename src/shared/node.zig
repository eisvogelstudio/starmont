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
const co = @import("core/core.zig");
const vi = @import("visual/visual.zig");
// ---------------------------

pub const NodeData = struct {
    offset: util.Vec2,
    rotation: util.Angle,
};

const PrefabMap = util.PerfectStringMap(&[_][]const u8{
    "res/prefab/other/ship",
    "res/prefab/ship/ship",
});

pub const NodeRef = union(enum) {
    id: struct { value: usize },
    path: struct { value: []const u8 },

    pub fn fromPath(path: []const u8) NodeRef {
        var ref = NodeRef{ .path = .{ .value = path } };
        ref.toId();
        return ref;
    }

    pub fn toPath(self: *NodeRef) void {
        switch (self) {
            .id => |i| self.path.value = PrefabMap.getString(i.value),
            .path => return,
            else => unreachable,
        }
    }

    pub fn toId(self: *NodeRef) void {
        switch (self.*) {
            .id => return,
            .path => |p| {
                const id = PrefabMap.getId(p.value) orelse @panic("invalid prefab path");
                self.* = .{ .id = .{ .value = id } };
            },
        }
    }

    pub fn getPath(self: NodeRef) []const u8 {
        return switch (self) {
            .id => |i| PrefabMap.getString(i.value),
            .path => |p| p.value,
        };
    }

    pub fn getId(self: NodeRef) usize {
        return switch (self) {
            .id => |i| i.value,
            .path => |p| PrefabMap.getId(p.value) orelse @panic("invalid prefab path"),
        };
    }
};

pub const NodeMetaLink = struct {
    ref: NodeRef,
    data: NodeData,
};

pub const NodeMetaDTO = struct {
    name: []const u8 = "",
    version: []const u8 = "",
    subs: []const NodeMetaLink = &[_]NodeMetaLink{},
    data: NodeData = NodeData{ .offset = util.Vec2.zero(), .rotation = util.Angle.zero() },

    pub fn copy(self: NodeMetaDTO, allocator: *std.mem.Allocator) !NodeMetaDTO {
        return NodeMetaDTO{
            .name = try allocator.dupe(u8, self.name),
            .version = try allocator.dupe(u8, self.version),
            .subs = try allocator.dupe(NodeMetaLink, self.subs),
            .data = self.data,
        };
    }

    pub fn free(self: *NodeMetaDTO, allocator: *std.mem.Allocator) void {
        allocator.free(self.name);
        allocator.free(self.version);
        allocator.free(self.subs);
    }

    pub fn fromMeta(meta: *const NodeMeta, allocator: std.mem.Allocator) !NodeMetaDTO {
        const dto = NodeMetaDTO{
            .name = try allocator.dupe(u8, meta.name),
            .version = try allocator.dupe(u8, meta.version),
            .subs = try allocator.alloc(NodeMetaLink, meta.subs.items.len),
            .data = meta.data,
        };

        for (meta.subs.items, 0..) |*link, i| {
            dto.subs[i] = link;
        }

        return dto;
    }

    pub fn toMeta(self: NodeMetaDTO, allocator: *std.mem.Allocator) !NodeMeta {
        var meta = NodeMeta.init(allocator);
        for (self.subs) |link| {
            try meta.subs.append(link);
        }
        return meta;
    }
};

pub const NodeMeta = struct {
    allocator: *std.mem.Allocator,
    name: []const u8 = "",
    version: []const u8 = "",
    subs: std.ArrayList(NodeMetaLink),
    data: NodeData = NodeData{ .offset = util.Vec2.zero(), .rotation = util.Angle.zero() },

    pub fn init(allocator: *std.mem.Allocator) NodeMeta {
        return NodeMeta{
            .allocator = allocator,
            .subs = std.ArrayList(NodeMetaLink).init(allocator.*),
        };
    }

    pub fn deinit(self: NodeMeta) void {
        self.allocator.free(self.name);
        self.allocator.free(self.version);
        self.subs.deinit();
    }
};
