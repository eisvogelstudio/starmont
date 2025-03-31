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
const testing = std.testing;
// -------------------------

// ---------- starmont ----------
const core = @import("core");
const util = @import("util");

pub const View = @import("view.zig").View;
// ------------------------------

// ---------- external ----------
const ecs = @import("zflecs");
const rl = @import("raylib");
// ------------------------------

const log = std.log.scoped(.control);

const name = "client";

const NetworkState = struct {
    entities: []ecs.entity_t,
    positions: []const core.Position,
    velocities: []const core.Velocity,
    accelerations: []const core.Acceleration,
};

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    view: View,
    client: util.Client,

    pub fn init(allocator: *std.mem.Allocator) Control {
        const control = Control{
            .allocator = allocator,
            .model = core.Model.init(allocator),
            .view = View.init(allocator),
            .client = util.Client.init(allocator),
        };

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        self.client.deinit();
        self.model.deinit();
        self.view.deinit();

        log.info("stopped sucessfully", .{});
    }

    pub fn update(self: *Control) void {
        const actions = captureInput(self.allocator);
        self.sendInput(actions);
        actions.deinit();

        self.model.update();
        self.view.update(&self.model);

        if (!self.client.connected) {
            self.client.connect("127.0.0.1", 11111);
        } else {
            const msgs = self.client.receive() catch return;
            defer {
                for (msgs) |msg| {
                    msg.deinit(self.allocator);
                }
                self.allocator.free(msgs);
            }

            for (msgs) |msg| {
                msg.print(std.io.getStdOut().writer()) catch @panic("error dsfds");
            }

            //const msg = util.Message{ .Chat = .{ .text = "Hello there" } };
            //const msg2 = util.Message{ .Position = util.PositionMessage.init(.{ .x = 1, .y = 0 }) };

            //self.client.send(msg) catch unreachable;
            //self.client.send(msg2) catch unreachable;
        }
    }

    pub fn shouldStop(self: *Control) bool {
        return self.view.shouldStop();
    }

    fn getNetworkState(self: *Control) void {
        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(core.Position) },
            ecs.term_t{ .id = ecs.id(core.ShipSize) },
            ecs.term_t{ .id = ecs.id(core.Ship) },
            ecs.term_t{ .id = ecs.id(core.Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 28;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(self.model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(self.model.world, query);

        while (ecs.query_next(&it)) {
            const position: []const core.Position = ecs.field(&it, core.Position, 0).?;
            const velocities: []const core.ShipSize = ecs.field(&it, core.Velocity, 1).?;
            const accelerations: []const core.ShipSize = ecs.field(&it, core.Acceleration, 1).?;

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
                _ = ecs.set(self.world, entity, core.Position, state.positions[i]);
                _ = ecs.set(self.world, entity, core.Velocity, state.velocities[i]);
                _ = ecs.set(self.world, entity, core.Acceleration, state.accelerations[i]);
            }
        }
    }

    fn captureInput(allocator: *std.mem.Allocator) std.ArrayList(core.Action) {
        var events = std.ArrayList(core.Action).init(allocator.*);

        if (rl.isKeyDown(rl.KeyboardKey.w)) events.append(core.Action.MoveForward) catch unreachable;
        if (rl.isKeyDown(rl.KeyboardKey.a)) events.append(core.Action.MoveLeft) catch unreachable;
        if (rl.isKeyDown(rl.KeyboardKey.s)) events.append(core.Action.MoveBackward) catch unreachable;
        if (rl.isKeyDown(rl.KeyboardKey.d)) events.append(core.Action.MoveRight) catch unreachable;
        if (rl.isKeyPressed(rl.KeyboardKey.space)) events.append(core.Action.Fire) catch unreachable;

        return events;
    }

    fn sendInput(self: *Control, actions: std.ArrayList(core.Action)) void {
        if (!self.client.connected) return;

        for (actions.items) |a| {
            const msg = util.Message{ .Action = util.ActionMessage.init(a) };
            self.client.send(msg) catch unreachable;
        }
    }
};
