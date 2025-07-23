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

// ---------- local ----------
const util = @import("../../util/root.zig");
const Collider = @import("../physics/collider.zig").Collider;
// --------------------------

const TileKind = enum {
    Empty,
    Floor,
    Wall,
    Glass,
    Door,
    Terminal,
    Spawnpoint,
};

const Tile = struct {
    kind: TileKind,
};

pub const tile_size = util.Vec2u.init(32, 32);

const Tilemap = struct {
    size: util.Vec2u,
    tiles: []Tile,
    colliders: []Collider,
    //markers: []Marker,
};

const TilemapEntity = struct {
    tilemap: *const Tilemap,
    position: util.Vec2,
    rotation: util.Angle,
};
