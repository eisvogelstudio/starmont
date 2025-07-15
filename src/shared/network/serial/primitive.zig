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

pub fn serializeU8(writer: anytype, uint: u8) void {
    var buf: [1]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeU8(reader: anytype) u8 {
    var buf: [1]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeU16(writer: anytype, uint: u16) void {
    var buf: [2]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeU16(reader: anytype) u16 {
    var buf: [2]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeU32(writer: anytype, uint: u32) void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeU32(reader: anytype) u32 {
    var buf: [4]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeU64(writer: anytype, uint: u64) void {
    var buf: [8]u8 = undefined;
    buf = @bitCast(uint);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeU64(reader: anytype) u64 {
    var buf: [8]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeF32(writer: anytype, float: f32) void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(float);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeF32(reader: anytype) f32 {
    var buf: [4]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeF64(writer: anytype, float: f64) void {
    var buf: [8]u8 = undefined;
    buf = @bitCast(float);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeF64(reader: anytype) f64 {
    var buf: [8]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeEnum(writer: anytype, comptime T: type, value: T) void {
    writer.writeByte(@intFromEnum(value)) catch unreachable;
}

pub fn deserializeEnum(reader: anytype, comptime T: type) T {
    const action_byte = reader.readByte() catch unreachable;
    return @enumFromInt(action_byte);
}
