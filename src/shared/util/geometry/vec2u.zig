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

// ---------- util/geometry ----------
const Vec2 = @import("vec2.zig").Vec2;
// -----------------------------------

// ---------- shared ----------
const network = @import("../../network/network.zig");
// ----------------------------

const Vec2u = struct {
    x: u32,
    y: u32,

    pub fn init(x: u32, y: u32) Vec2u {
        return .{ .x = x, .y = y };
    }

    pub fn add(self: Vec2u, other: Vec2u) Vec2u {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn toVec2(self: Vec2u) Vec2 {
        return .{ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y) };
    }
};
