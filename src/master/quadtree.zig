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

// ---------- std ----------
const std = @import("std");
const testing = std.testing;
// -------------------------

// ---------- shared ----------
const ServerId = @import("shared").network.ServerId;
// ----------------------------

// ---------- master ----------
const ServerRegistry = @import("server_registry.zig").ServerRegistry;
// -----------------------------

//TODO to utils
pub const Direction = enum {
    North,
    NorthEast,
    East,
    SouthEast,
    South,
    SouthWest,
    West,
    NorthWest,

    fn neighborChildQuadrants(self: Direction) []const Quadrant {
        return switch (self) {
            .NorthWest => &[_]Quadrant{.SE},
            .NorthEast => &[_]Quadrant{.SW},
            .SouthWest => &[_]Quadrant{.NO},
            .SouthEast => &[_]Quadrant{.NW},
            .North => &[_]Quadrant{ .SE, .SW },
            .South => &[_]Quadrant{ .NE, .NW },
            .West => &[_]Quadrant{ .NE, .SE },
            .East => &[_]Quadrant{ .NW, .SW },
        };
    }

    fn neighborChildQuadrant(self: Direction, from: Quadrant) ?Quadrant {
        return switch (from) {
            .NW => switch (self) {
                .North => .SW,
                .West => .NE,
                .NorthWest => .SE,
                else => null,
            },
            .NE => switch (self) {
                .North => .SE,
                .East => .NW,
                .NorthEast => .SW,
                else => null,
            },
            .SW => switch (self) {
                .South => .NW,
                .West => .NE,
                .SouthWest => .NE,
                else => null,
            },
            .SE => switch (self) {
                .South => .NE,
                .East => .NW,
                .SouthEast => .NW,
                else => null,
            },
        };
    }
};

const Quadrant = enum(u8) {
    NW = 0,
    NE = 1,
    SW = 2,
    SE = 3,

    fn hasSiblingInDirection(self: Quadrant, dir: Direction) bool {
        return switch (self) {
            .NW => dir == .East or dir == .South or dir == .SouthEast,
            .NE => dir == .West or dir == .South or dir == .SouthWest,
            .SW => dir == .North or dir == .East or dir == .NorthEast,
            .SE => dir == .North or dir == .West or dir == .NorthWest,
        };
    }

    pub fn fromInt(value: u8) ?Quadrant {
        return switch (value) {
            0 => .NW,
            1 => .NE,
            2 => .SW,
            3 => .SE,
            else => null,
        };
    }
};

//TODO to utils
const Vec2 = struct {
    x: i32,
    y: i32,
};

//TODO to utils
const Rect = struct {
    x: i16,
    y: i16,
    width: i16,
    height: i16,

    pub fn computeAdjacencyDirection(a: Rect, b: Rect) ?Direction {
        if (a.x + 1 == b.x and a.y == b.y) return .East;
        if (a.x - 1 == b.x and a.y == b.y) return .West;
        if (a.y - 1 == b.y and a.x == b.x) return .North;
        if (a.y + 1 == b.y and a.x == b.x) return .South;

        if (a.x + 1 == b.x and a.y + 1 == b.y) return .SouthEast;
        if (a.x - 1 == b.x and a.y + 1 == b.y) return .SouthWest;
        if (a.x + 1 == b.x and a.y - 1 == b.y) return .NorthEast;
        if (a.x - 1 == b.x and a.y - 1 == b.y) return .NorthWest;

        return null;
    }

    pub fn key(self: Rect) i64 {
        return (@as(i64, self.x) << 32) | (@as(u32, @bitCast(self.y)));
    }

    pub fn quadrant(self: Rect, q: Quadrant) Rect {
        const half_width = @divFloor(self.width, 2);
        const half_height = @divFloor(self.height, 2);
        std.log.info("draw {} {}", .{ self.width, half_width });
        switch (q) {
            .NE => return Rect{ .x = self.x + half_width, .y = self.y, .width = half_width, .height = half_height },
            .SE => return Rect{ .x = self.x + half_width, .y = self.y + half_height, .width = half_width, .height = half_height },
            .SW => return Rect{ .x = self.x, .y = self.y + half_height, .width = half_width, .height = half_height },
            .NW => return Rect{ .x = self.x, .y = self.y, .width = half_width, .height = half_height },
        }
    }
};

