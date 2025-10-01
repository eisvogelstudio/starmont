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

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ----------
const primitive = @import("primitive.zig");
const SerializeError = @import("error.zig").SerializeError;
const DeserializeError = @import("error.zig").DeserializeError;
// ---------------------------

// ╔══════════════════════════════ UUID4 ══════════════════════════════╗
pub fn wireSizeUUID4() usize {
    return 16;
}

pub fn serializeUUID4(uuid: util.UUID4, buffer: []u8) !void {
    if (buffer.len < 16) return SerializeError.BufferTooSmall;
    const raw: [16]u8 = @bitCast(uuid);
    @memcpy(buffer[0..16], raw[0..16]);
}

pub fn deserializeUUID4(buffer: []const u8) !util.UUID4 {
    if (buffer.len < 16) return DeserializeError.Truncated;
    return util.UUID4{ .bytes = buffer[0..16].* };
}

// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ Angle ══════════════════════════════╗
pub fn wireSizeAngle() usize {
    return primitive.wireSizeF32();
}

pub fn serializeAngle(angle: util.Angle, buffer: []u8) !void {
    try primitive.serializeF32(angle.toDegrees(), buffer);
}

pub fn deserializeAngle(buffer: []const u8) !util.Angle {
    return util.Angle.fromDegrees(try primitive.deserializeF32(buffer));
}
// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ Vec2 ══════════════════════════════╗
pub fn serializeVec2(self: util.Vec2, buffer: []u8) void {
    primitive.serializeF32(self.x, buffer);
    primitive.serializeF32(self.y, buffer);
}

pub fn deserializeVec2(buffer: []const u8) util.Vec2 {
    const x = primitive.deserializeF32(buffer);
    const y = primitive.deserializeF32(buffer);
    return util.Vec2{ .x = x, .y = y };
}
// ╚══════════════════════════════════════════════════════════════════╝
