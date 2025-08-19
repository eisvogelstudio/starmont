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
const ecs = @import("zflecs");
const zchip = @import("zchip2d");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ------
const component = @import("component.zig");
const tag = @import("tag.zig");
// ------------------------

pub fn applyVelocityLinear(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity) void {
    const delta: f32 = it.delta_time;

    for (positions, velocities) |*pos, *vel| {
        pos.x += vel.x * delta;
        pos.y += vel.y * delta;
    }
}

pub fn integrateVelocityAccelerated(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []component.Acceleration) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = std.math.pow(f32, delta, 2);

    for (velocities, accelerations) |*vel, *acc| {
        vel.x += acc.x * delta;
        vel.y += acc.y * delta;
    }

    for (positions, velocities, accelerations) |*pos, *vel, *acc| {
        pos.x += (vel.x * delta) + (0.5 * acc.x * delta2);
        pos.y += (vel.y * delta) + (0.5 * acc.y * delta2);
    }
}

pub fn integrateMovementDynamic(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = std.math.pow(f32, delta, 2);
    const delta3: f32 = std.math.pow(f32, delta, 3);
    const sixth = 1.0 / 6.0;

    for (accelerations, jerks) |*acc, *jerk| {
        acc.x += jerk.x * delta;
        acc.y += jerk.y * delta;
    }

    for (velocities, accelerations, jerks) |*vel, *acc, *jerk| {
        vel.x += (acc.x * delta) + (0.5 * jerk.x * delta2);
        vel.y += (acc.y * delta) + (0.5 * jerk.y * delta2);
    }

    for (positions, velocities, accelerations, jerks) |*pos, *vel, *acc, *jerk| {
        pos.x += (vel.x * delta) + (0.5 * acc.x * delta2) + (sixth * jerk.x * delta3);
        pos.y += (vel.y * delta) + (0.5 * acc.y * delta2) + (sixth * jerk.y * delta3);
    }
}
