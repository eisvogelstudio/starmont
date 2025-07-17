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

// ##### text #####

pub fn serializeText(writer: anytype, text: []const u8) void {
    serializeU64(writer, @intCast(text.len));
    writer.writeAll(text) catch unreachable;
}

pub fn deserializeText(reader: anytype, allocator: *std.mem.Allocator) []const u8 {
    const len = deserializeU64(reader);
    const text = allocator.alloc(u8, len) catch unreachable;
    _ = reader.readAll(text) catch unreachable;
    return text;
}

// ##### bool #####

pub fn serializeBool(writer: anytype, boolean: bool) void {
    const byte: u8 = if (boolean) 1 else 0;
    writer.writeByte(byte) catch unreachable;
}

pub fn deserializeBool(reader: anytype) bool {
    const byte = reader.readByte() catch unreachable;
    return byte != 0;
}

// ##### uint #####

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

// ##### int #####

pub fn serializeI8(writer: anytype, int: i8) void {
    var buf: [1]u8 = undefined;
    buf = @bitCast(int);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeI8(reader: anytype) i8 {
    var buf: [1]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeI16(writer: anytype, int: i16) void {
    var buf: [2]u8 = undefined;
    buf = @bitCast(int);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeI16(reader: anytype) i16 {
    var buf: [2]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeI32(writer: anytype, int: i32) void {
    var buf: [4]u8 = undefined;
    buf = @bitCast(int);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeI32(reader: anytype) i32 {
    var buf: [4]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

pub fn serializeI64(writer: anytype, int: i64) void {
    var buf: [8]u8 = undefined;
    buf = @bitCast(int);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeI64(reader: anytype) i64 {
    var buf: [8]u8 = undefined;
    _ = reader.readAll(&buf) catch unreachable;
    return @bitCast(buf);
}

// ##### float #####

pub fn serializeF16(writer: anytype, float: f16) void {
    var buf: [2]u8 = undefined;
    buf = @bitCast(float);
    writer.writeAll(&buf) catch unreachable;
}

pub fn deserializeF16(reader: anytype) f16 {
    var buf: [2]u8 = undefined;
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
