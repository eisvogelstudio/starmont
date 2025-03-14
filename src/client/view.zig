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

pub const View = struct {
    allocator: *std.mem.Allocator,

    const screenWidth = 800;
    const screenHeight = 450;

    pub fn init(allocator: *std.mem.Allocator) View {
        const view = View{
            .allocator = allocator,
        };

        rl.setTraceLogLevel(rl.TraceLogLevel.warning);

        rl.initWindow(screenWidth, screenHeight, core.name ++ " v" ++ core.version);

        rl.setTargetFPS(60);

        return view;
    }

    pub fn deinit(self: *View) void {
        _ = self;
        rl.closeWindow();
    }

    pub fn update(self: *View, model: *core.Model) void {
        _ = self;
        const ships = model.getVisibleShips() catch unreachable;
        View.renderShips(ships);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        const text = "Welcome to " ++ core.name ++ " - till the stars and far beyond";
        const fontSize = 20;

        const textWidth = rl.measureText(text, fontSize);
        const textHeight = fontSize;
        const x = @divTrunc((screenWidth - textWidth), 2);
        const y = @divTrunc((screenHeight - textHeight), 2);

        rl.drawText(text, x, y, fontSize, rl.Color.light_gray);
    }

    pub fn shouldStop(self: *View) bool {
        _ = self;

        return rl.windowShouldClose();
    }

    pub fn renderShips(ships: []const core.ShipData) void {
        for (ships) |s| {
            rl.drawCircle(@intFromFloat(@mod(s.x, screenWidth)), @intFromFloat(@mod(s.y, screenHeight)), 10, rl.Color.sky_blue);
        }
    }
};
