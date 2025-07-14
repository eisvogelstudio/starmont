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

// ---------- shared ----------
const core = @import("../core/root.zig");
// ----------------------------

// ########## primitive ##########

pub fn serializeU8(writer: anytype, uint: u8) void {
    var buf: [1]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn serializeU16(writer: anytype, uint: u16) void {
    var buf: [2]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn serializeU32(writer: anytype, uint: u32) void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn serializeU64(writer: anytype, uint: u64) void {
    var buf: [8]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn serializeF32(writer: anytype, float: f32) void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(float);
    writer.writeAll(&buf) catch unreachable;
}

pub fn serializeF64(writer: anytype, float: f64) void {
    var buf: [8]u8 = undefined;
    buf = @bitCast(float);
    writer.writeAll(&buf) catch unreachable;
}

pub fn serializeEnum(writer: anytype, comptime T: type, value: T) void {
    writer.writeByte(@intFromEnum(value)) catch unreachable;
}

// ###############################

// ########## model ##########

pub fn serializeId(writer: anytype, id: core.Id) void {
    serializeU64(writer, id.id);
}

pub fn serializePosition(writer: anytype, pos: core.Position) void {
    serializeF32(writer, pos.x);
    serializeF32(writer, pos.y);
}

pub fn serializeVelocity(writer: anytype, vel: core.Velocity) void {
    serializeF32(writer, vel.x);
    serializeF32(writer, vel.y);
}

pub fn serializeAcceleration(writer: anytype, acc: core.Acceleration) void {
    serializeF32(writer, acc.x);
    serializeF32(writer, acc.y);
}

pub fn serializeJerk(writer: anytype, jerk: core.Jerk) void {
    serializeF32(writer, jerk.x);
    serializeF32(writer, jerk.y);
}

pub fn serializeShipSize(writer: anytype, size: core.ShipSize) void {
    serializeEnum(writer, core.ShipSize, size);
}

// ###########################
