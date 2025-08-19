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

// ╔══════════════════════════════ init ══════════════════════════════╗
pub const name = "starmont";
pub const version = "0.1.0-dev";
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ pack ══════════════════════════════╗
// ┌──────────────────── character ────────────────────┐
pub const Action = @import("character/action.zig").Action;
pub const Identity = @import("character/identity.zig").Identity;
// └───────────────────────────────────────────────────┘
// ┌──────────────────── physics ────────────────────┐
pub const Collider = @import("physics/collider.zig").Collider;
pub const Prefab = @import("physics/collider.zig").Prefab;
pub const PrefabDTO = @import("physics/collider.zig").PrefabDTO;
// └─────────────────────────────────────────────────┘
// ┌──────────────────── world ────────────────────┐
pub const tilemap = @import("world/tilemap.zig");
// └───────────────────────────────────────────────┘
// ---------- component ----------
pub const ComponentType = @import("component.zig").ComponentType;
pub const Position = @import("component.zig").Position;
pub const Velocity = @import("component.zig").Velocity;
pub const Acceleration = @import("component.zig").Acceleration;
pub const Jerk = @import("component.zig").Jerk;
pub const Rotation = @import("component.zig").Rotation;
pub const AngularVelocity = @import("component.zig").AngularVelocity;
pub const AngularAcceleration = @import("component.zig").AngularAcceleration;
pub const ShipSize = @import("component.zig").ShipSize;
// ------------------------------
// ---------- registry ----------
pub const Id = @import("registry.zig").Id;
pub const Registry = @import("registry.zig").Registry;
// ------------------------------
// ---------- component ----------
pub const Capital = @import("tag.zig").SizeCapital;
pub const Large = @import("tag.zig").SizeLarge;
pub const Medium = @import("tag.zig").SizeMedium;
pub const Player = @import("tag.zig").Player;
pub const Ship = @import("tag.zig").Ship;
pub const Small = @import("tag.zig").SizeSmall;
pub const Visible = @import("tag.zig").Visible;
// ------------------------------

// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ test ══════════════════════════════╗
//TODO[TEST] import all pack files
// ╚══════════════════════════════════════════════════════════════════╝
