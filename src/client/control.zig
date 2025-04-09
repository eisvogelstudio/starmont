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
            self.client.connect("127.0.0.1", 11111) catch |err| {
                switch (err) {
                    error.Cooldown => {
                        //nothing
                    },
                    else => {
                        log.warn("could not connect to server", .{});
                    },
                }
            };
        }

        if (!self.client.connected) {
            return;
        }

        // Receive messages
        const data = self.client.receive();
        if (data) |messages| {
            defer {
                for (messages) |msg| {
                    msg.deinit();
                }
                self.allocator.free(messages);
            }

            for (messages) |msg| {
                msg.print(std.io.getStdOut().writer()) catch unreachable;
                std.io.getStdOut().writer().print("\n", .{}) catch unreachable;

                switch (msg) {
                    .Alpha => |alpha| {
                        self.model.tick = alpha.tick;
                    },
                    .Chat => |chat| {
                        _ = chat;
                    },
                    .Static => |static| {
                        _ = static;
                    },
                    .Linear => |linear| {
                        _ = linear;
                    },
                    .Accelerated => |accelerated| {
                        _ = accelerated;
                    },
                    .Dynamic => |dynamic| {
                        _ = dynamic;
                    },
                    .Action => |action| {
                        _ = action;
                    },
                    .Entity => |id| {
                        self.model.createEntity(id.id);
                    },
                    .EntityRemove => |id| {
                        self.model.removeEntity(id.id);
                    },
                    .Component => |comp| {
                        switch (comp.component) {
                            .Position => {
                                self.model.setComponent(comp.id, core.Position, comp.component.Position);
                            },
                            .Velocity => {
                                self.model.setComponent(comp.id, core.Velocity, comp.component.Velocity);
                            },
                            .Acceleration => {
                                self.model.setComponent(comp.id, core.Acceleration, comp.component.Acceleration);
                            },
                            .Jerk => {
                                self.model.setComponent(comp.id, core.Jerk, comp.component.Jerk);
                            },
                            .ShipSize => {
                                self.model.setComponent(comp.id, core.ShipSize, comp.component.ShipSize);
                            },
                        }
                    },
                    .ComponentRemove => |comp| {
                        switch (comp.component) {
                            .Position => {
                                self.model.removeComponent(comp.id, core.Position);
                            },
                            .Velocity => {
                                self.model.removeComponent(comp.id, core.Velocity);
                            },
                            .Acceleration => {
                                self.model.removeComponent(comp.id, core.Acceleration);
                            },
                            .Jerk => {
                                self.model.removeComponent(comp.id, core.Jerk);
                            },
                            .ShipSize => {
                                self.model.removeComponent(comp.id, core.ShipSize);
                            },
                        }
                    },
                }
            }
        } else |err| {
            switch (err) {
                error.WouldBlock => {
                    //nothing
                },
                error.ClosedConnection => {
                    log.info("connection closed by server", .{});
                },
                else => {
                    std.debug.print("receive error: {}\n", .{err});
                },
            }
        }

        // Construct and send a message
        //const msg = util.ComponentMessage.fromShipSize(.{ .id = 0 }, .Large);
        //self.client.send(msg) catch |err| {
        //    std.debug.print("send error: {}\n", .{err});
        //};
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
        if (rl.isKeyPressed(rl.KeyboardKey.space)) events.append(core.Action.SpawnPlayer) catch unreachable;

        return events; //TODO: move func to view
    }

    fn sendInput(self: *Control, actions: std.ArrayList(core.Action)) void {
        if (!self.client.connected) return;

        for (actions.items) |a| {
            self.client.send(util.ActionMessage.init(a)) catch |err| {
                log.err("failed to send action: {s}", .{@errorName(err)});
                continue;
            };
        }
    }
};
