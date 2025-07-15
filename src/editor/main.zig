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

// ---------- builtin ----------
const builtin = @import("builtin");
// -------------------------

// ---------- std ----------
const std = @import("std");
// -------------------------

// ---------- client ----------
const Control = @import("control.zig").Control;
// ----------------------------

// ---------- shared ----------
const util = @import("shared").util;
// ----------------------------

pub const std_options: std.Options = .{
    .log_level = if (builtin.mode == .Debug) .debug else .info,
    //.log_scope_levels = &.{
    //    .{ .scope = .decimal, .level = .info },
    //    .{ .scope = .proper, .level = .info },
    //},
    .logFn = util.log.logFn,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    var allocator = gpa.allocator();

    var control = Control.init(&allocator);

    while (!control.shouldStop()) {
        control.update();
    }

    control.deinit();
}

test {
    std.testing.refAllDecls(@This());
}
