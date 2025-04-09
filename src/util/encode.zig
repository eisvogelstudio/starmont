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

// ########## primitive ##########

pub fn serializeU32(writer: anytype, uint: u32) !void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(uint);
    try writer.writeAll(&buf);
}

pub fn serializeU64(writer: anytype, uint: u64) !void {
    var buf: [8]u8 = undefined;
    buf = @bitCast(uint);
    try writer.writeAll(&buf);
}

pub fn serializeF32(writer: anytype, float: f32) !void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(float);
    try writer.writeAll(&buf);
}

pub fn serializeEnum(writer: anytype, comptime T: type, value: T) !void {
    try writer.writeByte(@intFromEnum(value));
}

// ###############################

// ########## model ##########

pub fn serializeId(writer: anytype, id: core.Id) !void {
    try serializeU64(writer, id.id);
}

pub fn serializePosition(writer: anytype, pos: core.Position) !void {
    try serializeF32(writer, pos.x);
    try serializeF32(writer, pos.y);
}

pub fn serializeVelocity(writer: anytype, vel: core.Velocity) !void {
    try serializeF32(writer, vel.x);
    try serializeF32(writer, vel.y);
}

pub fn serializeAcceleration(writer: anytype, acc: core.Acceleration) !void {
    try serializeF32(writer, acc.x);
    try serializeF32(writer, acc.y);
}

pub fn serializeJerk(writer: anytype, jerk: core.Jerk) !void {
    try serializeF32(writer, jerk.x);
    try serializeF32(writer, jerk.y);
}

pub fn serializeShipSize(writer: anytype, size: core.ShipSize) !void {
    try serializeEnum(writer, core.ShipSize, size);
}

// ###########################
