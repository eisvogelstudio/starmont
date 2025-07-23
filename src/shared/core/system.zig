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
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- local ------
const component = @import("component.zig");
// ------------------------

pub fn applyJerk(it: *ecs.iter_t, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;

    for (accelerations, jerks) |*acc, *jerk| {
        acc.x += jerk.x * delta;
        acc.y += jerk.y * delta;
    }
}

pub fn applyAccelerationAccelerated(it: *ecs.iter_t, velocities: []component.Velocity, accelerations: []component.Acceleration) void {
    const delta: f32 = it.delta_time;

    for (velocities, accelerations) |*vel, *acc| {
        vel.x += acc.x * delta;
        vel.y += acc.y * delta;
    }
}

pub fn applyAccelerationDynamic(it: *ecs.iter_t, velocities: []component.Velocity, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = std.math.pow(f32, delta, 2);

    for (velocities, accelerations, jerks) |*vel, *acc, *jerk| {
        vel.x += (acc.x * delta) + (0.5 * jerk.x * delta2);
        vel.y += (acc.y * delta) + (0.5 * jerk.y * delta2);
    }
}

pub fn applyVelocityLinear(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity) void {
    const delta: f32 = it.delta_time;

    for (positions, velocities) |*pos, *vel| {
        pos.x += vel.x * delta;
        pos.y += vel.y * delta;
    }
}

pub fn applyVelocityAccelerated(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []component.Acceleration) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = std.math.pow(f32, delta, 2);

    for (positions, velocities, accelerations) |*pos, *vel, *acc| {
        pos.x += (vel.x * delta) + (0.5 * acc.x * delta2);
        pos.y += (vel.y * delta) + (0.5 * acc.y * delta2);
    }
}

pub fn applyVelocityDynamic(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = std.math.pow(f32, delta, 2);
    const delta3: f32 = std.math.pow(f32, delta, 3);
    const sixth = 1.0 / 6.0;

    for (positions, velocities, accelerations, jerks) |*pos, *vel, *acc, *jerk| {
        pos.x += (vel.x * delta) + (0.5 * acc.x * delta2) + (sixth * jerk.x * delta3);
        pos.y += (vel.y * delta) + (0.5 * acc.y * delta2) + (sixth * jerk.y * delta3);
    }
}
