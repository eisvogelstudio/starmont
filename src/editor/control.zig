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

// ---------- shared ----------
const core = @import("shared").core;
const network = @import("shared").network;
// ----------------------------

// ---------- external ----------
const ecs = @import("zflecs");
//const rl = @import("raylib");
// ------------------------------

const log = std.log.scoped(.control);

const name = "editor";

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    client: network.Client,
    snapshotRequired: bool = true,

    pub fn init(allocator: *std.mem.Allocator) Control {
        const control = Control{
            .allocator = allocator,
            .model = core.Model.init(allocator),
            .client = network.Client.init(allocator),
        };

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        _ = self;

        log.info("stopped sucessfully", .{});
    }

    pub fn update(self: *Control) void {
        const actions = captureInput(self.allocator);
        actions.deinit();
    }

    pub fn shouldStop(self: *Control) bool {
        //return self.view.shouldStop();
        _ = self;
        return false;
    }

    fn captureInput(allocator: *std.mem.Allocator) std.ArrayList(core.Action) {
        const events = std.ArrayList(core.Action).init(allocator.*);

        return events; //TODO: move func to view
    }
};
