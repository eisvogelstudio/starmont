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
// ---------------------------

// ╔══════════════════════════════ UUID4 ══════════════════════════════╗
pub fn serializeUUID4(uuid: util.UUID4, writer: anytype) void {
    writer.writeAll(&uuid.bytes) catch unreachable;
}

pub fn deserializeUUID4(reader: anytype) util.UUID4 {
    var buf: [16]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return util.UUID4{ .bytes = buf };
}
// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ Angle ══════════════════════════════╗
pub fn serializeAngle(angle: util.Angle, writer: anytype) void {
    primitive.serializeF32(writer, angle.toDegrees());
}

pub fn deserializeAngle(reader: anytype) util.Angle {
    return util.Angle.fromDegrees(primitive.deserializeF32(reader));
}
// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ Vec2 ══════════════════════════════╗
pub fn serializeVec2(self: util.Vec2, writer: anytype) void {
    primitive.serializeF32(writer, self.x);
    primitive.serializeF32(writer, self.y);
}

pub fn deserializeVec2(reader: anytype) util.Vec2 {
    const x = primitive.deserializeF32(reader);
    const y = primitive.deserializeF32(reader);
    return util.Vec2{ .x = x, .y = y };
}
// ╚══════════════════════════════════════════════════════════════════╝
