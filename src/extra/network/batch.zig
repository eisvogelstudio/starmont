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
const testing = std.testing;
// -------------------------

// ---------- local ----------
const message = @import("message.zig");
const Package = @import("package.zig").Package;
const serial = @import("serial/serial.zig");
// ---------------------------

pub const Update = struct {
    gpa: *std.mem.Allocator,
    messages: std.ArrayList(Package),
    tick: u64 = undefined,

    pub fn init(gpa: *std.mem.Allocator) Update {
        const batch = Update{
            .gpa = gpa,
            .messages = std.ArrayList(Package).init(gpa.*),
        };

        return batch;
    }

    pub fn deinit(self: *Update) void {
        for (self.messages.items) |*msg| {
            msg.deinit();
        }
        self.messages.deinit();
    }

    pub fn copy(self: *Update, gpa: *std.mem.Allocator) Update {
        var messages = std.ArrayList(message.Message).init(gpa.*);

        messages.appendSlice(self.messages.items) catch unreachable;

        return Update{
            .gpa = gpa,
            .messages = messages,
            .id = self.id,
        };
    }

    pub fn append(self: *Update, msg: message.Message) !void {
        //if (self.messages.items.len >= max_size) {
        //    return error.Overflow;
        //}

        self.messages.append(msg) catch unreachable;
    }

    pub fn clear(self: *Update) void {
        self.messages.clearRetainingCapacity();
    }

    pub fn serialize(self: *const Update, writer: anytype) void {
        const count: u16 = @intCast(self.messages.items.len);
        serial.serializeU16(writer, count);

        std.log.info("batch size A: {any}", .{count});

        for (self.messages.items) |msg| {
            msg.serialize(writer);
        }
    }

    pub fn deserialize(reader: anytype, gpa: *std.mem.Allocator) Update {
        const count = serial.deserializeU16(reader);
        var batch = Update.init(gpa);

        std.log.info("batch size RECEIVE: {any}", .{count});

        var i: usize = 0;
        while (i < count) : (i += 1) {
            const msg = message.Message.deserialize(reader, gpa);
            batch.append(msg) catch unreachable;
        }

        return batch;
    }

    pub fn print(self: *const Update, writer: anytype) void {
        writer.print("Batch ({} messages):\n", .{self.messages.items.len}) catch unreachable;
        for (self.messages.items, 0..) |msg, i| {
            writer.print("  [{}] ", .{i}) catch unreachable;
            msg.print(writer) catch unreachable;
            writer.print("\n", .{}) catch unreachable;
        }
    }
};
