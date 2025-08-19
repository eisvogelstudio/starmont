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

const TagType = enum {
    Player,
    Ship,
    SizeSmall,
    SizeMedium,
    SizeLarge,
    SizeCapital,
    Visible,
    MovementStatic,
    MovementKinematic,
    MovementPhysics,
    MovementScripted,
};

pub const Player = struct {};

pub const Ship = struct {};

pub const SizeSmall = struct {};
pub const SizeMedium = struct {};
pub const SizeLarge = struct {};
pub const SizeCapital = struct {};

pub const Visible = struct {};

pub const MovementStatic = struct {};
pub const MovementKinematic = struct {};
pub const MovementPhysics = struct {};
pub const MovementScripted = struct {};
