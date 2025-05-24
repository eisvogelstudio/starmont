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

pub fn writeId(writer: anytype, id: core.Id) !void {
    try writer.print("Id({d})", .{id.id});
}

pub fn writePosition(writer: anytype, pos: core.Position) !void {
    try writer.print("Position({any}, {any})", .{ pos.x, pos.y });
}

pub fn writeVelocity(writer: anytype, vel: core.Velocity) !void {
    try writer.print("Velocity({any}, {any})", .{ vel.x, vel.y });
}

pub fn writeAcceleration(writer: anytype, acc: core.Acceleration) !void {
    try writer.print("Acceleration({any}, {any})", .{ acc.x, acc.y });
}

pub fn writeJerk(writer: anytype, jerk: core.Jerk) !void {
    try writer.print("Jerk({any}, {any})", .{ jerk.x, jerk.y });
}

pub fn writeShipSize(writer: anytype, size: core.ShipSize) !void {
    try writer.print("ShipSize({s})", .{@tagName(size)});
}
