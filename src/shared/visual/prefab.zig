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

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

pub const VisualPart = struct {
    image_path: []const u8,
    position: util.Vec2 = util.Vec2.zero(),
    rotation: util.Angle = util.Angle.zero(),
    scale: util.Vec2 = util.Vec2.one(),
    pivot: util.Vec2 = .{ .x = 0.5, .y = 0.5 },
};

pub const VisualPrefab = struct {
    parts: []const VisualPart = &[_]VisualPart{},
};
