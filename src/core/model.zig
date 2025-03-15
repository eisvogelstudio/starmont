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

const std = @import("std");
const testing = std.testing;

const ecs = @import("zflecs");

const component = @import("component.zig");
const tag = @import("tag.zig");

fn move_system_with_it(it: *ecs.iter_t, positions: []component.Position, velocities: []component.Velocity, accelerations: []const component.Acceleration) void {
    //const type_str = ecs.table_str(it.world, it.table).?;
    //std.debug.print("Move entities with [{s}]\n", .{type_str});
    //defer ecs.os.free(type_str);

    const dt: f32 = it.delta_time;

    for (positions, velocities, accelerations) |*p, *v, a| {
        p.x += 0.5 * v.x * dt;
        p.y += 0.5 * v.y * dt;

        v.x += a.x * dt;
        v.y += a.y * dt;

        p.x += 0.5 * v.x * dt;
        p.y += 0.5 * v.y * dt;
    }
}

pub const Model = struct {
    allocator: *std.mem.Allocator,
    world: *ecs.world_t,
    prng: std.Random.DefaultPrng,

    pub fn init(allocator: *std.mem.Allocator) Model {
        var model = Model{
            .allocator = allocator,
            .world = ecs.init(),
            .prng = std.Random.DefaultPrng.init(@intCast(std.time.milliTimestamp())),
        };

        model.registerComponents();
        model.registerTags();
        model.registerSystems();

        _ = createShip(&model, "Shuttle_0", .Small);
        _ = createShip(&model, "Cargo-Shuttle", .Small);
        _ = createShip(&model, "Frigatte", .Medium);
        _ = createShip(&model, "Destroyer", .Large);
        _ = createShip(&model, "Battleship", .Capital);

        return model;
    }

    pub fn deinit(self: *Model) void {
        _ = ecs.fini(self.world);
    }

    pub fn update(self: *Model) void {
        _ = ecs.progress(self.world, 0);
    }

    fn registerComponents(self: *Model) void {
        ecs.COMPONENT(self.world, component.Position);
        ecs.COMPONENT(self.world, component.Velocity);
        ecs.COMPONENT(self.world, component.Acceleration);
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
        _ = ecs.ADD_SYSTEM(self.world, "move system", ecs.OnUpdate, move_system_with_it);
    }

    fn createShip(self: *Model, name: [:0]const u8, size: component.ShipSize) ecs.entity_t {
        const ship = ecs.new_entity(self.world, name);

        const rng = self.prng.random();

        const x = rng.float(f32) * 1000;
        const y = rng.float(f32) * 200;

        const ax = rng.float(f32) * 10;
        const ay = rng.float(f32) * 10;

        _ = ecs.set(self.world, ship, component.Position, .{ .x = x, .y = y });
        _ = ecs.set(self.world, ship, component.Velocity, .{ .x = 0, .y = 0 });
        _ = ecs.set(self.world, ship, component.Acceleration, .{ .x = ax, .y = ay });
        _ = ecs.set(self.world, ship, component.ShipSize, size);
        ecs.add(self.world, ship, tag.Ship);
        ecs.add(self.world, ship, tag.Visible);

        switch (size) {
            .Small => ecs.add(self.world, ship, tag.Small),
            .Medium => ecs.add(self.world, ship, tag.Medium),
            .Large => ecs.add(self.world, ship, tag.Large),
            .Capital => ecs.add(self.world, ship, tag.Capital),
        }

        return ship;
    }

    pub fn createPlayer(self: *Model) ecs.entity_t {
        const player = ecs.new_id(self.world);

        _ = ecs.set(self.world, player, component.Position, .{ .x = 0, .y = 0 });
        _ = ecs.set(self.world, player, component.Velocity, .{ .x = 0, .y = 0 });
        _ = ecs.set(self.world, player, component.Acceleration, .{ .x = 0, .y = 0 });
        ecs.add(self.world, player, tag.Player);
        ecs.add(self.world, player, tag.Visible);

        return player;
    }
};
