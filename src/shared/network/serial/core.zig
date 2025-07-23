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

// ---------- local ----------
const core = @import("../../core/core.zig");
const util = @import("../../util/util.zig");
// ---------------------------

// ---------- network/serial ----------
const primitive = @import("primitive.zig");
// -----------------------------

pub fn serializePosition(writer: anytype, pos: core.Position) void {
    primitive.serializeF32(writer, pos.x);
    primitive.serializeF32(writer, pos.y);
}

pub fn deserializePosition(reader: anytype) core.Position {
    const x = primitive.deserializeF32(reader);
    const y = primitive.deserializeF32(reader);
    return core.Position{ .x = x, .y = y };
}

pub fn serializeVelocity(writer: anytype, vel: core.Velocity) void {
    primitive.serializeF32(writer, vel.x);
    primitive.serializeF32(writer, vel.y);
}

pub fn deserializeVelocity(reader: anytype) core.Velocity {
    const x = primitive.deserializeF32(reader);
    const y = primitive.deserializeF32(reader);
    return core.Velocity{ .x = x, .y = y };
}

pub fn serializeAcceleration(writer: anytype, acc: core.Acceleration) void {
    primitive.serializeF32(writer, acc.x);
    primitive.serializeF32(writer, acc.y);
}

pub fn deserializeAcceleration(reader: anytype) core.Acceleration {
    const x = primitive.deserializeF32(reader);
    const y = primitive.deserializeF32(reader);
    return core.Acceleration{ .x = x, .y = y };
}

pub fn serializeJerk(writer: anytype, jerk: core.Jerk) void {
    primitive.serializeF32(writer, jerk.x);
    primitive.serializeF32(writer, jerk.y);
}

pub fn deserializeJerk(reader: anytype) core.Jerk {
    const x = primitive.deserializeF32(reader);
    const y = primitive.deserializeF32(reader);
    return core.Jerk{ .x = x, .y = y };
}

pub fn serializeRotation(writer: anytype, rot: core.Rotation) void {
    rot.value.serialize(writer);
}

pub fn deserializeRotation(reader: anytype) core.Rotation {
    return core.Rotation{ .value = util.Angle.deserialize(reader) };
}

pub fn serializeRotationalVelocity(writer: anytype, rotv: core.RotationalVelocity) void {
    rotv.value.serialize(writer);
}

pub fn deserializeRotationalVelocity(reader: anytype) core.RotationalVelocity {
    return core.RotationalVelocity{ .value = util.Angle.deserialize(reader) };
}

pub fn serializeRotationalAcceleration(writer: anytype, rota: core.RotationalAcceleration) void {
    rota.value.serialize(writer);
}

pub fn deserializeRotationalAcceleration(reader: anytype) core.RotationalAcceleration {
    return core.RotationalAcceleration{ .value = util.Angle.deserialize(reader) };
}

pub fn serializeShipSize(writer: anytype, size: core.ShipSize) void {
    primitive.serializeEnum(writer, core.ShipSize, size);
}

pub fn deserializeShipSize(reader: anytype) core.ShipSize {
    return primitive.deserializeEnum(reader, core.ShipSize);
}
