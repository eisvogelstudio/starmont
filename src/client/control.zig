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
const Model = core.model.Model;

pub const View = @import("view.zig").View;

pub const name = "client";

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

    fn getNetworkState() void {}
};
