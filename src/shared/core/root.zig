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

pub const name = "starmont";
pub const version = "0.1.0-dev";

const action = @import("action.zig");
pub const Action = action.Action;

const identity = @import("identity.zig");
pub const Identity = identity.Identity;

const registry = @import("registry.zig");
pub const Id = registry.Id;
pub const Registry = registry.Registry;

const model = @import("model.zig");
pub const Model = model.Model;

pub usingnamespace @import("component.zig");
pub usingnamespace @import("tag.zig");
