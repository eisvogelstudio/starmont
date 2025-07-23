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

// ---------- starmont ----------
const core = @import("shared").core;
const editor = @import("shared").editor;
const util = @import("util");
// ------------------------------

pub const FrontEvent = union(enum) {
    // ##### general #####
    Quit,
    TogglePause,
    ToggleFullscreen,
    Undo,
    Redo,
    MoveIntent: struct {
        entity: u32,
        direction: util.Vec2,
    },
    RotateIntent: struct {
        entity: u32,
        rotation: util.Angle,
    },

    // ##### camera #####
    CameraZoom: f32,
    CameraPan: util.Vec2,
    CameraFocusEntity: u32,
    CameraReset,

    // ##### editor #####
    Editor: editor.Action, //TODO[OPTIMISATION] make optional to save mem / only if editor

    // ##### game #####
    Action: core.Action, //TODO[OPTIMISATION] make optional to save mem / only if game

    // ##### debug #####
    ReloadAssets,
    ToggleDebugOverlay,
    LogState,
};
