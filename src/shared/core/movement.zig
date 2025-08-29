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

// ---------- local ------
const comp = @import("component.zig");
// ------------------------

pub fn ensureMotionChainLinear(it: *ecs.iter_t) void {
    const entities = it.entities();

    for (entities) |e| {
        ensureLinearMotionComponent(it.world, e, comp.Position);
    }
}

pub fn ensureMotionChainAccelerated(it: *ecs.iter_t) void {
    const entities = it.entities();

    for (entities) |e| {
        ensureLinearMotionComponent(it.world, e, comp.Velocity);
        ensureLinearMotionComponent(it.world, e, comp.Position);
    }
}

pub fn ensureMotionChainDynamic(it: *ecs.iter_t) void {
    const entities = it.entities();

    for (entities) |e| {
        ensureLinearMotionComponent(it.world, e, comp.Acceleration);
        ensureLinearMotionComponent(it.world, e, comp.Velocity);
        ensureLinearMotionComponent(it.world, e, comp.Position);
    }
}

fn ensureLinearMotionComponent(world: *ecs.world_t, e: ecs.entity_t, comptime T: type) void {
    if (!ecs.has_id(world, e, ecs.id(T))) {
        _ = ecs.set(world, e, T, .{ .x = 0, .y = 0 });
    }
}
