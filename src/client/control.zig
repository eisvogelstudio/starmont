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
// -------------------------

// ---------- local ----------
const View = @import("view/view.zig").View;
// ----------------------------

// ---------- shared ----------
const core = @import("shared").core;
const network = @import("shared").network;
// ----------------------------

// ---------- frontend ----------
const frontend = @import("frontend");
// ----------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.control);

const name = "client";
// ╚══════════════════════════════════════════════════════════════════╝

// ┌──────────────────── State ────────────────────┐
const State = struct {
    should_stop: bool = false,
    should_request_snapshot: bool = true,
};
// └───────────────────────────────────────────────┘

// ┌──────────────────── Control ────────────────────┐
pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    view: View,
    client: network.Client,
    state: State,

    pub fn init(allocator: *std.mem.Allocator) Control {
        const control = Control{
            .allocator = allocator,
            .model = core.Model.init(allocator),
            .view = View.init(allocator),
            .client = network.Client.init(allocator),
            .state = State{},
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
        self.processFrontEvents();

        self.sendActions();

        self.model.update();
        self.view.update(&self.model);

        if (!self.client.is_connected) {
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

        if (!self.client.is_connected) {
            return;
        }

        if (self.state.should_request_snapshot) {
            self.client.submit(network.SnapshotRequestMessage.init());
            self.state.should_request_snapshot = false;
        }

        // Receive messages
        const data = self.client.receive();
        if (data) |batches| {
            defer {
                for (batches) |*b| {
                    b.*.deinit();
                }

                self.allocator.free(batches);
            }

            for (batches) |b| {
                for (b.messages.items) |message| {
                    switch (message) {
                        .Entity => |id| {
                            self.model.createEntity(id.id);
                        },
                        .EntityRemove => |id| {
                            self.model.removeEntity(id.id);
                        },
                        .Component => |comp| {
                            comp.apply(&self.model);
                        },
                        .ComponentRemove => |comp| {
                            comp.apply(&self.model);
                        },
                        else => @panic("received unexpected message"),
                    }
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

        self.client.update();
    }

    pub fn shouldStop(self: *Control) bool {
        return self.state.should_stop;
    }

    fn processFrontEvents(self: *Control) void {
        const events = std.ArrayList(frontend.FrontEvent).init(self.allocator.*);

        //TODO[MISSING]

        events.deinit();
    }

    fn sendActions(self: *Control) void {
        if (!self.client.is_connected) return;

        //for (actions.items) |a| {
        //    self.client.submit(network.ActionMessage.init(a));
        //}

        //TODO[MISSING]
    }

    //fn getNetworkState(self: *Control) void {
    //    const terms: [32]ecs.term_t = [_]ecs.term_t{
    //        ecs.term_t{ .id = ecs.id(core.Position) },
    //        ecs.term_t{ .id = ecs.id(core.ShipSize) },
    //        ecs.term_t{ .id = ecs.id(core.Ship) },
    //        ecs.term_t{ .id = ecs.id(core.Visible) },
    //    } ++ [_]ecs.term_t{ecs.term_t{}} ** 28;
    //
    //    var query_desc = ecs.query_desc_t{
    //        .terms = terms,
    //        .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
    //    };
    //
    //    const query = ecs.query_init(self.model.world, &query_desc) catch unreachable;
    //    defer ecs.query_fini(query);
    //
    //    var it = ecs.query_iter(self.model.world, query);
    //
    //    while (ecs.query_next(&it)) {
    //        const position: []const core.Position = ecs.field(&it, core.Position, 0).?;
    //        const velocities: []const core.ShipSize = ecs.field(&it, core.Velocity, 1).?;
    //        const accelerations: []const core.ShipSize = ecs.field(&it, core.Acceleration, 1).?;
    //
    //        for (0..it.count()) |i| {
    //            const entity = it.entities()[i];
    //
    //            _ = entity;
    //        }
    //
    //        _ = position;
    //        _ = velocities;
    //        _ = accelerations;
    //    }
    //}
};
// └─────────────────────────────────────────────────┘
