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

const core = @import("core");

const decode = @import("decode.zig");
const encode = @import("encode.zig");

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

    pub fn serialize(self: ChatMessage, writer: anytype) !void {
        const len: u16 = @intCast(self.text.len);
        const buf: [2]u8 = @bitCast(len);
        try writer.writeAll(&buf);
        try writer.writeAll(self.text);
    }

    pub fn deserialize(reader: anytype, allocator: *std.mem.Allocator) !ChatMessage {
        var len_buf: [2]u8 = undefined;
        _ = try reader.readAll(&len_buf);
        const len: u16 = @bitCast(len_buf);
        const text = try allocator.alloc(u8, len);
        _ = try reader.readAll(text);
        return ChatMessage{ .text = text };
    }
};

pub const StaticMessage = struct {
    position: core.Position,

    pub fn init(position: core.Position) StaticMessage {
        return StaticMessage{
            .position = position,
        };
    }

    pub fn deinit(self: StaticMessage) void {
        _ = self;
    }

    pub fn serialize(self: StaticMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
    }

    pub fn deserialize(reader: anytype) !StaticMessage {
        const pos = try decode.deserializePosition(reader);
        return init(pos);
    }
};

pub const LinearMessage = struct {
    position: core.Position,
    velocity: core.Velocity,

    pub fn init(position: core.Position, velocity: core.Velocity) LinearMessage {
        return LinearMessage{
            .position = position,
            .velocity = velocity,
        };
    }

    pub fn deinit(self: LinearMessage) void {
        _ = self;
    }

    pub fn serialize(self: LinearMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
        try encode.serializeVelocity(writer, self.velocity);
    }

    pub fn deserialize(reader: anytype) !LinearMessage {
        const pos = try decode.deserializePosition(reader);
        const vel = try decode.deserializeVelocity(reader);
        return init(pos, vel);
    }
};

pub const AcceleratedMessage = struct {
    position: core.Position,
    velocity: core.Velocity,
    acceleration: core.Acceleration,

    pub fn init(position: core.Position, velocity: core.Velocity, acceleration: core.Acceleration) AcceleratedMessage {
        return AcceleratedMessage{
            .position = position,
            .velocity = velocity,
            .acceleration = acceleration,
        };
    }

    pub fn deinit(self: AcceleratedMessage) void {
        _ = self;
    }

    pub fn serialize(self: AcceleratedMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
        try encode.serializeVelocity(writer, self.velocity);
        try encode.serializeAcceleration(writer, self.acceleration);
    }

    pub fn deserialize(reader: anytype) !AcceleratedMessage {
        const pos = try decode.deserializePosition(reader);
        const vel = try decode.deserializeVelocity(reader);
        const acc = try decode.deserializeAcceleration(reader);
        return init(pos, vel, acc);
    }
};

pub const DynamicMessage = struct {
    position: core.Position,
    velocity: core.Velocity,
    acceleration: core.Acceleration,
    jerk: core.Jerk,

    pub fn init(position: core.Position, velocity: core.Velocity, acceleration: core.Acceleration, jerk: core.Jerk) DynamicMessage {
        return DynamicMessage{
            .position = position,
            .velocity = velocity,
            .acceleration = acceleration,
            .jerk = jerk,
        };
    }

    pub fn deinit(self: DynamicMessage) void {
        _ = self;
    }

    pub fn serialize(self: DynamicMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
        try encode.serializeVelocity(writer, self.velocity);
        try encode.serializeAcceleration(writer, self.acceleration);
        try encode.serializeJerk(writer, self.jerk);
    }

    pub fn deserialize(reader: anytype) !DynamicMessage {
        const pos = try decode.deserializePosition(reader);
        const vel = try decode.deserializeVelocity(reader);
        const acc = try decode.deserializeAcceleration(reader);
        const jerk = try decode.deserializeJerk(reader);
        return init(pos, vel, acc, jerk);
    }
};

pub const ActionMessage = struct {
    action: core.Action,

    pub fn init(action: core.Action) ActionMessage {
        return ActionMessage{
            .action = action,
        };
    }

    pub fn deinit(self: ActionMessage) void {
        _ = self;
    }

    pub fn serialize(self: ActionMessage, writer: anytype) !void {
        try writer.writeByte(@intFromEnum(self.action));
    }

    pub fn deserialize(reader: anytype) !ActionMessage {
        const action_byte = try reader.readByte();
        return init(@enumFromInt(action_byte));
    }
};

pub const MessageType = enum(u8) {
    Chat,
    Static,
    Linear,
    Accelerated,
    Dynamic,
    Action,
};

pub const Message = union(MessageType) {
    Chat: ChatMessage,
    Static: StaticMessage,
    Linear: LinearMessage,
    Accelerated: AcceleratedMessage,
    Dynamic: DynamicMessage,
    Action: ActionMessage,

    pub fn serialize(self: Message, writer: anytype) !void {
        try writer.writeByte(@intFromEnum(self));
        switch (self) {
            .Chat => |chat| {
                try chat.serialize(writer);
            },
            .Static => |static| {
                try static.serialize(writer);
            },
            .Linear => |linear| {
                try linear.serialize(writer);
            },
            .Accelerated => |accelerated| {
                try accelerated.serialize(writer);
            },
            .Dynamic => |dynamic| {
                try dynamic.serialize(writer);
            },
            .Action => |action| {
                try action.serialize(writer);
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
            .Static => {
                const pos = try StaticMessage.deserialize(reader);
                return Message{ .Static = pos };
            },
            .Linear => {
                const vel = try LinearMessage.deserialize(reader);
                return Message{ .Linear = vel };
            },
            .Accelerated => {
                const acc = try AcceleratedMessage.deserialize(reader);
                return Message{ .Accelerated = acc };
            },
            .Dynamic => {
                const dyn = try DynamicMessage.deserialize(reader);
                return Message{ .Dynamic = dyn };
            },
            .Action => {
                const act = try ActionMessage.deserialize(reader);
                return Message{ .Action = act };
            },
        }
    }
};
