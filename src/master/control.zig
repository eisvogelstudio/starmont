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

// ---------- starmont ----------
const core = @import("shared").core;
const network = @import("extra").network;
// ------------------------------

const log = std.log.scoped(.control);

const name = "master";

pub const Control = struct {
    allocator: *std.mem.Allocator,
    server: network.Server,

    pub fn init(allocator: *std.mem.Allocator) Control {
        var control = Control{
            .allocator = allocator,
            .server = network.Server.init(allocator),
        };

        control.server.open(11111);

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        self.server.deinit();

        log.info("stopped sucessfully", .{});
    }

    pub fn update(self: *Control) void {
        self.server.update();
    }

    pub fn shouldStop(self: *Control) bool {
        _ = self;
        return false;
    }
};
