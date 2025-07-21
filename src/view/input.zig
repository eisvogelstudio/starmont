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

// ---------- special -----------
const rl = @import("raylib");
// ------------------------------

pub const Input = struct {
    pub const KeyboardKey = rl.KeyboardKey;
    pub const MouseButton = rl.MouseButton;
    pub const Vector2 = rl.Vector2; //TODO use own vec2

    pub const isKeyDown = rl.isKeyDown;
    pub const isKeyUp = rl.isKeyUp;
    pub const isKeyPressed = rl.isKeyPressed;
    pub const isKeyReleased = rl.isKeyReleased;

    pub const isMouseButtonDown = rl.isMouseButtonDown;
    pub const isMouseButtonUp = rl.isMouseButtonUp;
    pub const isMouseButtonPressed = rl.isMouseButtonPressed;
    pub const isMouseButtonReleased = rl.isMouseButtonReleased;

    pub const getMousePosition = rl.getMousePosition;
    pub const getMouseDelta = rl.getMouseDelta;
    pub const getMouseWheelMove = rl.getMouseWheelMove;
    pub const getMouseWheelMoveV = rl.getMouseWheelMoveV;
};
