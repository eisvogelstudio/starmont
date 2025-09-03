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
const core = @import("shared").core;
// ------------------------------

// ---------- local ----------
const primitive = @import("primitive.zig");
const util = @import("util.zig");
const SerializeError = @import("error.zig").SerializeError;
const DeserializeError = @import("error.zig").DeserializeError;
const Error = @import("error.zig").Error;
// ---------------------------

pub fn wireSizeId() usize {
    return util.wireSizeUUID4();
}

pub fn serializeId(value: core.Id, buffer: []u8) Error!void {
    try util.serializeUUID4(value.uuid, buffer[0..wireSizeId()]);
}

pub fn deserializeId(buffer: []const u8) Error!core.Id {
    const uuid = try util.deserializeUUID4(buffer[0..util.wireSizeUUID4()]);
    return core.Id{ .uuid = uuid };
}

pub fn wireSizePosition() usize {
    return 2 * primitive.wireSizeF32();
}

pub fn serializePosition(value: core.Position, buffer: []u8) Error!void {
    if (buffer.len < wireSizePosition()) return Error.BufferTooSmall;
    try primitive.serializeF32(value.x, buffer[0..4]);
    try primitive.serializeF32(value.y, buffer[4..8]);
}

pub fn deserializePosition(buffer: []const u8) Error!core.Position {
    if (buffer.len < wireSizePosition()) return Error.Truncated;
    const x = try primitive.deserializeF32(buffer[0..4]);
    const y = try primitive.deserializeF32(buffer[4..8]);
    return core.Position{ .x = x, .y = y };
}

pub fn wireSizeVelocity() usize {
    return 2 * primitive.wireSizeF32();
}

pub fn serializeVelocity(value: core.Velocity, buffer: []u8) Error!void {
    if (buffer.len < wireSizeVelocity()) return Error.BufferTooSmall;
    try primitive.serializeF32(value.x, buffer[0..4]);
    try primitive.serializeF32(value.y, buffer[4..8]);
}

pub fn deserializeVelocity(buffer: []const u8) Error!core.Velocity {
    if (buffer.len < wireSizeVelocity()) return Error.Truncated;
    const x = try primitive.deserializeF32(buffer[0..4]);
    const y = try primitive.deserializeF32(buffer[4..8]);
    return core.Velocity{ .x = x, .y = y };
}

pub fn wireSizeAcceleration() usize {
    return 2 * primitive.wireSizeF32();
}

pub fn serializeAcceleration(value: core.Acceleration, buffer: []u8) Error!void {
    if (buffer.len < wireSizeAcceleration()) return Error.BufferTooSmall;
    try primitive.serializeF32(value.x, buffer[0..4]);
    try primitive.serializeF32(value.y, buffer[4..8]);
}

pub fn deserializeAcceleration(buffer: []const u8) Error!core.Acceleration {
    if (buffer.len < wireSizeAcceleration()) return Error.Truncated;
    const x = try primitive.deserializeF32(buffer[0..4]);
    const y = try primitive.deserializeF32(buffer[4..8]);
    return core.Acceleration{ .x = x, .y = y };
}

pub fn wireSizeJerk() usize {
    return 2 * primitive.wireSizeF32();
}

pub fn serializeJerk(value: core.Jerk, buffer: []u8) Error!void {
    if (buffer.len < wireSizeJerk()) return Error.BufferTooSmall;
    try primitive.serializeF32(value.x, buffer[0..4]);
    try primitive.serializeF32(value.y, buffer[4..8]);
}

pub fn deserializeJerk(buffer: []const u8) Error!core.Jerk {
    if (buffer.len < wireSizeJerk()) return Error.Truncated;
    const x = try primitive.deserializeF32(buffer[0..4]);
    const y = try primitive.deserializeF32(buffer[4..8]);
    return core.Jerk{ .x = x, .y = y };
}

pub fn wireSizeRotation() usize {
    return util.wireSizeAngle();
}

pub fn serializeRotation(value: core.Rotation, buffer: []u8) Error!void {
    try util.serializeAngle(value.value, buffer[0..wireSizeRotation()]);
}

pub fn deserializeRotation(buffer: []const u8) Error!core.Rotation {
    return core.Rotation{ .value = try util.deserializeAngle(buffer[0..wireSizeRotation()]) };
}

pub fn wireSizeAngularVelocity() usize {
    return util.wireSizeAngle();
}

pub fn serializeAngularVelocity(value: core.AngularVelocity, buffer: []u8) Error!void {
    try util.serializeAngle(value.value, buffer[0..wireSizeAngularVelocity()]);
}

pub fn deserializeAngularVelocity(buffer: []const u8) Error!core.AngularVelocity {
    return core.AngularVelocity{ .value = try util.deserializeAngle(buffer[0..wireSizeAngularVelocity()]) };
}

pub fn wireSizeAngularAcceleration() usize {
    return util.wireSizeAngle();
}

pub fn serializeAngularAcceleration(value: core.AngularAcceleration, buffer: []u8) Error!void {
    try util.serializeAngle(value.value, buffer[0..wireSizeAngularAcceleration()]);
}

pub fn deserializeAngularAcceleration(buffer: []const u8) Error!core.AngularAcceleration {
    return core.AngularAcceleration{ .value = try util.deserializeAngle(buffer[0..wireSizeAngularAcceleration()]) };
}

pub fn wireSizeShipSize() usize {
    return primitive.wireSizeEnum(core.ShipSize);
}

pub fn serializeShipSize(value: core.ShipSize, buffer: []u8) Error!void {
    try primitive.serializeEnum(core.ShipSize, value, buffer[0..wireSizeShipSize()]);
}

pub fn deserializeShipSize(buffer: []const u8) Error!core.ShipSize {
    return try primitive.deserializeEnum(core.ShipSize, buffer[0..wireSizeShipSize()]);
}
