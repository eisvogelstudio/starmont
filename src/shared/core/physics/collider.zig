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

// ---------- external ----------
const zchip = @import("zchip2d");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ┌──────────────────── Collider ────────────────────┐
pub const Collider = struct {
    shape: util.Shape,
    offset: util.Vec2 = util.Vec2.zero(),
    rotation: util.Angle = util.Angle.zero(),
    is_sensor: bool = false,

    pub fn fromShape(shape_val: util.Shape) Collider {
        return Collider{
            .shape = shape_val,
        };
    }
};
// └──────────────────────────────────────────────────┘

pub const PrefabDTO = struct {
    colliders: []const Collider,

    pub fn copy(self: PrefabDTO, allocator: *std.mem.Allocator) !PrefabDTO {
        const n = self.colliders.len;
        var new_colliders = try allocator.alloc(Collider, n);

        for (self.colliders, 0..) |c, i| {
            new_colliders[i] = Collider{
                .shape = c.shape, // shallow copy (ok wenn shape kein Heap nutzt)
                .offset = c.offset,
                .rotation = c.rotation,
                .is_sensor = c.is_sensor,
            };
        }

        return PrefabDTO{
            .colliders = new_colliders,
        };
    }

    pub fn free(self: PrefabDTO, allocator: *std.mem.Allocator) void {
        allocator.free(self.colliders);
    }

    pub fn fromPrefab(prefab: *const Prefab, allocator: std.mem.Allocator) !PrefabDTO {
        const dto = PrefabDTO{
            .colliders = try allocator.alloc(Collider, prefab.colliders.items.len),
        };

        for (prefab.colliders.items, 0..) |*col, i| {
            dto.colliders[i] = col;
        }

        return dto;
    }

    pub fn toPrefab(self: PrefabDTO, allocator: *std.mem.Allocator) !Prefab {
        var prefab = Prefab.init(allocator);
        for (self.colliders) |col| {
            try prefab.colliders.append(col);
        }
        return prefab;
    }
};

pub const Prefab = struct {
    allocator: *std.mem.Allocator,
    colliders: std.ArrayList(Collider),
    //behavior (e.g turret, door)

    pub fn init(allocator: *std.mem.Allocator) Prefab {
        return Prefab{
            .allocator = allocator,
            .colliders = std.ArrayList(Collider).init(allocator.*),
        };
    }

    pub fn deinit(self: *Prefab) void {
        for (self.colliders.items) |*c| {
            _ = c;
        }
        self.colliders.deinit();
    }

    pub fn addCollider(self: *Prefab, collider: Collider) !void {
        try self.colliders.append(collider);
    }
};

//const RuntimeCollider = struct {
//    id: u32,
//    body: *zchip.cpBody,
//    shapes: []const *zchip.cpShape,
//
//    pub fn fromCollider(id: u32, space: *zchip.cpSpace, collider: *const Collider, allocator: std.mem.Allocator) !RuntimeCollider {
//        const mass = 1.0;
//        const moment = 1.0;
//
//        const body = zchip.cpBodyNew(mass, moment);
//        zchip.cpBodySetPosition(body, zchip.cpv(collider.offset.x, collider.offset.y));
//        zchip.cpBodySetAngle(body, collider.rotation.toDegrees());
//
//        var shapes = std.ArrayList(*zchip.cpShape).init(allocator);
//
//        switch (collider.kind) {
//            .Circle => {
//                const r = collider.shape.Circle.radius;
//                const shape = zchip.cpCircleShapeNew(body, r, zchip.cpvzero);
//                try shapes.append(shape);
//            },
//            .Box => {
//                const s = collider.shape.Box.size;
//                const hw = s.x / 2.0;
//                const hh = s.y / 2.0;
//                const verts = [_]zchip.cpVect{
//                    zchip.cpv(-hw, -hh),
//                    zchip.cpv(hw, -hh),
//                    zchip.cpv(hw, hh),
//                    zchip.cpv(-hw, hh),
//                };
//                const shape = zchip.cpPolyShapeNew(body, 4, &verts[0], zchip.cpTransformIdentity, 0.0);
//                try shapes.append(shape);
//            },
//            .Segment => {
//                const seg = collider.shape.Segment;
//                const shape = zchip.cpSegmentShapeNew(body, zchip.cpv(seg.a.x, seg.a.y), zchip.cpv(seg.b.x, seg.b.y), seg.radius);
//                try shapes.append(shape);
//            },
//            .Polygon => {
//                const verts = try allocator.alloc(zchip.cpVect, collider.shape.Polygon.vertices.len);
//                defer allocator.free(verts);
//                for (collider.shape.Polygon.vertices, 0..) |v, i| {
//                    verts[i] = zchip.cpv(v.x, v.y);
//                }
//                const shape = zchip.cpPolyShapeNew(body, @intCast(verts.len), &verts[0], zchip.cpTransformIdentity, 0.0);
//                try shapes.append(shape);
//            },
//            .Capsule => {
//                const cap = collider.shape.Capsule;
//                const r = cap.radius;
//                const hh = cap.half_height;
//
//                const box_bb = zchip.cpBBNew(-r, -hh, r, hh);
//                const mid = zchip.cpBoxShapeNew2(body, box_bb, 0.0);
//                const top = zchip.cpCircleShapeNew(body, r, zchip.cpv(0, hh));
//                const bot = zchip.cpCircleShapeNew(body, r, zchip.cpv(0, -hh));
//
//                try shapes.append(mid);
//                try shapes.append(top);
//                try shapes.append(bot);
//            },
//        }
//
//        for (shapes.items) |s| {
//            zchip.cpShapeSetSensor(s, if (collider.is_sensor) 1 else 0);
//            zchip.cpSpaceAddShape(space, s);
//        }
//        zchip.cpSpaceAddBody(space, body);
//
//        return RuntimeCollider{
//            .id = id,
//            .body = body,
//            .shapes = try shapes.toOwnedSlice(),
//        };
//    }
//
//    pub fn syncToCollider(runtime: *RuntimeCollider, target: *Collider) void {
//        const pos = zchip.cpBodyGetPosition(runtime.body);
//        const rot = zchip.cpBodyGetAngle(runtime.body);
//        target.offset = .{ .x = pos.x, .y = pos.y };
//        target.rotation = rot;
//    }
//};
//
