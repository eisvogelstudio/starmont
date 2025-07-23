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
const ziggy = @import("ziggy");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

pub fn load(allocator: std.mem.Allocator, path: []const u8, T: type) !?T {
    const fs = std.fs.cwd();
    const file = fs.openFile(path, .{}) catch |err| {
        switch (err) {
            error.FileNotFound => return error.FileNotFound,
            else => return error.CouldNotOpen,
        }
    };
    defer file.close();

    const stat = file.stat() catch unreachable;
    file.seekTo(0) catch unreachable;

    const raw = allocator.alloc(u8, stat.size) catch unreachable;
    defer allocator.free(raw);

    const buffer = file.readToEndAlloc(allocator, stat.size) catch unreachable;
    defer allocator.free(buffer);

    const file_data = allocator.dupeZ(u8, buffer) catch unreachable;
    defer allocator.free(file_data);

    const result = ziggy.parseLeaky(T, allocator, file_data, .{}) catch {
        return error.InvalidFormat;
    };

    return result;
}

pub fn save(allocator: std.mem.Allocator, path: []const u8, value: anytype) !void {
    var output_buffer = std.ArrayList(u8).init(allocator);
    defer output_buffer.deinit();

    ziggy.stringify(value, .{}, output_buffer.writer()) catch unreachable;

    const fs = std.fs.cwd();
    const file = try fs.createFile(path, .{
        .truncate = true,
        .read = false,
    });
    defer file.close();

    _ = file.writeAll(output_buffer.items) catch unreachable;

    runZiggyFmt(allocator, path) catch unreachable;
}

pub fn runZiggyFmt(allocator: std.mem.Allocator, path: []const u8) !void {
    var child = std.process.Child.init(&[_][]const u8{
        "ziggy", "fmt", path,
    }, allocator);

    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;
    child.stdin_behavior = .Inherit;

    try child.spawn();
    const result = try child.wait();

    switch (result) {
        .Exited => |code| {
            if (code != 0)
                return error.FmtFailed;
        },
        else => return error.FmtDidNotExitCleanly,
    }
}
