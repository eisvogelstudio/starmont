// ─────────────────────────────────────────────────────────────────────
//  Starmont - Version 0.1.0
//  Prefab data structures
// ─────────────────────────────────────────────────────────────────────

const std = @import("std");
const util = @import("util");
const core = @import("shared").core;

pub const Part = struct {
    image_path: []const u8,
    position: util.Vec2 = util.Vec2.zero(),
    rotation: util.Angle = util.Angle.zero(),
    scale: util.Vec2 = util.Vec2.one(),
    pivot: util.Vec2 = .{ .x = 0.5, .y = 0.5 },
};

pub const VisualPrefab = struct {
    parts: []const Part = &[_]Part{},
};

pub const CorePrefab = struct {
    colliders: []const core.Collider = &[_]core.Collider{},
};
