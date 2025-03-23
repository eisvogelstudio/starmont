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

// ---------- starmont ----------
const core = @import("core");
// ------------------------------

pub fn deserializeF32(reader: anytype) !f32 {
    var buf: [4]u8 = undefined;
    _ = try reader.readAll(&buf);
    return @bitCast(buf);
}

pub fn deserializeEnum(reader: anytype, comptime T: type) !T {
    const action_byte = try reader.readByte();
    return @enumFromInt(action_byte);
}

pub fn deserializePosition(reader: anytype) !core.Position {
    const x = try deserializeF32(reader);
    const y = try deserializeF32(reader);
    return core.Position{ .x = x, .y = y };
}

pub fn deserializeVelocity(reader: anytype) !core.Velocity {
    const x = try deserializeF32(reader);
    const y = try deserializeF32(reader);
    return core.Velocity{ .x = x, .y = y };
}

pub fn deserializeAcceleration(reader: anytype) !core.Acceleration {
    const x = try deserializeF32(reader);
    const y = try deserializeF32(reader);
    return core.Acceleration{ .x = x, .y = y };
}

pub fn deserializeJerk(reader: anytype) !core.Jerk {
    const x = try deserializeF32(reader);
    const y = try deserializeF32(reader);
    return core.Jerk{ .x = x, .y = y };
}
