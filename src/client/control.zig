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

const core = @import("core");
const component = core.component;
const tag = core.tag;
const Model = core.model.Model;

pub const View = @import("view.zig").View;

const ecs = @import("zflecs");

const name = "client";

const NetworkState = struct {
    entities: []ecs.entity_t,
    positions: []const component.Position,
    velocities: []const component.Velocity,
    accelerations: []const component.Acceleration,
};

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: Model,
    view: View,

    pub fn init(allocator: *std.mem.Allocator) Control {
        const control = Control{
            .allocator = allocator,
            .model = Model.init(allocator),
            .view = View.init(allocator),
        };

        std.log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        std.log.info("All your starbase are belong to us.", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        self.model.deinit();
        self.view.deinit();

        std.log.info("stopped sucessfully", .{});
    }

    pub fn update(self: *Control) void {
        self.model.update();
        self.view.update(&self.model);
    }

    pub fn shouldStop(self: *Control) bool {
        return self.view.shouldStop();
    }

    fn getNetworkState(self: *Control) void {
        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(component.Position) },
            ecs.term_t{ .id = ecs.id(component.ShipSize) },
            ecs.term_t{ .id = ecs.id(tag.Ship) },
            ecs.term_t{ .id = ecs.id(tag.Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 28;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(self.model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(self.model.world, query);

        while (ecs.query_next(&it)) {
            const position: []const component.Position = ecs.field(&it, component.Position, 0).?;
            const velocities: []const component.ShipSize = ecs.field(&it, component.Velocity, 1).?;
            const accelerations: []const component.ShipSize = ecs.field(&it, component.Acceleration, 1).?;

            for (0..it.count()) |i| {
                const entity = it.entities()[i];

                _ = entity;
            }

            _ = position;
            _ = velocities;
            _ = accelerations;
        }
    }

    fn setNetworkState(self: *Control, state: *const NetworkState) void {
        const count = state.entities.len;
        for (0..count) |i| {
            const entity = state.entities[i];

            if (ecs.is_alive(self.world, entity)) {
                _ = ecs.set(self.world, entity, component.Position, state.positions[i]);
                _ = ecs.set(self.world, entity, component.Velocity, state.velocities[i]);
                _ = ecs.set(self.world, entity, component.Acceleration, state.accelerations[i]);
            }
        }
    }
};
