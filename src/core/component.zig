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

const ecs = @import("zflecs");

pub const Position = struct {
    x: f32,
    y: f32,
};

pub const Velocity = struct {
    x: f32,
    y: f32,
};

pub const Acceleration = struct {
    x: f32,
    y: f32,
};

pub const ShipSize = enum {
    Small,
    Medium,
    Large,
    Capital,
};
