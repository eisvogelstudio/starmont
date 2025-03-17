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

const std = @import("std");
const testing = std.testing;

pub const ChatMessage = struct {
    text: []const u8,

    pub fn init(allocator: *std.mem.Allocator, text: []const u8) !ChatMessage {
        const dup = try allocator.dupe(u8, text);
        return ChatMessage{
            .text = dup,
        };
    }

    pub fn deinit(self: ChatMessage, allocator: *std.mem.Allocator) void {
        allocator.free(self.text);
    }

    fn serialize(self: ChatMessage, writer: anytype) !void {
        const len: u16 = @intCast(self.text.len);
        const buf: [2]u8 = @bitCast(len);
        try writer.writeAll(&buf);
        try writer.writeAll(self.text);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) !ChatMessage {
        var len_buf: [2]u8 = undefined;
        _ = try reader.readAll(&len_buf);
        const len: u16 = @bitCast(len_buf);
        const text = try allocator.alloc(u8, len);
        _ = try reader.readAll(text);
        return ChatMessage{ .text = text };
    }
};

pub const PositionMessage = struct {
    x: f32,
    y: f32,

    fn serialize(self: PositionMessage, writer: anytype) !void {
        var buf: [4]u8 = undefined;
        buf = @bitCast(self.x);
        try writer.writeAll(&buf);
        buf = @bitCast(self.y);
        try writer.writeAll(&buf);
    }

    fn deserialize(reader: anytype) !PositionMessage {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return PositionMessage{ .x = x, .y = y };
    }
};

pub const VelocityMessage = struct {
    x: f32,
    y: f32,

    fn serialize(self: VelocityMessage, writer: anytype) !void {
        var buf: [4]u8 = undefined;
        buf = @bitCast(self.x);
        try writer.writeAll(&buf);
        buf = @bitCast(self.y);
        try writer.writeAll(&buf);
    }

    fn deserialize(reader: anytype) !VelocityMessage {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return VelocityMessage{ .x = x, .y = y };
    }
};

pub const AccelerationMessage = struct {
    x: f32,
    y: f32,

    fn serialize(self: AccelerationMessage, writer: anytype) !void {
        var buf: [4]u8 = undefined;
        buf = @bitCast(self.x);
        try writer.writeAll(&buf);
        buf = @bitCast(self.y);
        try writer.writeAll(&buf);
    }

    fn deserialize(reader: anytype) !AccelerationMessage {
        var buf: [4]u8 = undefined;
        _ = try reader.readAll(&buf);
        const x: f32 = @bitCast(buf);
        _ = try reader.readAll(&buf);
        const y: f32 = @bitCast(buf);
        return AccelerationMessage{ .x = x, .y = y };
    }
};

pub const MessageType = enum(u8) {
    Chat,
    Position,
    Velocity,
    Acceleration,
};

pub const Message = union(MessageType) {
    Chat: ChatMessage,
    Position: PositionMessage,
    Velocity: VelocityMessage,
    Acceleration: AccelerationMessage,

    pub fn serialize(self: Message, writer: anytype) !void {
        try writer.writeByte(@intFromEnum(self));
        switch (self) {
            .Chat => |chat| {
                try chat.serialize(writer);
            },
            .Position => |pos| {
                try pos.serialize(writer);
            },
            .Velocity => |vel| {
                try vel.serialize(writer);
            },
            .Acceleration => |acc| {
                try acc.serialize(writer);
            },
        }
    }

    pub fn deserialize(reader: anytype, allocator: *std.mem.Allocator) !Message {
        const type_byte = try reader.readByte();
        const message_type: MessageType = @enumFromInt(type_byte);
        switch (message_type) {
            .Chat => {
                const chat = try ChatMessage.deserialize(reader, allocator);
                return Message{ .Chat = chat };
            },
            .Position => {
                const pos = try PositionMessage.deserialize(reader);
                return Message{ .Position = pos };
            },
            .Velocity => {
                const vel = try VelocityMessage.deserialize(reader);
                return Message{ .Velocity = vel };
            },
            .Acceleration => {
                const acc = try AccelerationMessage.deserialize(reader);
                return Message{ .Acceleration = acc };
            },
        }
    }
};
