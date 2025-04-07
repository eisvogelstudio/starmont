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

pub const log_scope = .control;

const name = "server";

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    server: util.Server,
    player: ecs.entity_t = 0,
    count: i32 = 0,

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
                msg.deinit(self.allocator);
            }
            self.allocator.free(msgs);
        }

        for (msgs) |msg| {
            msg.print(std.io.getStdOut().writer()) catch @panic("error dsfds");

            if (self.server.clients.items.len < 1) return;
            const spawn = util.EntityMessage.init(.{ .id = 0 });
            self.server.send(0, spawn) catch unreachable;
            self.count += 1;
            std.log.info("count: {d}\n", .{self.count});
        }

        //if (self.server.clients.items.len < 1) return;

        //const msg = util.Message{ .Static = util.StaticMessage.init(.{ .x = 1, .y = 0 }) };

        //self.server.send(0, msg) catch unreachable;
    }

    pub fn shouldStop(self: *Control) bool {
        _ = self;
        return false;
    }
};
