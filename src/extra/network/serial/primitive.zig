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

// ---------- local ----------
const SerializeError = @import("error.zig").SerializeError;
const DeserializeError = @import("error.zig").DeserializeError;
const Error = @import("error.zig").Error;
// ---------------------------

//TODO[IMPROVEMENT] make buffer the first arg in all the serialize/deserialize functions

const endian = std.builtin.Endian.big;

// ╔══════════════════════════════ text ══════════════════════════════╗
const max_text_size = 1024;

pub fn wireSizeText(text: []const u8) usize {
    std.debug.assert(text.len <= max_text_size);

    return @sizeOf(u64) + text.len;
}

pub fn serializeText(text: []const u8, buffer: []u8) SerializeError!void {
    std.debug.assert(text.len <= max_text_size);

    const need = wireSizeText(text);
    if (buffer.len < need) return SerializeError.BufferTooSmall;

    var i: usize = 0;
    std.mem.writeInt(u64, buffer[i..][0..8], @intCast(text.len), endian);
    i += 8;

    @memcpy(buffer[i .. i + text.len], text);
}

pub fn deserializeText(buffer: []const u8, gpa: std.mem.Allocator) Error![]u8 {
    if (buffer.len < 8) return DeserializeError.Truncated;

    var i: usize = 0;
    const len = std.mem.readInt(u64, buffer[i..][0..8], endian);
    i += 8;

    if (len > max_text_size) return DeserializeError.TextTooLarge;
    if (i + len > buffer.len) return DeserializeError.Truncated;

    const text = try gpa.alloc(u8, @intCast(len));
    @memcpy(text, buffer[i .. i + len]);

    return text;
}
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ enum ══════════════════════════════╗
//pub fn wireSizeEnum(comptime T: type) usize {
//    const tag_type = @typeInfo(T).@"enum".tag_type;
//    switch (tag_type) {
//        u8 => {
//            return 1;
//        },
//        u16 => {
//            return 2;
//        },
//        u32 => {
//            return 4;
//        },
//        u64 => {
//            return 8;
//        },
//        else => @compileError(std.fmt.comptimePrint("Unsupported enum backing type: '{s}'", .{@typeName(tag_type)})),
//    }
//}
pub fn wireSizeEnum(comptime T: type) usize {
    const info = @typeInfo(T);
    if (info != .@"enum") {
        @compileError("wireSizeEnum requires an enum type, got " ++ @typeName(T));
    }
    const tag_type = info.@"enum".tag_type;
    const bits = @typeInfo(tag_type).int.bits;
    return (bits + 7) / 8;
}

pub fn serializeEnum(comptime T: type, value: T, buffer: []u8) SerializeError!void {
    const info = @typeInfo(T);
    if (info != .@"enum") {
        @compileError("serializeEnum requires an enum type, got " ++ @typeName(T));
    }

    const size = wireSizeEnum(T);

    if (buffer.len < size)
        return SerializeError.BufferTooSmall;

    const int_val = @intFromEnum(value);

    // byteweise schreiben
    var tmp: u64 = int_val;
    for (0..size) |i| {
        buffer[i] = @intCast(tmp & 0xFF);
        tmp >>= 8;
    }
}

pub fn deserializeEnum(comptime T: type, buffer: []const u8) DeserializeError!T {
    const info = @typeInfo(T);
    if (info != .@"enum") {
        @compileError("deserializeEnum requires an enum type, got " ++ @typeName(T));
    }

    const size = wireSizeEnum(T);

    if (buffer.len < size)
        return DeserializeError.Truncated;

    var raw: usize = 0;
    for (0..size) |i| {
        const off: u6 = @intCast(i);
        raw |= (@as(usize, buffer[i]) << (8 * off));
    }

    if (raw >= @typeInfo(T).@"enum".fields.len)
        return DeserializeError.InvalidEnumValue;

    return @enumFromInt(raw);
}

// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ bool ══════════════════════════════╗
pub fn wireSizeBool() usize {
    return 1;
}

pub fn serializeBool(value: bool, buffer: []u8) SerializeError!void {
    if (buffer.len < 1) return SerializeError.BufferTooSmall;
    buffer[0] = if (value) 1 else 0;
}

pub fn deserializeBool(buffer: []const u8) DeserializeError!bool {
    if (buffer.len < 1) return DeserializeError.Truncated;
    return buffer[0] != 0;
}

// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ uint ══════════════════════════════╗
pub fn wireSizeU8() usize {
    return 1;
}

pub fn serializeU8(value: u8, buffer: []u8) SerializeError!void {
    if (buffer.len < 1) return SerializeError.BufferTooSmall;
    buffer[0] = value;
}

pub fn deserializeU8(buffer: []const u8) DeserializeError!u8 {
    if (buffer.len < 1) return DeserializeError.Truncated;
    return buffer[0];
}

pub fn wireSizeU16() usize {
    return 2;
}

pub fn serializeU16(value: u16, buffer: []u8) SerializeError!void {
    if (buffer.len < 2) return SerializeError.BufferTooSmall;
    std.mem.writeInt(u16, buffer[0..2], value, endian);
}

