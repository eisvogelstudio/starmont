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

const min_level = std.log.Level.info;

pub fn writeTimestamp(buf: []u8) []const u8 {
    const now: u64 = @intCast(std.time.timestamp());
    const s: u32 = @intCast(@mod(now, 86400));
    const h = s / 3600;
    const m = (s % 3600) / 60;
    const sec = s % 60;

    return std.fmt.bufPrint(buf, "{d:02}:{d:02}:{d:02}", .{ h, m, sec }) catch "??:??:??";
}

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const writer = switch (level) {
        .debug, .info => std.io.getStdOut().writer(),
        .warn, .err => std.io.getStdErr().writer(),
    };

    var ts_buf: [8]u8 = undefined;
    const ts = writeTimestamp(&ts_buf);

    const scope_str = if (scope == .default) "" else "[" ++ @tagName(scope) ++ "]";

    var prefix_buf: [128]u8 = undefined;
    const prefix = std.fmt.bufPrint(
        &prefix_buf,
        "[{s}]{s}",
        .{ ts, scope_str },
    ) catch "[<?>][<?>] ";

    _ = writer.print("{s}[{s}] ", .{ prefix, @tagName(level) }) catch {};
    _ = writer.print(format ++ "\n", args) catch {};
}
