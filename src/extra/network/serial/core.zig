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
const serial = @import("serial.zig");
const SerializeError = @import("error.zig").SerializeError;
const DeserializeError = @import("error.zig").DeserializeError;
const Error = @import("error.zig").Error;
// ---------------------------

pub const Id = struct {
    pub fn wireSize() usize {
        return serial.UUID4.wireSize();
    }

    pub fn serializeId(value: core.Id, buffer: []u8) Error!void {
        try serial.UUID4.serialize(value.uuid, buffer[0..wireSize()]);
    }

    pub fn deserializeId(buffer: []const u8) Error!core.Id {
        const uuid = try serial.UUID4.deserialize(buffer[0..wireSize()]);
        return core.Id{ .uuid = uuid };
    }
};

pub const Position = struct {
    pub fn wireSize() usize {
        return 2 * serial.F32.wireSize();
    }

    pub fn serialize(value: core.Position, buffer: []u8) Error!void {
        if (buffer.len < serial.Position.wireSize()) return Error.BufferTooSmall;
        try serial.F32.serialize(value.x, buffer[0..4]);
        try serial.F32.serialize(value.y, buffer[4..8]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.Position {
        if (buffer.len < serial.Position.wireSize()) return Error.Truncated;
        const x = try serial.F32.deserialize(buffer[0..4]);
        const y = try serial.F32.deserialize(buffer[4..8]);
        return core.Position{ .x = x, .y = y };
    }
};

pub const Velocity = struct {
    pub fn wireSize() usize {
        return 2 * serial.F32.wireSize();
    }

    pub fn serialize(value: core.Velocity, buffer: []u8) Error!void {
        if (buffer.len < wireSize()) return Error.BufferTooSmall;
        try serial.F32.serialize(value.x, buffer[0..4]);
        try serial.F32.serialize(value.y, buffer[4..8]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.Velocity {
        if (buffer.len < wireSize()) return Error.Truncated;
        const x = try serial.F32.deserialize(buffer[0..4]);
        const y = try serial.F32.deserialize(buffer[4..8]);
        return core.Velocity{ .x = x, .y = y };
    }
};

pub const Acceleration = struct {
    pub fn wireSize() usize {
        return 2 * serial.F32.wireSize();
    }

    pub fn serialize(value: core.Acceleration, buffer: []u8) Error!void {
        if (buffer.len < wireSize()) return Error.BufferTooSmall;
        try serial.F32.serialize(value.x, buffer[0..4]);
        try serial.F32.serialize(value.y, buffer[4..8]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.Acceleration {
        if (buffer.len < wireSize()) return Error.Truncated;
        const x = try serial.F32.deserialize(buffer[0..4]);
        const y = try serial.F32.deserialize(buffer[4..8]);
        return core.Acceleration{ .x = x, .y = y };
    }
};

pub const Jerk = struct {
    pub fn wireSize() usize {
        return 2 * serial.F32.wireSize();
    }

    pub fn serialize(value: core.Jerk, buffer: []u8) Error!void {
        if (buffer.len < wireSize()) return Error.BufferTooSmall;
        try serial.F32.serialize(value.x, buffer[0..4]);
        try serial.F32.serialize(value.y, buffer[4..8]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.Jerk {
        if (buffer.len < wireSize()) return Error.Truncated;
        const x = try serial.F32.deserialize(buffer[0..4]);
        const y = try serial.F32.deserialize(buffer[4..8]);
        return core.Jerk{ .x = x, .y = y };
    }
};

pub const Rotation = struct {
    pub fn wireSize() usize {
        return serial.Angle.wireSize();
    }

    pub fn serialize(value: core.Rotation, buffer: []u8) Error!void {
        try serial.Angle.serialize(value.value, buffer[0..wireSize()]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.Rotation {
        return core.Rotation{ .value = try serial.Angle.deserializeAngle(buffer[0..wireSize()]) };
    }
};

pub const AngularVelocity = struct {
    pub fn wireSize() usize {
        return serial.Angle.wireSize();
    }

    pub fn serialize(value: core.AngularVelocity, buffer: []u8) Error!void {
        try serial.Angle.serialize(value.value, buffer[0..wireSize()]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.AngularVelocity {
        return core.AngularVelocity{ .value = try serial.Angle.deserializeAngle(buffer[0..wireSize()]) };
    }
};

pub const AngularAcceleration = struct {
    pub fn wireSize() usize {
        return serial.Angle.wireSize();
    }

    pub fn serialize(value: core.AngularAcceleration, buffer: []u8) Error!void {
        try serial.Angle.serialize(value.value, buffer[0..wireSize()]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.AngularAcceleration {
        return core.AngularAcceleration{ .value = try serial.Angle.deserializeAngle(buffer[0..wireSize()]) };
    }
};

pub const ShipSize = struct {
    pub fn wireSize() usize {
        return serial.Enum.wireSize(core.ShipSize);
    }

    pub fn serialize(value: core.ShipSize, buffer: []u8) Error!void {
        try serial.Enum.serialize(core.ShipSize, value, buffer[0..wireSize()]);
    }

    pub fn deserialize(buffer: []const u8) Error!core.ShipSize {
        return try serial.Enum.deserialize(core.ShipSize, buffer[0..wireSize()]);
    }
};
