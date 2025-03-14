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
const util = @import("util");

const rl = @import("raylib");

pub const View = @import("view.zig").View;

const Model = core.Model;

pub const name = "client";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    var allocator = gpa.allocator();

    var model = Model.init(&allocator);
    defer model.deinit();

    var view = View.init(&allocator);
    defer view.deinit();

    std.log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
    std.log.info("All your starbase are belong to us.", .{});

    while (!view.shouldStop()) {
        model.update();
        view.update(&model);
    }

    util.helloutil();
}
