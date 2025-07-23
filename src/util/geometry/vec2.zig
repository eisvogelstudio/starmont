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
const Angle = @import("angle.zig").Angle;
// ---------------------------

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn zero() Vec2 {
        return .{ .x = 0.0, .y = 0.0 };
    }

    pub fn one() Vec2 {
        return .{ .x = 1.0, .y = 1.0 };
    }

    pub fn add(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn addScalar(a: Vec2, s: f32) Vec2 {
        return .{ .x = a.x + s, .y = a.y + s };
    }

    pub fn subScalar(a: Vec2, s: f32) Vec2 {
        return .{ .x = a.x - s, .y = a.y - s };
    }

    pub fn scale(v: Vec2, s: f32) Vec2 {
        return .{ .x = v.x * s, .y = v.y * s };
    }

    pub fn multiply(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn divide(a: Vec2, b: Vec2) Vec2 {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn negate(v: Vec2) Vec2 {
        return .{ .x = -v.x, .y = -v.y };
    }

    pub fn invert(v: Vec2) Vec2 {
        return .{ .x = 1.0 / v.x, .y = 1.0 / v.y };
    }

    pub fn dot(a: Vec2, b: Vec2) f32 {
        return a.x * b.x + a.y * b.y;
    }

    pub fn cross(a: Vec2, b: Vec2) f32 {
        return a.x * b.y - a.y * b.x;
    }

    pub fn length(v: Vec2) f32 {
        return @sqrt(v.x * v.x + v.y * v.y);
    }

    pub fn lengthSquared(v: Vec2) f32 {
        return v.x * v.x + v.y * v.y;
    }

    pub fn distance(a: Vec2, b: Vec2) f32 {
        return length(sub(a, b));
    }

    pub fn distanceSquared(a: Vec2, b: Vec2) f32 {
        return lengthSquared(sub(a, b));
    }

    pub fn normalize(v: Vec2) Vec2 {
        const len = length(v);
        return if (len != 0.0) scale(v, 1.0 / len) else v;
    }

    pub fn angleBetween(a: Vec2, b: Vec2) Angle {
        return Angle.radians(std.math.acos(dot(normalize(a), normalize(b))));
    }

    pub fn directionAngle(start: Vec2, end: Vec2) Angle {
        const dir = normalize(sub(end, start));
        return Angle.radians(std.math.atan2(dir.y, dir.x));
    }

    pub fn rotate(v: Vec2, angle: Angle) Vec2 {
        const cos = @cos(angle.toDegrees());
        const sin = @sin(angle.toDegrees());
        return .{
            .x = v.x * cos - v.y * sin,
            .y = v.x * sin + v.y * cos,
        };
    }

    pub fn lerp(a: Vec2, b: Vec2, t: f32) Vec2 {
        return .{
            .x = a.x + (b.x - a.x) * t,
            .y = a.y + (b.y - a.y) * t,
        };
    }

    pub fn moveTowards(current: Vec2, target: Vec2, maxDist: f32) Vec2 {
        const delta = sub(target, current);
        const dist = length(delta);
        if (dist <= maxDist or dist == 0.0) return target;
        return add(current, scale(delta, maxDist / dist));
    }

    pub fn clamp(v: Vec2, min_val: Vec2, max_val: Vec2) Vec2 {
        return .{
            .x = std.math.clamp(v.x, min_val.x, max_val.x),
            .y = std.math.clamp(v.y, min_val.y, max_val.y),
        };
    }

    pub fn clampScalar(v: Vec2, min_val: f32, max_val: f32) Vec2 {
        return .{
            .x = std.math.clamp(v.x, min_val, max_val),
            .y = std.math.clamp(v.y, min_val, max_val),
        };
    }

    pub fn min(a: Vec2, b: Vec2) Vec2 {
        return .{
            .x = @min(a.x, b.x),
            .y = @min(a.y, b.y),
        };
    }

    pub fn max(a: Vec2, b: Vec2) Vec2 {
        return .{
            .x = @max(a.x, b.x),
            .y = @max(a.y, b.y),
        };
    }

    pub fn equals(a: Vec2, b: Vec2, epsilon: f32) bool {
        return std.math.approxEqAbs(f32, a.x, b.x, epsilon) and std.math.approxEqAbs(f32, a.y, b.y, epsilon);
    }

    pub fn reflect(v: Vec2, normal: Vec2) Vec2 {
        const dot2 = 2.0 * dot(v, normal);
        return sub(v, scale(normal, dot2));
    }

    pub fn refract(v: Vec2, n: Vec2, eta: f32) Vec2 {
        const dotVN = dot(v, n);
        const k = 1.0 - eta * eta * (1.0 - dotVN * dotVN);
        if (k < 0.0) return .{ .x = 0.0, .y = 0.0 };
        return sub(scale(v, eta), scale(n, eta * dotVN + @sqrt(k)));
    }
};