//TODO to utils
pub const DirectionSet = packed struct {
    has_north: bool = false,
    has_south: bool = false,
    has_east: bool = false,
    has_west: bool = false,

    pub fn empty() DirectionSet {
        return .{};
    }

    pub fn with(dir: Direction) DirectionSet {
        var dirSet = DirectionSet.empty();
        dirSet.set(dir, true);
        return dirSet;
    }

    pub fn set(self: *DirectionSet, dir: Direction, value: bool) void {
        switch (dir) {
            .North => self.has_north = value,
            .South => self.has_south = value,
            .East => self.has_east = value,
            .West => self.has_west = value,

            .NorthEast => {
                self.has_north = value;
                self.has_east = value;
            },
            .NorthWest => {
                self.has_north = value;
                self.has_west = value;
            },
            .SouthEast => {
                self.has_south = value;
                self.has_east = value;
            },
            .SouthWest => {
                self.has_south = value;
                self.has_west = value;
            },
        }
    }
};

const Neightbours = struct {
    is_valid: bool = false,
    north: *std.ArrayList(ServerId),
    ne: ServerId,
    east: *std.ArrayList(ServerId),
    se: ServerId,
    south: *std.ArrayList(ServerId),
    sw: ServerId,
    west: *std.ArrayList(ServerId),
    nw: ServerId,
};

pub const QuadNode = struct {
    pub const max_depth = 10;
    pub const cells_per_axis: i32 = 1 << max_depth;
    pub const merge_threshhold = 30;
    pub const merge_time = 10;
    pub const split_threshhold = 50;

    allocator: *std.mem.Allocator,
    owner: ?ServerId,
    pressure: f32,
    depth: u8,
    rectangle: Rect,
    parent: ?*QuadNode,
    quadrant_in_parent: ?Quadrant,
    children: ?[]*QuadNode,
    below_threshhold_since: i64,

    fn init(allocator: *std.mem.Allocator, rectangle: Rect, depth: u8) QuadNode {
        return QuadNode{
            .allocator = allocator,
            .owner = null,
            .pressure = 0,
            .depth = depth,
            .rectangle = rectangle,
            .parent = null,
            .quadrant_in_parent = null,
            .children = null,
            .below_threshhold_since = std.time.timestamp(),
        };
    }

    fn deinit(self: *QuadNode) void {
        if (self.children) |children| {
            for (children) |child| {
                child.deinit();
                self.allocator.destroy(child);
            }
            self.allocator.free(children);
            self.children = null;
        }
    }

    pub fn split(self: *QuadNode) void {
        if (self.children != null) return;

        const alloc = self.allocator;
        const next_depth = self.depth + 1;

        self.children = alloc.alloc(*QuadNode, 4) catch unreachable;

        const bounds = [_]Rect{
            self.rectangle.quadrant(Quadrant.NE),
            self.rectangle.quadrant(Quadrant.SE),
            self.rectangle.quadrant(Quadrant.SW),
            self.rectangle.quadrant(Quadrant.NW),
        };

        for (self.children.?, 0..) |*child_ptr, i| {
            const child = alloc.create(QuadNode) catch unreachable;
            child.* = QuadNode{
                .allocator = alloc,
                .owner = null,
                .pressure = split_threshhold - 1,
                .depth = next_depth,
                .rectangle = bounds[i],
                .children = null,
                .below_threshhold_since = std.time.timestamp(),
                .parent = self,
                .quadrant_in_parent = Quadrant.fromInt(@intCast(i)),
            };
            child_ptr.* = child;
        }
    }

    fn merge(self: *QuadNode) void {
        if (self.children == null) return;

        var totalPressure: f32 = 0;
        for (self.children.?) |child| {
            totalPressure += child.pressure;
            self.allocator.destroy(child);
        }

        self.allocator.free(self.children.?);
        self.children = null;
        self.pressure = totalPressure;
        self.below_threshhold_since = std.time.timestamp();
    }

    pub fn isLeaf(self: *QuadNode) bool {
        return self.children == null;
    }

    fn tick_recurse(self: *QuadNode, registry: *ServerRegistry, time: i64) void {
        //const now = std.time.milliTimestamp();
        const now = time;
        if (!self.isLeaf()) {
            var totalCount: f32 = 0;
            if (self.children) |children| {
                for (children) |child| {
                    tick_recurse(child, registry, time);
                    totalCount += child.pressure;
                }
            }
            self.pressure = totalCount;
        } else {
            if (self.depth >= max_depth) return;

            if (self.pressure >= split_threshhold) {
                self.split(); // create children

                if (self.children) |children| {
                    for (children) |child| {
                        const chosen = registry.getLeastLoaded();
                        child.owner = chosen.id;
                    }
                }
            } else if (self.pressure > merge_threshhold) {
                self.below_threshhold_since = now;
            }
        }

        if (now - self.below_threshhold_since > merge_time) {
            if (self.children) |children| {
                for (children) |child| {
                    if (!child.isLeaf()) {
                        return;
                    }
                    std.log.info("time: {}", .{now - child.below_threshhold_since});
                    if (!(now - child.below_threshhold_since > merge_time)) {
                        return;
                    }
                }
            }
            self.merge(); // children -> owner
        }
    }

    fn getSiblingInDirection(parent: *QuadNode, q: Quadrant, dir: Direction) *QuadNode {
        const sibling_index: usize = switch (q) {
            .NW => switch (dir) {
                .East => Quadrant.NE,
                .South => Quadrant.SW,
                .SouthEast => Quadrant.SE,
                else => unreachable,
            },
            .NE => switch (dir) {
                .West => Quadrant.NW,
                .South => Quadrant.SE,
                .SouthWest => Quadrant.SW,
                else => unreachable,
            },
            .SW => switch (dir) {
                .North => Quadrant.NW,
                .East => Quadrant.SE,
                .NorthEast => Quadrant.NE,
                else => unreachable,
            },
            .SE => switch (dir) {
                .North => Quadrant.NE,
                .West => Quadrant.SW,
                .NorthWest => Quadrant.NW,
                else => unreachable,
            },
        };

        return parent.children.?[sibling_index];
    }
};

