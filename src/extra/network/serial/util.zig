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

// ---------- external ----------
const net = @import("network");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ----------
const serial = @import("serial.zig");
const SerializeError = @import("error.zig").SerializeError;
const DeserializeError = @import("error.zig").DeserializeError;
// ---------------------------

const endian = std.builtin.Endian.big;

// ╔══════════════════════════════ Address ════════════════════════════╗
pub const Address = struct {
    pub fn wireSize(address: net.Address) usize {
        return switch (address) {
            .ipv4 => serial.Enum.wireSize(net.AddressFamily) + 4,
            .ipv6 => serial.Enum.wireSize(net.AddressFamily) + 16,
        };
    }

    pub fn serialize(address: net.Address, buffer: []u8) !void {
        if (buffer.len < wireSize(address))
            return SerializeError.BufferTooSmall;

        var offset: usize = 0;

        try serial.Enum.serialize(net.AddressFamily, address, buffer[offset..]);
        offset += serial.Enum.wireSize(net.AddressFamily);

        switch (address) {
            .ipv4 => |v| {
                std.mem.copyForwards(u8, buffer[offset .. offset + 4], &v.value);
                offset += 4;
            },
            .ipv6 => |v| {
                std.mem.copyForwards(u8, buffer[offset .. offset + 16], &v.value);
                offset += 16;
                try serial.U32.serialize(v.scope_id, buffer[offset..]);
                offset += @sizeOf(u32);
            },
        }
    }

    pub fn deserialize(buffer: []const u8) !net.Address {
        if (buffer.len < 1)
            return DeserializeError.Truncated;

        var offset: usize = 0;

        const tag = try serial.Enum.deserialize(net.AddressFamily, buffer);
        offset += serial.Enum.wireSize(net.AddressFamily);

        if (tag == .ipv4) {
            if (offset + 4 > buffer.len) return DeserializeError.Truncated;
            var bytes: [4]u8 = undefined;
            std.mem.copyForwards(u8, &bytes, buffer[offset .. offset + 4]);
            offset += 4;
            return net.Address{ .ipv4 = .{ .value = bytes } };
        } else if (tag == .ipv6) {
            if (offset + 16 > buffer.len) return DeserializeError.Truncated;
            var bytes: [16]u8 = undefined;
            std.mem.copyForwards(u8, &bytes, buffer[offset .. offset + 16]);
            offset += 16;

            const scope = try serial.U32.deserialize(buffer[offset..]);
            offset += @sizeOf(u32);

            return net.Address{ .ipv6 = .{ .value = bytes, .scope_id = scope } };
        } else {
            return DeserializeError.InvalidEnumValue;
        }
    }
};
// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ UUID4 ══════════════════════════════╗
pub const UUID4 = struct {
    pub fn wireSize() usize {
        return 16;
    }

    pub fn serialize(uuid: util.UUID4, buffer: []u8) !void {
        if (buffer.len < 16) return SerializeError.BufferTooSmall;
        const raw: [16]u8 = @bitCast(uuid);
        @memcpy(buffer[0..16], raw[0..16]);
    }

    pub fn deserialize(buffer: []const u8) !util.UUID4 {
        if (buffer.len < 16) return DeserializeError.Truncated;
        return util.UUID4{ .bytes = buffer[0..16].* };
    }
};
// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ Angle ══════════════════════════════╗
pub const Angle = struct {
    pub fn wireSize() usize {
        return serial.F32.wireSize();
    }

    pub fn serialize(angle: util.Angle, buffer: []u8) !void {
        try serial.F32.serialize(angle.toDegrees(), buffer);
    }

    pub fn deserializeAngle(buffer: []const u8) !util.Angle {
        return util.Angle.fromDegrees(try serial.F32.deserialize(buffer));
    }
};
// ╚═══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ Vec2 ══════════════════════════════╗
pub const Vec2 = struct {
    pub fn wireSize() usize {
        return serial.F32.wireSize() * 2;
    }
    pub fn serialize(self: util.Vec2, buffer: []u8) void {
        serial.F32.serialize(self.x, buffer);
        serial.F32.serialize(self.y, buffer);
    }

    pub fn deserialize(buffer: []const u8) util.Vec2 {
        const x = serial.F32.deserialize(buffer);
        const y = serial.F32.deserialize(buffer);
        return util.Vec2{ .x = x, .y = y };
    }
};
// ╚══════════════════════════════════════════════════════════════════╝
