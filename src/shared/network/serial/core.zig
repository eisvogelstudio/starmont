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

// ---------- shared ----------
const core = @import("../../core/root.zig");
// ----------------------------

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

pub fn serializeShipSize(writer: anytype, size: core.ShipSize) void {
    primitive.serializeEnum(writer, core.ShipSize, size);
}

pub fn deserializeShipSize(reader: anytype) core.ShipSize {
    return primitive.deserializeEnum(reader, core.ShipSize);
}

test "serialize/deserialize Position" {
    var buf: [8]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    const writer = stream.writer();
    const reader = stream.reader();

    const original = core.Position{ .x = 42.0, .y = -13.5 };
    serializePosition(writer, original);

    stream.reset();
    const result = deserializePosition(reader);
    try std.testing.expectEqual(original.x, result.x);
    try std.testing.expectEqual(original.y, result.y);
}

test "serialize/deserialize Velocity" {
    var buf: [8]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    const writer = stream.writer();
    const reader = stream.reader();

    const original = core.Velocity{ .x = 0.1, .y = -0.1 };
    serializeVelocity(writer, original);

    stream.reset();
    const result = deserializeVelocity(reader);
    try std.testing.expectEqual(original.x, result.x);
    try std.testing.expectEqual(original.y, result.y);
}

test "serialize/deserialize ShipSize enum" {
    var buf: [1]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    const writer = stream.writer();
    const reader = stream.reader();

    const original = core.ShipSize.medium; // Beispielwert
    serializeShipSize(writer, original);

    stream.reset();
    const result = deserializeShipSize(reader);
    try std.testing.expectEqual(original, result);
}
