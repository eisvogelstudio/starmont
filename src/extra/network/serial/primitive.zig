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
const endian = @import("endian.zig").value;
// ---------------------------

// ╔══════════════════════════════ text ══════════════════════════════╗
pub const Text = struct {
    const max_text_size = 1024;

    pub fn wireSize(text: []const u8) usize {
        std.debug.assert(text.len <= max_text_size);

        return @sizeOf(u64) + text.len;
    }

    pub fn serialize(text: []const u8, buffer: []u8) SerializeError!void {
        std.debug.assert(text.len <= max_text_size);

        const need = wireSize(text);
        if (buffer.len < need) return SerializeError.BufferTooSmall;

        var i: usize = 0;
        std.mem.writeInt(u64, buffer[i..][0..8], @intCast(text.len), endian);
        i += 8;

        @memcpy(buffer[i .. i + text.len], text);
    }

    pub fn deserialize(buffer: []const u8, gpa: std.mem.Allocator) Error![]u8 {
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
};
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ enum ══════════════════════════════╗
pub const Enum = struct {
    fn storageType(comptime T: type) type {
        const tag_type = @typeInfo(T).@"enum".tag_type;
        const bits = 7 + @typeInfo(tag_type).int.bits / 8;
        return std.meta.Int(.unsigned, std.math.ceilPowerOfTwo(usize, bits) catch @panic("failed"));
    }

    pub fn wireSize(comptime T: type) usize {
        const info = @typeInfo(T);
        if (info != .@"enum") {
            @compileError("wireSizeEnum requires an enum type, got " ++ @typeName(T));
        }
        const bits = @typeInfo(info.@"enum".tag_type).int.bits;
        return (bits + 7) / 8; // immer auf volles Byte runden
    }

    pub fn serialize(comptime T: type, value: T, buffer: []u8) SerializeError!void {
        const info = @typeInfo(T);
        if (info != .@"enum") {
            @compileError("serializeEnum requires an enum type, got " ++ @typeName(T));
        }

        const Store = storageType(T);
        const size = @sizeOf(Store);

        if (buffer.len < size)
            return SerializeError.BufferTooSmall;

        const int_val: Store = @intCast(@intFromEnum(value));
        std.mem.writeInt(Store, buffer[0..size], int_val, .little);
    }

    pub fn deserialize(comptime T: type, buffer: []const u8) DeserializeError!T {
        const info = @typeInfo(T);
        if (info != .@"enum") {
            @compileError("deserializeEnum requires an enum type, got " ++ @typeName(T));
        }

        const tag_type = info.@"enum".tag_type;
        const Store = storageType(T);
        const size = @sizeOf(Store);

        if (buffer.len < size)
            return DeserializeError.Truncated;

        const raw: Store = std.mem.readInt(Store, buffer[0..size], .little);

        if (raw >= info.@"enum".fields.len)
            return DeserializeError.InvalidEnumValue;

        return @enumFromInt(@as(tag_type, @intCast(raw)));
    }
};
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ bool ══════════════════════════════╗
pub const Bool = struct {
    pub fn wireSize() usize {
        return 1;
    }

    pub fn serialize(value: bool, buffer: []u8) SerializeError!void {
        if (buffer.len < 1) return SerializeError.BufferTooSmall;
        buffer[0] = if (value) 1 else 0;
    }

    pub fn deserialize(buffer: []const u8) DeserializeError!bool {
        if (buffer.len < 1) return DeserializeError.Truncated;
        return buffer[0] != 0;
    }
};
// ╚══════════════════════════════════════════════════════════════════╝
