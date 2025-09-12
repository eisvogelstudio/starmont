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

// ---------- std ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const core = @import("shared").core;
const network = @import("extra").network;
const util = @import("util");
const Model = @import("model").Model;
// ----------------------------

const log = std.log.scoped(.control);

const name = "server";

var already = false;

pub const Control = struct {
    gpa: *std.mem.Allocator,
    model: Model,
    server: network.Server,

    pub fn init(gpa: *std.mem.Allocator) !Control {
        var control = Control{
            .gpa = gpa,
            .model = Model.init(gpa),
            .server = network.Server.init(gpa),
        };

        control.server.open(11111);

        log.info("{s}-{s} v{s} started successfully", .{ core.name, name, core.version });
        log.info("all your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        self.server.deinit();
        self.model.deinit();

        log.info("stopped successfully", .{});
    }

    pub fn update(self: *Control) void {
        self.model.update();

        //self.server.accept();
        //const data = self.server.withdraw(self.gpa);
        //
        //if (data) |batches| {
        //    defer {
        //        for (batches) |*b| {
        //            b.*.deinit();
        //        }
        //        self.gpa.free(batches);
        //    }
        //
        //    for (batches) |b| {
        //        for (b.messages.items) |msg| {
        //            //check if is valid
        //            //apply/apply best effort version
        //
        //            switch (msg) {
        //                .Action => |action| {
        //                    switch (action.action) {
        //                        //.SpawnPlayer => {
        //                        //self.model.createEntity(id);
        //                        //const cmsg = network.EntityMessage.init(id);
        //
        //                        //var it = self.server.clients.iterator();
        //                        //while (it.next()) |entry| {
        //                        //    self.server.submit(entry.key_ptr.*, cmsg) catch unreachable;
        //                        // }
        //                        //},
        //                        //.MoveLeft => {
        //                        //    self.model.setComponent(id, core.Velocity, .{ .x = -100, .y = 0 });
        //                        //},
        //                        //.MoveRight => {
        //                        //    self.model.setComponent(id, core.Velocity, .{ .x = 100, .y = 0 });
        //                        //},
        //                        //.MoveForward => {
        //                        //    self.model.setComponent(id, core.Velocity, .{ .x = 0, .y = -100 });
        //                        //},
        //                        //.MoveBackward => {
        //                        //    self.model.setComponent(id, core.Velocity, .{ .x = 0, .y = 100 });
        //                        //},
        //                        //.Fire => {
        //                        //    //nothing
        //                        //},
        //                        else => @panic("received unexpected message"),
        //                    }
        //                },
        //                .SnapshotRequest => {
        //                    std.debug.print("requested snapshot\n", .{});
        //                    self.sendSnapshot();
        //                },
        //                else => @panic("received unexpected message"),
        //            }
        //        }
        //    }
        //} else |err| {
        //    switch (err) {
        //        error.WouldBlock => {
        //            //nothing
        //        },
        //    }
        //}

        //if (self.server.clients.count() > 0 and !already) {
        //    self.sendSnapshot();
        //    already = true;
        //}

        //self.syncEntites();

        //self.server.update();
    }

    fn syncEntites(self: *Control) void {
        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(core.Position) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 31;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(self.model.registry.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var ecsIt = ecs.query_iter(self.model.registry.world, query);

        ////##### force tick
        //const tick_msg = network.TickMessage.init(self.model.tick);
        //
        //var it = self.server.clients.iterator();
        //while (it.next()) |entry| {
        //    self.server.submit(entry.key_ptr.*, tick_msg) catch unreachable;
        //}
        ////#####

        while (ecs.query_next(&ecsIt)) {
            const positions: []const core.Position = ecs.field(&ecsIt, core.Position, 0).?;

            for (0..ecsIt.count()) |i| {
                //log.info("synx", .{});
                const entity = ecsIt.entities()[i];
                const id = self.model.registry.getId(entity);

                const msg = network.msg.ComponentMessage.fromPosition(id.?, positions[i]);

                var it2 = self.server.clients.iterator();
                while (it2.next()) |entry| {
                    self.server.submit(entry.key_ptr.*, msg) catch unreachable;
                }
            }
        }
    }

    fn sendSnapshot(self: *Control) void {
        log.debug("send snapshot", .{});

        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(core.Position) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 31;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(self.model.registry.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var ecsIt = ecs.query_iter(self.model.registry.world, query);

        while (ecs.query_next(&ecsIt)) {
            const positions: []const core.Position = ecs.field(&ecsIt, core.Position, 0).?;

            for (0..ecsIt.count()) |i| {
                log.debug("x", .{});
                const entity = ecsIt.entities()[i];
                const id = self.model.registry.getId(entity);

                const createmsg = network.msg.EntityMessage.init(id.?);
                const msg = network.msg.ComponentMessage.fromPosition(id.?, positions[i]);

                var it = self.server.clients.iterator();
                while (it.next()) |entry| {
                    self.server.submit(entry.key_ptr.*, createmsg) catch {
                        continue;
                    };
                    self.server.submit(entry.key_ptr.*, msg) catch unreachable;
                }
            }
        }
    }

    pub fn shouldStop(self: *Control) bool {
        _ = self;
        return false;
    }
};
