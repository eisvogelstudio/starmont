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

// ---------- options ----------
const build_options = @import("build_options");
const hasRenderer = build_options.hasRenderer;
// -----------------------------

// ---------- special -----------
const rl = if (hasRenderer) @import("raylib") else @import("raylib.zig");
// ------------------------------

var _width: i32 = undefined;
var _height: i32 = undefined;

pub const Window = struct {
    pub fn open(title: []const u8, width: i32, height: i32) void {
        _ = title;
        _width = width;
        _height = height;

        rl.initWindow(width, height, "todo");
        rl.setTargetFPS(60);

        update();
    }

    pub fn update() void {
        applyScale();
    }

    pub fn close() void {
        rl.closeWindow();
    }

    pub fn shouldClose() bool {
        return rl.windowShouldClose();
    }

    pub fn beginFrame() void {
        rl.beginDrawing();
    }

    pub fn endFrame() void {
        rl.endDrawing();
    }

    pub fn clear() void {
        rl.clearBackground(rl.Color.gold);
    }

    pub fn getWidth() i32 {
        return rl.getScreenWidth();
    }

    pub fn getHeight() i32 {
        return rl.getScreenHeight();
    }

    fn applyScale() void {
        const dpiScale = rl.getWindowScaleDPI();
        const newWidth = @divFloor(@as(f32, @floatFromInt(_width)), dpiScale.x);
        const newHeight = @divFloor(@as(f32, @floatFromInt(_height)), dpiScale.y);

        rl.setWindowSize(@intFromFloat(newWidth), @intFromFloat(newHeight));
        rl.setMouseScale(dpiScale.x, dpiScale.y);
    }
};
