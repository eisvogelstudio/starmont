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

pub const Control = struct {
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) Control {
        const view = Control{
            .allocator = allocator,
        };

        return view;
    }

    pub fn deinit(self: *Control) void {
        _ = self;
    }

    pub fn update(self: *Control) void {
        _ = self;
    }
};
