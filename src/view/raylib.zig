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
const rl = @import("raylib");
// ------------------------------

pub fn getScreenWidth() i32 {
    return 1;
}

pub fn getScreenHeight() i32 {
    return 1;
}

pub fn getRenderWidth() i32 {
    return 1;
}

pub fn getRenderHeight() i32 {
    return 1;
}

pub fn setMouseScale(scaleX: f32, scaleY: f32) void {
    _ = scaleX;
    _ = scaleY;
}

pub fn getWindowScaleDPI() rl.Vector2 {
    return rl.Vector2{ .x = 1, .y = 1 };
}

pub fn setTargetFPS(fps: i32) void {
    _ = fps;
}

pub fn beginDrawing() void {}

pub fn endDrawing() void {}

pub fn initWindow(_: i32, _: i32, _: [:0]const u8) void {}

pub fn closeWindow() void {}

pub fn windowShouldClose() bool {
    return true;
}

pub fn isWindowReady() bool {
    return false;
}

pub fn isWindowFullscreen() bool {
    return false;
}

pub fn isWindowHidden() bool {
    return false;
}

pub fn isWindowMinimized() bool {
    return false;
}

pub fn isWindowMaximized() bool {
    return false;
}

pub fn isWindowFocused() bool {
    return false;
}

pub fn isWindowResized() bool {
    return false;
}

pub fn isWindowState(_: rl.ConfigFlags) bool {
    return false;
}

pub fn setWindowState(_: rl.ConfigFlags) void {}

pub fn clearWindowState(_: rl.ConfigFlags) void {}

pub fn toggleFullscreen() void {}

pub fn toggleBorderlessWindowed() void {}

pub fn maximizeWindow() void {}

pub fn minimizeWindow() void {}

pub fn restoreWindow() void {}

pub fn setWindowIcon(_: rl.Image) void {}

pub fn setWindowTitle(_: [:0]const u8) void {}

pub fn setWindowPosition(_: i32, _: i32) void {}

pub fn setWindowMonitor(_: i32) void {}

pub fn setWindowMinSize(_: i32, _: i32) void {}

pub fn setWindowMaxSize(_: i32, _: i32) void {}

pub fn setWindowSize(_: i32, _: i32) void {}

pub fn setWindowOpacity(_: f32) void {}

pub fn setWindowFocused() void {}

pub fn getWindowHandle() *anyopaque {
    return null;
}
