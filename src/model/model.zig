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

// ---------- starmont ------
const core = @import("shared").core;
const msg = @import("extra").network.msg;
// --------------------------

const log = std.log.scoped(.model);

const velocity_max: core.Velocity = .{
    .x = 200,
    .y = 200,
};

pub const Model = struct {
    allocator: *std.mem.Allocator,
    registry: core.Registry,

    var random = std.Random.DefaultPrng.init(0);

    pub fn init(allocator: *std.mem.Allocator) Model {
        const model = Model{
            .allocator = allocator,
            .registry = core.Registry.init(allocator, random.random()),
        };

        return model;
    }

    pub fn deinit(self: *Model) void {
        self.registry.deinit();
    }

    pub fn apply(self: *Model, other: *Model) void {
        _ = self;
        _ = other;
    }

    pub fn update(self: *Model) void {
        self.registry.update();
    }

    //fn createShip(self: *Model, id: core.Id, name: [:0]const u8, size: core.ShipSize) ecs.entity_t {
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
    //    _ = ecs.set(self.world, ship, core.Position, .{ .x = x, .y = y });
    //    _ = ecs.set(self.world, ship, core.Velocity, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, ship, core.Acceleration, .{ .x = ax, .y = ay });
    //    _ = ecs.set(self.world, ship, core.ShipSize, size);
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
    //    _ = ecs.set(self.world, player, core.Position, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, player, core.Velocity, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, player, core.Acceleration, .{ .x = 0, .y = 0 });
    //    _ = ecs.set(self.world, player, core.Jerk, .{ .x = 100, .y = 100 });
    //    ecs.add(self.world, player, tag.Player);
    //    ecs.add(self.world, player, tag.Visible);
    //
    //    return player;
    //}
};
