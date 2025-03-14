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

const Position = struct { x: f32, y: f32 };
const Velocity = struct { x: f32, y: f32 };
const Acceleration = struct { x: f32, y: f32 };

pub const ShipSize = enum {
    Small,
    Medium,
    Large,
    Capital,
};

pub const Ship = struct {};

pub const Small = struct {};
pub const Medium = struct {};
pub const Large = struct {};
pub const Capital = struct {};

pub const Visible = struct {};

pub const ShipData = struct {
    x: f32,
    y: f32,
    size: ShipSize,
};

fn move_system_with_it(it: *ecs.iter_t, positions: []Position, velocities: []Velocity, accelerations: []const Acceleration) void {
    const type_str = ecs.table_str(it.world, it.table).?;
    //std.debug.print("Move entities with [{s}]\n", .{type_str});
    defer ecs.os.free(type_str);

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

        //const shuttle = ecs.new_entity(model.world, "Shuttle");
        // = ecs.set(model.world, shuttle, Position, .{ .x = 0, .y = 0 });
        //_ = ecs.set(model.world, shuttle, Velocity, .{ .x = 0, .y = 0 });
        //_ = ecs.set(model.world, shuttle, Acceleration, .{ .x = 2, .y = 4 });
        //_ = ecs.set(model.world, shuttle, ShipSize, .Small);
        //ecs.add(model.world, shuttle, Ship);
        //ecs.add(model.world, shuttle, Small);
        //ecs.add(model.world, shuttle, Visible);

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

    pub fn registerComponents(self: *Model) void {
        ecs.COMPONENT(self.world, Position);
        ecs.COMPONENT(self.world, Velocity);
        ecs.COMPONENT(self.world, Acceleration);
        ecs.COMPONENT(self.world, ShipSize);
    }

    pub fn registerTags(self: *Model) void {
        ecs.TAG(self.world, Ship);

        ecs.TAG(self.world, Small);
        ecs.TAG(self.world, Medium);
        ecs.TAG(self.world, Large);
        ecs.TAG(self.world, Capital);

        ecs.TAG(self.world, Visible);
    }

    pub fn registerSystems(self: *Model) void {
        _ = ecs.ADD_SYSTEM(self.world, "move system", ecs.OnUpdate, move_system_with_it);
        //_ = self;
    }

    pub fn getVisibleShips(self: *Model) ![]ShipData {
        //var terms: [32]ecs.term_t = undefined;
        //terms[0] = ecs.term_t{ .id = ecs.id(Position) };
        //terms[1] = ecs.term_t{ .id = ecs.id(Ship) };
        //terms[2] = ecs.term_t{ .id = ecs.id(Visible) };

        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(Position) },
            ecs.term_t{ .id = ecs.id(ShipSize) },
            ecs.term_t{ .id = ecs.id(Ship) },
            ecs.term_t{ .id = ecs.id(Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 28;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(self.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(self.world, query);

        var ships_list = std.ArrayList(ShipData).init(self.allocator.*);
        defer ships_list.deinit();

        while (ecs.query_next(&it)) {
            const ships: []const Position = ecs.field(&it, Position, 0).?;
            const sizes: []const ShipSize = ecs.field(&it, ShipSize, 1).?;

            for (0..ships.len) |i| {
                //const entity = it.entities()[i];
                //std.log.info("{s}", .{ecs.get_name(self.world, entity)});

                ships_list.append(ShipData{
                    .x = ships[i].x,
                    .y = ships[i].y,
                    .size = sizes[i],
                }) catch unreachable;
            }
        }

        return ships_list.toOwnedSlice();
    }

    pub fn createShip(self: *Model, name: [:0]const u8, size: ShipSize) ecs.entity_t {
        const ship = ecs.new_entity(self.world, name);

        const rng = self.prng.random();

        const x = rng.float(f32) * 1000;
        const y = rng.float(f32) * 200;

        const ax = rng.float(f32) * 10;
        const ay = rng.float(f32) * 10;

        _ = ecs.set(self.world, ship, Position, .{ .x = x, .y = y });
        _ = ecs.set(self.world, ship, Velocity, .{ .x = 0, .y = 0 });
        _ = ecs.set(self.world, ship, Acceleration, .{ .x = ax, .y = ay });

        _ = ecs.set(self.world, ship, ShipSize, size);
        ecs.add(self.world, ship, Ship);
        ecs.add(self.world, ship, Visible);

        switch (size) {
            .Small => ecs.add(self.world, ship, Small),
            .Medium => ecs.add(self.world, ship, Medium),
            .Large => ecs.add(self.world, ship, Large),
            .Capital => ecs.add(self.world, ship, Capital),
        }

        return ship;
    }
};
