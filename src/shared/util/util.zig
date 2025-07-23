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

// ╔══════════════════════════════ pack ══════════════════════════════╗
pub const format = @import("format.zig");
pub const log = @import("log.zig");
pub const ziggy = @import("ziggy.zig");

pub const UUID4 = @import("uuid4.zig").UUID4;

pub const Vec2 = @import("geometry/vec2.zig").Vec2;
pub const Vec2u = @import("geometry/vec2u.zig").Vec2u;
pub const Angle = @import("geometry/angle.zig").Angle;
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ test ══════════════════════════════╗
//TODO[TEST] import all pack files
// ╚══════════════════════════════════════════════════════════════════╝
