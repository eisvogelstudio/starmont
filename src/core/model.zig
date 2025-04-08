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
const math = std.math;
const testing = std.testing;
// -------------------------

// ---------- starmont ----------
const core = @import("root.zig");
// ------------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

const log = std.log.scoped(.model);

const component = @import("component.zig");
const tag = @import("tag.zig");

const velocity_max: component.Velocity = .{
    .x = 200,
    .y = 200,
};

fn applyJerk(it: *ecs.iter_t, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;

    for (accelerations, jerks) |*acc, *jerk| {
        acc.x += jerk.x * delta;
        acc.y += jerk.y * delta;
    }
}

fn applyAccelerationAccelerated(it: *ecs.iter_t, velocities: []component.Velocity, accelerations: []component.Acceleration) void {
    const delta: f32 = it.delta_time;

    for (velocities, accelerations) |*vel, *acc| {
        vel.x += acc.x * delta;
        vel.y += acc.y * delta;
    }
}

fn applyAccelerationDynamic(it: *ecs.iter_t, velocities: []component.Velocity, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = math.pow(f32, delta, 2);

    for (velocities, accelerations, jerks) |*vel, *acc, *jerk| {
        vel.x += (acc.x * delta) + (0.5 * jerk.x * delta2);
        vel.y += (acc.y * delta) + (0.5 * jerk.y * delta2);
    }
}

fn applyVelocityLinear(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity) void {
    const delta: f32 = it.delta_time;

    for (positions, velocities) |*pos, *vel| {
        pos.x += vel.x * delta;
        pos.y += vel.y * delta;
    }
}

fn applyVelocityAccelerated(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []component.Acceleration) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = math.pow(f32, delta, 2);

    for (positions, velocities, accelerations) |*pos, *vel, *acc| {
        pos.x += (vel.x * delta) + (0.5 * acc.x * delta2);
        pos.y += (vel.y * delta) + (0.5 * acc.y * delta2);
    }
}

fn applyVelocityDynamic(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []component.Acceleration, jerks: []component.Jerk) void {
    const delta: f32 = it.delta_time;
    const delta2: f32 = math.pow(f32, delta, 2);
    const delta3: f32 = math.pow(f32, delta, 3);
    const sixth = 1.0 / 6.0;

    for (positions, velocities, accelerations, jerks) |*pos, *vel, *acc, *jerk| {
        pos.x += (vel.x * delta) + (0.5 * acc.x * delta2) + (sixth * jerk.x * delta3);
        pos.y += (vel.y * delta) + (0.5 * acc.y * delta2) + (sixth * jerk.y * delta3);
    }
}

