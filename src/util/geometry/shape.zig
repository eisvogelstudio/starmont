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
const Vec2 = @import("vec2.zig").Vec2;
// ---------------------------

// ┌──────────────────── ShapeType ────────────────────┐
pub const ShapeType = enum {
    Box,
    Circle,
    Capsule,
    Segment,
    Polygon,
};
// └───────────────────────────────────────────────────┘

// ┌──────────────────── Shape ────────────────────┐
pub const Shape = union(ShapeType) {
    Box: BoxShape,
    Circle: CircleShape,
    Capsule: CapsuleShape,
    Segment: SegmentShape,
    Polygon: PolygonShape,
};
// └───────────────────────────────────────────────┘

// ┌──────────────────── BoxShape ────────────────────┐
pub const BoxShape = struct {
    size: Vec2,

    pub fn init(width: f32, height: f32) Shape {
        return Shape{ .Box = BoxShape{
            .size = Vec2{ .x = width, .y = height },
        } };
    }

    pub fn fromVec2(size: Vec2) Shape {
        return Shape{ .Box = BoxShape{ .size = size } };
    }
};
// └──────────────────────────────────────────────────┘

// ┌──────────────────── CircleShape ────────────────────┐
pub const CircleShape = struct {
    radius: f32,

    pub fn init(radius: f32) Shape {
        return Shape{ .Circle = CircleShape{ .radius = radius } };
    }

    pub fn fromDiameter(d: f32) Shape {
        return CircleShape.init(d / 2.0);
    }
};
// └─────────────────────────────────────────────────────┘

// ┌──────────────────── CapsuleShape ────────────────────┐
pub const CapsuleShape = struct {
    half_height: f32,
    radius: f32,

    pub fn init(half_height: f32, radius: f32) Shape {
        return Shape{ .Capsule = CapsuleShape{
            .half_height = half_height,
            .radius = radius,
        } };
    }

    pub fn fromTotalHeight(total_height: f32, radius: f32) Shape {
        return CapsuleShape.init(total_height / 2.0 - radius, radius);
    }

    //TODO[MISSING]
    //pub fn fromWidth(total_height: f32, radius: f32) Shape {
    //    return CapsuleShape.init(total_height / 2.0 - radius, radius);
    //}
};
// └──────────────────────────────────────────────────────┘

// ┌──────────────────── SegmentShape ────────────────────┐
pub const SegmentShape = struct {
    a: Vec2,
    b: Vec2,
    thickness: f32 = 0.0,

    pub fn init(a: Vec2, b: Vec2, thickness: f32) Shape {
        return Shape{ .Segment = SegmentShape{
            .a = a,
            .b = b,
            .thickness = thickness,
        } };
    }

    //TODO[MISSING]
    //pub fn fromLengthDir(center: Vec2, angle: f32, length: f32, thickness: f32) Shape {
    //    const dir = util.vec2FromAngle(angle);
    //    const half = util.vec2Scale(dir, length / 2.0);
    //    return SegmentShape.init(
    //        util.vec2Sub(center, half),
    //        util.vec2Add(center, half),
    //        thickness,
    //    );
    //}
};
// └──────────────────────────────────────────────────────┘

// ┌──────────────────── PolygonShape ────────────────────┐
pub const PolygonShape = struct {
    vertices: []const Vec2,

    pub fn init(vertices: []const Vec2) Shape {
        return Shape{ .Polygon = PolygonShape{ .vertices = vertices } };
    }

    pub fn rectangle(width: f32, height: f32) Shape {
        const hw = width / 2.0;
        const hh = height / 2.0;
        const verts = [_]Vec2{
            .{ .x = -hw, .y = -hh },
            .{ .x = hw, .y = -hh },
            .{ .x = hw, .y = hh },
            .{ .x = -hw, .y = hh },
        };
        return PolygonShape.init(&verts);
    }
};
// └──────────────────────────────────────────────────────┘
