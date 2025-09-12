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

// ╔══════════════════════════════ pack ══════════════════════════════╗
pub const log = @import("log.zig");
pub const PerfectStringMap = @import("perfect.zig").PerfectStringMap;
pub const RingBuffer = @import("ringbuffer.zig").RingBuffer;
pub const stripBeforeStarmont = @import("strip.zig").stripBeforeStarmont;
pub const UUID4 = @import("uuid4.zig").UUID4;
pub const ziggy = @import("ziggy.zig");
// ┌──────────────────── geometry ────────────────────┐
pub const Angle = @import("geometry/angle.zig").Angle;
// ---------- shape ----------
pub const Shape = @import("geometry/shape.zig").Shape;
pub const ShapeType = @import("geometry/shape.zig").ShapeType;
pub const BoxShape = @import("geometry/shape.zig").BoxShape;
pub const CircleShape = @import("geometry/shape.zig").CircleShape;
pub const CapsuleShape = @import("geometry/shape.zig").CapsuleShape;
pub const PolygonShape = @import("geometry/shape.zig").PolygonShape;
pub const SegmentShape = @import("geometry/shape.zig").SegmentShape;
// ---------------------------
pub const Vec2 = @import("geometry/vec2.zig").Vec2;
pub const Vec2u = @import("geometry/vec2u.zig").Vec2u;
// └──────────────────────────────────────────────────┘
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ test ══════════════════════════════╗
test {
    //TODO[TEST]
}
// ╚══════════════════════════════════════════════════════════════════╝

pub fn seqGreater(comptime T: type, a: T, b: T) bool {
    const Signed = std.meta.Int(.signed, @bitSizeOf(T));
    const s: Signed = @intCast(a - b);
    return s > 0;
}
