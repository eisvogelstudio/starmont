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

// ---------- starmont --------
const core = @import("shared").core;
// ----------------------------

pub fn writeId(writer: anytype, id: core.Id) void {
    writer.print("Id({d})", .{id.id}) catch unreachable;
}

pub fn writePosition(writer: anytype, pos: core.Position) void {
    writer.print("Position({any}, {any})", .{ pos.x, pos.y }) catch unreachable;
}

pub fn writeVelocity(writer: anytype, vel: core.Velocity) void {
    writer.print("Velocity({any}, {any})", .{ vel.x, vel.y }) catch unreachable;
}

pub fn writeAcceleration(writer: anytype, acc: core.Acceleration) void {
    writer.print("Acceleration({any}, {any})", .{ acc.x, acc.y }) catch unreachable;
}

pub fn writeJerk(writer: anytype, jerk: core.Jerk) void {
    writer.print("Jerk({any}, {any})", .{ jerk.x, jerk.y }) catch unreachable;
}

pub fn writeShipSize(writer: anytype, size: core.ShipSize) void {
    writer.print("ShipSize({s})", .{@tagName(size)}) catch unreachable;
}
