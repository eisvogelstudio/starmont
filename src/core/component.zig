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

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

pub const Identifier = struct {
    id: u64,
};

pub const Position = struct {
    x: f32,
    y: f32,

    pub fn deserialize(reader: anytype) !Position {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return Position{ .x = x, .y = y };
    }
};

pub const Velocity = struct {
    x: f32,
    y: f32,

    pub fn deserialize(reader: anytype) !Velocity {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return Velocity{ .x = x, .y = y };
    }
};

pub const Acceleration = struct {
    x: f32,
    y: f32,

    pub fn deserialize(reader: anytype) !Acceleration {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return Acceleration{ .x = x, .y = y };
    }
};

pub const Jerk = struct {
    x: f32,
    y: f32,

    pub fn deserialize(reader: anytype) !Jerk {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return Jerk{ .x = x, .y = y };
    }
};

pub const ShipSize = enum {
    Small,
    Medium,
    Large,
    Capital,
};