pub fn deserializeU16(buffer: []const u8) DeserializeError!u16 {
    if (buffer.len < 2) return DeserializeError.Truncated;
    return std.mem.readInt(u16, buffer[0..2], endian);
}

pub fn wireSizeU32() usize {
    return 4;
}

pub fn serializeU32(value: u32, buffer: []u8) SerializeError!void {
    if (buffer.len < 4) return SerializeError.BufferTooSmall;
    std.mem.writeInt(u32, buffer[0..4], value, endian);
}

pub fn deserializeU32(buffer: []const u8) DeserializeError!u32 {
    if (buffer.len < 4) return DeserializeError.Truncated;
    return std.mem.readInt(u32, buffer[0..4], endian);
}

pub fn wireSizeU64() usize {
    return 8;
}

pub fn serializeU64(value: u64, buffer: []u8) SerializeError!void {
    if (buffer.len < 8) return SerializeError.BufferTooSmall;
    std.mem.writeInt(u64, buffer[0..8], value, endian);
}

pub fn deserializeU64(buffer: []const u8) DeserializeError!u64 {
    if (buffer.len < 8) return DeserializeError.Truncated;
    return std.mem.readInt(u64, buffer[0..8], endian);
}
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ int ══════════════════════════════╗
pub fn wireSizeI8() usize {
    return 1;
}

pub fn serializeI8(value: i8, buffer: []u8) SerializeError!void {
    if (buffer.len < 1) return SerializeError.BufferTooSmall;
    buffer[0] = @bitCast(value);
}

pub fn deserializeI8(buffer: []const u8) DeserializeError!i8 {
    if (buffer.len < 1) return DeserializeError.Truncated;
    return @bitCast(buffer[0]);
}

pub fn wireSizeI16() usize {
    return 2;
}

pub fn serializeI16(value: i16, buffer: []u8) SerializeError!void {
    if (buffer.len < 2) return SerializeError.BufferTooSmall;
    std.mem.writeInt(i16, buffer[0..2], value, endian);
}

pub fn deserializeI16(buffer: []const u8) DeserializeError!i16 {
    if (buffer.len < 2) return DeserializeError.Truncated;
    return std.mem.readInt(i16, buffer[0..2], endian);
}

pub fn wireSizeI32() usize {
    return 4;
}

pub fn serializeI32(value: i32, buffer: []u8) SerializeError!void {
    if (buffer.len < 4) return SerializeError.BufferTooSmall;
    std.mem.writeInt(i32, buffer[0..4], value, endian);
}

pub fn deserializeI32(buffer: []const u8) DeserializeError!i32 {
    if (buffer.len < 4) return DeserializeError.Truncated;
    return std.mem.readInt(i32, buffer[0..4], endian);
}

pub fn wireSizeI64() usize {
    return 8;
}

pub fn serializeI64(value: i64, buffer: []u8) SerializeError!void {
    if (buffer.len < 8) return SerializeError.BufferTooSmall;
    std.mem.writeInt(i64, buffer[0..8], value, endian);
}

pub fn deserializeI64(buffer: []const u8) DeserializeError!i64 {
    if (buffer.len < 8) return DeserializeError.Truncated;
    return std.mem.readInt(i64, buffer[0..8], endian);
}
// ╚═════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ float ══════════════════════════════╗
pub fn wireSizeF16() usize {
    return 2;
}

pub fn serializeF16(value: f16, buffer: []u8) SerializeError!void {
    if (buffer.len < 2) return SerializeError.BufferTooSmall;
    const raw: [2]u8 = @bitCast(value);
    @memcpy(buffer[0..2], raw[0..2]);
}

pub fn deserializeF16(buffer: []const u8) DeserializeError!f16 {
    if (buffer.len < 2) return DeserializeError.Truncated;
    const raw: [2]u8 = buffer[0..2].*;
    return @bitCast(raw);
}

pub fn wireSizeF32() usize {
    return 4;
}

pub fn serializeF32(value: f32, buffer: []u8) SerializeError!void {
    if (buffer.len < 4) return SerializeError.BufferTooSmall;
    const raw: [4]u8 = @bitCast(value);
    @memcpy(buffer[0..4], raw[0..4]);
}

pub fn deserializeF32(buffer: []const u8) DeserializeError!f32 {
    if (buffer.len < 4) return DeserializeError.Truncated;
    const raw: [4]u8 = buffer[0..4].*;
    return @bitCast(raw);
}

pub fn wireSizeF64() usize {
    return 8;
}

pub fn serializeF64(value: f64, buffer: []u8) SerializeError!void {
    if (buffer.len < 8) return SerializeError.BufferTooSmall;
    const raw: [8]u8 = @bitCast(value);
    @memcpy(buffer[0..8], raw[0..8]);
}

pub fn deserializeF64(buffer: []const u8) DeserializeError!f64 {
    if (buffer.len < 8) return DeserializeError.Truncated;
    const raw: [8]u8 = buffer[0..8].*;
    return @bitCast(raw);
}
// ╚═══════════════════════════════════════════════════════════════════╝
