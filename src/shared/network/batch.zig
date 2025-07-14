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

// ---------- network ----------
const message = @import("message.zig");
const decode = @import("decode.zig");
const encode = @import("encode.zig");
// -----------------------------

pub const Batch = struct {
    allocator: *std.mem.Allocator,
    messages: std.ArrayList(message.Message),
    id: usize = 0,

    pub fn init(allocator: *std.mem.Allocator) Batch {
        const batch = Batch{
            .allocator = allocator,
            .messages = std.ArrayList(message.Message).init(allocator.*),
        };

        return batch;
    }

    pub fn deinit(self: *Batch) void {
        for (self.messages.items) |*msg| {
            msg.deinit();
        }
        self.messages.deinit();
    }

    pub fn copy(self: *Batch, allocator: *std.mem.Allocator) Batch {
        var messages = std.ArrayList(message.Message).init(allocator.*);

        messages.appendSlice(self.messages.items) catch unreachable;

        return Batch{
            .allocator = allocator,
            .messages = messages,
            .id = self.id,
        };
    }

    pub fn append(self: *Batch, msg: message.Message) !void {
        if (self.messages.items.len > std.math.maxInt(u16) - 1) {
            return error.Overflow;
        }

        self.messages.append(msg) catch unreachable;
    }

    pub fn clear(self: *Batch) void {
        self.messages.clearRetainingCapacity();
    }

    pub fn serialize(self: *const Batch, writer: anytype) void {
        const count: u16 = @intCast(self.messages.items.len);
        encode.serializeU16(writer, count);

        for (self.messages.items) |msg| {
            msg.serialize(writer);
        }
    }

    pub fn deserialize(reader: anytype, allocator: *std.mem.Allocator) Batch {
        const count = decode.deserializeU16(reader);
        var batch = Batch.init(allocator);

        var i: usize = 0;
        while (i < count) : (i += 1) {
            const msg = message.Message.deserialize(reader, allocator);
            batch.append(msg) catch unreachable;
        }

        return batch;
    }

    pub fn print(self: *const Batch, writer: anytype) void {
        writer.print("Batch ({} messages):\n", .{self.messages.items.len}) catch unreachable;
        for (self.messages.items, 0..) |msg, i| {
            writer.print("  [{}] ", .{i}) catch unreachable;
            msg.print(writer) catch unreachable;
            writer.print("\n", .{}) catch unreachable;
        }
    }
};