pub const Model = struct {
    allocator: *std.mem.Allocator,
    world: *ecs.world_t,
    prng: std.Random.DefaultPrng,
    registry: core.Registry,

    pub fn init(allocator: *std.mem.Allocator) Model {
        var model = Model{
            .allocator = allocator,
            .world = ecs.init(),
            .prng = std.Random.DefaultPrng.init(@intCast(std.time.milliTimestamp())),
            .registry = core.Registry.init(allocator),
        };

        model.registerComponents();
        model.registerTags();
        model.registerSystems();

        //_ = createShip(&model, "Shuttle_0", .Small);
        //_ = createShip(&model, "Cargo-Shuttle", .Small);
        //_ = createShip(&model, "Frigatte", .Medium);
        //_ = createShip(&model, "Destroyer", .Large);
        //_ = createShip(&model, "Battleship", .Capital);

        return model;
    }

    pub fn deinit(self: *Model) void {
        _ = ecs.fini(self.world);
    }

    pub fn update(self: *Model) void {
        _ = ecs.progress(self.world, 0);
    }

    fn registerComponents(self: *Model) void {
        ecs.COMPONENT(self.world, component.Id);
        ecs.COMPONENT(self.world, component.Position);
        ecs.COMPONENT(self.world, component.Velocity);
        ecs.COMPONENT(self.world, component.Acceleration);
        ecs.COMPONENT(self.world, component.Jerk);
        ecs.COMPONENT(self.world, component.ShipSize);
    }

    fn registerTags(self: *Model) void {
        ecs.TAG(self.world, tag.Player);

        ecs.TAG(self.world, tag.Ship);

        ecs.TAG(self.world, tag.Small);
        ecs.TAG(self.world, tag.Medium);
        ecs.TAG(self.world, tag.Large);
        ecs.TAG(self.world, tag.Capital);

        ecs.TAG(self.world, tag.Visible);
    }

    fn registerSystems(self: *Model) void {
        const jerk_id = ecs.ADD_SYSTEM(self.world, "apply_jerk", ecs.OnUpdate, applyJerk);

        const accel_accelerated_id = ecs.ADD_SYSTEM(self.world, "apply_acceleration_accelerated", ecs.OnUpdate, applyAccelerationAccelerated);
        const accel_dynamic_id = ecs.ADD_SYSTEM(self.world, "apply_acceleration_dynamic", ecs.OnUpdate, applyAccelerationDynamic);

        const velocity_linear_id = ecs.ADD_SYSTEM(self.world, "apply_velocity_linear", ecs.OnUpdate, applyVelocityLinear);
        const velocity_accelerated_id = ecs.ADD_SYSTEM(self.world, "apply_velocity_accelerated", ecs.OnUpdate, applyVelocityAccelerated);
        const velocity_dynamic_id = ecs.ADD_SYSTEM(self.world, "apply_velocity_dynamic", ecs.OnUpdate, applyVelocityDynamic);

        _ = jerk_id;

        _ = accel_accelerated_id;
        _ = accel_dynamic_id;

        _ = velocity_linear_id;
        _ = velocity_accelerated_id;
        _ = velocity_dynamic_id;
    }

    //fn createShip(self: *Model, id: core.Id, name: [:0]const u8, size: component.ShipSize) ecs.entity_t {
    //    const ship = ecs.new_entity(self.world, name);
    //    self.registry.register(id, ship);
    //
    //    const rng = self.prng.random();
    //
    //    const x = rng.float(f32) * 1000;
    //    const y = rng.float(f32) * 200;
    //
    //    const ax = rng.float(f32) * 10;
    //    const ay = rng.float(f32) * 10;
    //
    //    _ = ecs.set(self.world, ship, component.Position, .{ .x = x, .y = y });
    //    _ = ecs.set(self.world, ship, component.Velocity, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, ship, component.Acceleration, .{ .x = ax, .y = ay });
    //    _ = ecs.set(self.world, ship, component.ShipSize, size);
    //    ecs.add(self.world, ship, tag.Ship);
    //    ecs.add(self.world, ship, tag.Visible);
    //
    //    switch (size) {
    //        .Small => ecs.add(self.world, ship, tag.Small),
    //        .Medium => ecs.add(self.world, ship, tag.Medium),
    //        .Large => ecs.add(self.world, ship, tag.Large),
    //        .Capital => ecs.add(self.world, ship, tag.Capital),
    //    }
    //
    //    return ship;
    //}
    //
    //pub fn createPlayer(self: *Model) ecs.entity_t {
    //    const player = ecs.new_id(self.world);
    //
    //    _ = ecs.set(self.world, player, component.Position, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, player, component.Velocity, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, player, component.Acceleration, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, player, component.Jerk, .{ .x = 100, .y = 100 });
    //    ecs.add(self.world, player, tag.Player);
    //    ecs.add(self.world, player, tag.Visible);
    //
    //    return player;
    //}

    pub fn createEntity(self: *Model, id: core.Id) void {
        const entity = ecs.new_id(self.world);
        self.registry.register(id, entity) catch unreachable;

        _ = ecs.set(self.world, entity, component.Position, .{ .x = 0, .y = 0 });
        _ = ecs.set(self.world, entity, component.Velocity, .{ .x = 10, .y = 10 });
        ecs.add(self.world, entity, tag.Player);
        ecs.add(self.world, entity, tag.Visible);
    }

    pub fn removeEntity(self: *Model, id: core.Id) void {
        const entity = self.registry.getEntity(id);
        if (entity) |e| {
            ecs.delete(self.world, e);
            self.registry.remove(id);
        }
    }

    pub fn addComponent(self: *Model, id: core.Id, T: type, value: T) void {
        const entity = self.registry.getEntity(id);

        if (entity) |e| {
            _ = ecs.set(self.world, e, T, value);
        } else {
            std.log.warn("Tried to add component to unknown entity", .{});
        }
    }

    pub fn removeComponent(self: *Model, id: core.Id, T: type) void {
        const entity = self.registry.getEntity(id);

        if (entity) |e| {
            _ = ecs.remove(self.world, e, T);
        } else {
            std.log.warn("Tried to remove component from unknown entity", .{});
        }
    }
};