pub const QuadTree = struct {
    root: QuadNode,
    allocator: *std.mem.Allocator,

    pub fn init(
        allocator: *std.mem.Allocator,
    ) !QuadTree {
        return QuadTree{
            .root = QuadNode.init(allocator, Rect{ .x = 0, .y = 0, .width = QuadNode.cells_per_axis, .height = QuadNode.cells_per_axis }, 0),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *QuadTree) void {
        self.root.deinit();
    }

    pub fn tick(tree: *QuadTree, registry: *ServerRegistry, time: i64) void {
        tree.root.tick_recurse(registry, time);
    }

    //with depth <= own_depth
    //may not be a leaf
    pub fn findSameDepthNeighbor(self: *QuadNode, dir: Direction) ?*QuadNode {
        var current = self;
        var parent = self.parent;

        // Steige nach oben, bis ein Nachbar in die Richtung existieren könnte
        while (parent) |p| {
            const quadrant = p.quadrant_in_parent;
            if (quadrant.hasSiblingInDirection(dir)) {
                const sibling = self.getSiblingInDirection(quadrant, dir);
                return descendToSameDepth(sibling, self.depth, dir);
            }
            current = p;
            parent = p.parent;
        }

        return null;
    }

    pub fn findNeighbour(self: *QuadNode, dir: Direction, allocator: *std.mem.Allocator) ![]*QuadNode {
        const maybe_neighbour = findSameDepthNeighbor(self, dir);

        if (maybe_neighbour) |neighbour| {
            if (neighbour.isLeaf()) {
                return allocator.alloc(*QuadNode, 1) catch unreachable;
            } else {
                var list = std.ArrayList(*QuadNode).init(allocator);
                descendDeeper(neighbour);
                return try list.toOwnedSlice();
            }
        }

        return allocator.alloc(*QuadNode, 0) catch unreachable;
    }

    //fn getQuadrantInParent(node: *QuadNode) Quadrant {
    //    const parent = node.parent orelse unreachable;
    //    const dx = node.bounds.x - parent.bounds.x * 2;
    //    const dy = node.bounds.y - parent.bounds.y * 2;
    //
    //    if (dx == 0 and dy == 0) return .NW;
    //    if (dx == 1 and dy == 0) return .NE;
    //    if (dx == 0 and dy == 1) return .SW;
    //    if (dx == 1 and dy == 1) return .SE;
    //}

    fn descendToSameDepth(start: *QuadNode, target_depth: usize, dir: Direction) ?*QuadNode {
        var current = start;
        while (current.depth < target_depth) {
            const quadrant = current.quadrant_in_parent;
            const child_idx = dir.neighborChildQuadrant(quadrant);
            current = current.children.?[child_idx];
        }
        return current;
    }

    fn descendDeeper(node: *QuadNode, dir: Direction, list: *std.ArrayList(*QuadNode)) !void {
        if (node.isLeaf()) {
            try list.append(node);
            return;
        }

        const quads = dir.neighborChildQuadrants();
        for (quads) |q| {
            const child = node.children.?[@intFromEnum(q)];
            try descendDeeper(child, dir, list);
        }
    }
};
