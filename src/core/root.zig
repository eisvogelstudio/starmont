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
const testing = std.testing;
// -------------------------

pub const name = "starmont";
pub const version = "0.1.0-dev";

pub usingnamespace @import("action.zig");
pub usingnamespace @import("component.zig");
pub usingnamespace @import("identity.zig");
pub usingnamespace @import("model.zig");
pub usingnamespace @import("registry.zig");
pub usingnamespace @import("tag.zig");
