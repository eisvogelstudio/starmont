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
// ------------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

const name = "server";

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    server: util.Server,
    player: ecs.entity_t = 0,

    pub fn init(allocator: *std.mem.Allocator) !Control {
        var control = Control{
            .allocator = allocator,
            .model = core.Model.init(allocator),
            .server = try util.Server.init(allocator),
        };

        control.server.open(11111) catch @panic("failed to open socket");

        std.log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        std.log.info("All your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        self.server.deinit();
        self.model.deinit();

        std.log.info("stopped sucessfully", .{});
    }

    pub fn update(self: *Control) void {
        self.model.update();

        self.server.accept() catch return;

        const msgs = self.server.receive(self.allocator) catch return;
        defer {
            for (msgs) |msg| {
                switch (msg) {
                    util.Message.Chat => |chat| {
                        chat.deinit(self.allocator);
                    },
                    util.Message.Static => |static| {
                        static.deinit();
                    },
                    util.Message.Linear => |linear| {
                        linear.deinit();
                    },
                    util.Message.Accelerated => |accelerated| {
                        accelerated.deinit();
                    },
                    util.Message.Dynamic => |dynamic| {
                        dynamic.deinit();
                    },
                    util.Message.Action => |act| {
                        act.deinit();
                    },
                }
            }
            self.allocator.free(msgs);
        }

        for (msgs) |msg| {
            switch (msg) {
                util.Message.Chat => |chat| {
                    std.debug.print("Chat: {s}\n", .{chat.text});
                },
                util.Message.Static => |static| {
                    std.debug.print("Position: ({}, {})\n", .{ static.position.x, static.position.y });
                },
                util.Message.Linear => |linear| {
                    std.debug.print("Velocity: ({}, {})\n", .{ linear.velocity.x, linear.velocity.y });
                },
                util.Message.Accelerated => |accelerated| {
                    std.debug.print("Acceleration: ({}, {})\n", .{ accelerated.acceleration.x, accelerated.acceleration.y });
                    if (self.player != 0) self.model.moveEntity(self.player, accelerated.position);
                },
                util.Message.Dynamic => |dynamic| {
                    std.debug.print("Acceleration: ({}, {})\n", .{ dynamic.acceleration.x, dynamic.acceleration.y });
                    if (self.player != 0) self.model.moveEntity(self.player, dynamic.position);
                },
                util.Message.Action => |act| {
                    std.debug.print("Action: ({s})\n", .{@tagName(act.action)});
                    if (self.player != 0) self.player = self.model.createPlayer();
                },
            }
        }

        if (self.server.clients.items.len < 1) return;

        const msg = util.Message{ .Static = util.StaticMessage.init(.{ .x = 1, .y = 0 }) };

        self.server.send(0, msg) catch unreachable;
    }

    pub fn shouldStop(self: *Control) bool {
        _ = self;
        return false;
    }
};
