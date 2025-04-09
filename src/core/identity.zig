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
const math = std.math;
const testing = std.testing;
// -------------------------

// ---------- starmont ----------
const core = @import("root.zig");
// ------------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

pub const Identity = struct {
    body: core.Id,

    pub fn init(body: core.Id) Identity {
        const identity = Identity{
            .body = body,
        };

        return identity;
    }

    pub fn deinit(self: *Identity) void {
        _ = self;
    }
};
