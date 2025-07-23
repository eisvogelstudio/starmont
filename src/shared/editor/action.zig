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

// ---------- shared ----------
const core = @import("../core/core.zig");
const util = @import("../util/util.zig");
// ----------------------------

pub const Tool = enum {
    Select,
    Move,
    Rotate,
    Scale,
    Paint,
    Collider,
    Pivot,
};

pub const Action = union(enum) {
    SelectPart: u32,
    DeleteSelected,
    DuplicateSelected,
    CreatePart,
    CreateCollider,
    PlacePivot,
    ToggleColliderView,
    ToggleSnapToGrid,
    ChangeTool: Tool,
    FileOpen: []const u8,
    FileSave,
    FileSaveAs: []const u8,
};
