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

// ---------- shared ----------
const util = @import("shared").util;
// ----------------------------

pub const ComponentType = enum {
    Position,
    Velocity,
    Acceleration,
    Jerk,
    Rotation,
    RotationalVelocity,
    RotationalAcceleration,
    ShipSize,
};

pub const Position = struct {
    x: f32,
    y: f32,

    pub fn toVec2(self: Position) util.Vec2 {
        return .{ .x = self.x, .y = self.y };
    }

    pub fn fromVec2(v: util.Vec2) Position {
        return .{ .x = v.x, .y = v.y };
    }
};

pub const Velocity = struct {
    x: f32,
    y: f32,

    pub fn toVec2(self: Position) util.Vec2 {
        return .{ .x = self.x, .y = self.y };
    }

    pub fn fromVec2(v: util.Vec2) Position {
        return .{ .x = v.x, .y = v.y };
    }
};

pub const Acceleration = struct {
    x: f32,
    y: f32,

    pub fn toVec2(self: Position) util.Vec2 {
        return .{ .x = self.x, .y = self.y };
    }

    pub fn fromVec2(v: util.Vec2) Position {
        return .{ .x = v.x, .y = v.y };
    }
};

pub const Jerk = struct {
    x: f32,
    y: f32,

    pub fn toVec2(self: Position) util.Vec2 {
        return .{ .x = self.x, .y = self.y };
    }

    pub fn fromVec2(v: util.Vec2) Position {
        return .{ .x = v.x, .y = v.y };
    }
};

const Rotation = struct {
    value: util.Angle,
};

const RotationalVelocity = struct {
    value: util.Angle,
};

const RotationalAcceleration = struct {
    value: util.Angle,
};

pub const ShipSize = enum {
    Small,
    Medium,
    Large,
    Capital,
};
