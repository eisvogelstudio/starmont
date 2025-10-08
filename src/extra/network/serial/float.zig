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
const endian = @import("endian.zig").value;
// ---------------------------

pub fn Float(comptime T: type) type {
    if (@typeInfo(T) != .Float) @compileError(@typeName(T) ++ " is not a float type");

    const I = switch (@bitSizeOf(T)) {
        16 => u16,
        32 => u32,
        64 => u64,
        128 => u128,
        else => @compileError("Unsupported float size for " ++ @typeName(T)),
    };

    return struct {
        pub fn wireSize() usize {
            return @sizeOf(T);
        }

        pub fn serialize(value: T, buffer: []u8) SerializeError!void {
            if (buffer.len < @sizeOf(T))
                return SerializeError.BufferTooSmall;

            const bits: I = @bitCast(value);
            std.mem.writeInt(I, buffer[0..@sizeOf(T)], bits, endian);
        }

        pub fn deserialize(buffer: []const u8) DeserializeError!T {
            if (buffer.len < @sizeOf(T))
                return DeserializeError.Truncated;

            const bits = std.mem.readInt(I, buffer[0..@sizeOf(T)], endian);
            return @bitCast(bits);
        }

        pub fn write(value: T, buffer: []u8, offset: *usize) SerializeError!void {
            const size = wireSize();
            if (offset.* + size > buffer.len)
                return SerializeError.BufferTooSmall;

            try serialize(value, buffer[offset.* .. offset.* + size]);
            offset.* += size;
        }

        pub fn read(buffer: []const u8, offset: *usize) DeserializeError!T {
            const size = wireSize();
            const value = try deserialize(buffer[offset.* .. offset.* + size]);
            offset.* += size;
            return value;
        }
    };
}
