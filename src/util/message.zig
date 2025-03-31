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

// ---------- starmont ----------
const core = @import("core");
const util = @import("root.zig");
const decode = @import("decode.zig");
const encode = @import("encode.zig");
const format = @import("format.zig");
// ------------------------------

// ---------- external ----------
const String = @import("string").String;
// ------------------------------

pub const ChatMessage = struct {
    text: []const u8,

    pub fn init(allocator: *std.mem.Allocator, text: []const u8) !ChatMessage {
        const dup = try allocator.dupe(u8, text);
        return ChatMessage{
            .text = dup,
        };
    }

    fn deinit(self: ChatMessage, allocator: *std.mem.Allocator) void {
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

    pub fn write(self: ChatMessage, writer: anytype) !void {
        try writer.print("Chat: {s}", .{self.text});
    }
};

pub const StaticMessage = struct {
    position: core.Position,

    pub fn init(position: core.Position) StaticMessage {
        return StaticMessage{
            .position = position,
        };
    }

    fn deinit(self: StaticMessage) void {
        _ = self;
    }

    fn serialize(self: StaticMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
    }

    fn deserialize(reader: anytype) !StaticMessage {
        const pos = try decode.deserializePosition(reader);
        return init(pos);
    }

    pub fn write(self: StaticMessage, writer: anytype) !void {
        try writer.print("Linear: ", .{});

        try writer.print("\n\t", .{});
        try format.writePosition(writer, self.position);
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

    fn deinit(self: LinearMessage) void {
        _ = self;
    }

    fn serialize(self: LinearMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
        try encode.serializeVelocity(writer, self.velocity);
    }

    fn deserialize(reader: anytype) !LinearMessage {
        const pos = try decode.deserializePosition(reader);
        const vel = try decode.deserializeVelocity(reader);
        return init(pos, vel);
    }

    pub fn write(self: LinearMessage, writer: anytype) !void {
        try writer.print("Linear: ", .{});

        try writer.print("\n\t", .{});
        try format.writePosition(writer, self.position);
        try writer.print("\n\t", .{});
        try format.writeVelocity(writer, self.velocity);
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

    fn deinit(self: AcceleratedMessage) void {
        _ = self;
    }

    fn serialize(self: AcceleratedMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
        try encode.serializeVelocity(writer, self.velocity);
        try encode.serializeAcceleration(writer, self.acceleration);
    }

    fn deserialize(reader: anytype) !AcceleratedMessage {
        const pos = try decode.deserializePosition(reader);
        const vel = try decode.deserializeVelocity(reader);
        const acc = try decode.deserializeAcceleration(reader);
        return init(pos, vel, acc);
    }

    pub fn write(self: AcceleratedMessage, writer: anytype) !void {
        try writer.print("Accelerated: ", .{});

        try writer.print("\n\t", .{});
        try format.writePosition(writer, self.position);
        try writer.print("\n\t", .{});
        try format.writeVelocity(writer, self.velocity);
        try writer.print("\n\t", .{});
        try format.writeAcceleration(writer, self.acceleration);
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

    fn deinit(self: DynamicMessage) void {
        _ = self;
    }

    fn serialize(self: DynamicMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
        try encode.serializeVelocity(writer, self.velocity);
        try encode.serializeAcceleration(writer, self.acceleration);
        try encode.serializeJerk(writer, self.jerk);
    }

    fn deserialize(reader: anytype) !DynamicMessage {
        const pos = try decode.deserializePosition(reader);
        const vel = try decode.deserializeVelocity(reader);
        const acc = try decode.deserializeAcceleration(reader);
        const jerk = try decode.deserializeJerk(reader);
        return init(pos, vel, acc, jerk);
    }

    pub fn write(self: DynamicMessage, writer: anytype) !void {
        try writer.print("Dynamic: ", .{});

        try writer.print("\n\t", .{});
        try format.writePosition(writer, self.position);
        try writer.print("\n\t", .{});
        try format.writeVelocity(writer, self.velocity);
        try writer.print("\n\t", .{});
        try format.writeAcceleration(writer, self.acceleration);
        try writer.print("\n\t", .{});
        try format.writeJerk(writer, self.jerk);
    }
};

pub const ActionMessage = struct {
    action: core.Action,

    pub fn init(action: core.Action) ActionMessage {
        return ActionMessage{
            .action = action,
        };
    }

    fn deinit(self: ActionMessage) void {
        _ = self;
    }

    fn serialize(self: ActionMessage, writer: anytype) !void {
        try writer.writeByte(@intFromEnum(self.action));
    }

    fn deserialize(reader: anytype) !ActionMessage {
        const action_byte = try reader.readByte();
        return init(@enumFromInt(action_byte));
    }

    pub fn write(self: ActionMessage, writer: anytype) !void {
        try writer.print("Action: {}", .{self.action});
    }
};

pub const ComponentMessage = union(ComponentType) {
    pub const ComponentType = enum {
        Id,
        Position,
        Velocity,
        Acceleration,
        Jerk,
        ShipSize,
    };

    Id: core.Id,
    Position: core.Position,
    Velocity: core.Velocity,
    Acceleration: core.Acceleration,
    Jerk: core.Jerk,
    ShipSize: core.ShipSize,

    pub fn fromId(id: core.Id) Message {
        return ComponentMessage{
            .Id = id,
        };
    }

    pub fn fromPosition(pos: core.Position) Message {
        return ComponentMessage{
            .Position = pos,
        };
    }

    pub fn fromVelocity(vel: core.Velocity) Message {
        return ComponentMessage{
            .Velocity = vel,
        };
    }

    pub fn fromAcceleration(acc: core.Acceleration) Message {
        return ComponentMessage{
            .Acceleration = acc,
        };
    }

    pub fn fromJerk(jerk: core.Id) Message {
        return ComponentMessage{
            .Jerk = jerk,
        };
    }

    pub fn fromShipSize(size: core.ShipSize) Message {
        return ComponentMessage{
            .ShipSize = size,
        };
    }

    fn deinit(self: ComponentMessage) void {
        _ = self;
    }

    pub fn serialize(self: ComponentMessage, writer: anytype) !void {
        try writer.writeByte(@intFromEnum(self));
        switch (self) {
            .Id => |id| {
                try encode.serializeId(writer, id);
            },
            .Position => |pos| {
                try encode.serializePosition(writer, pos);
            },
            .Velocity => |vel| {
                try encode.serializeVelocity(writer, vel);
            },
            .Acceleration => |acc| {
                try encode.serializeAcceleration(writer, acc);
            },
            .Jerk => |jerk| {
                try encode.serializeJerk(writer, jerk);
            },
            .ShipSize => |size| {
                try encode.serializeShipSize(writer, size);
            },
        }
    }

    pub fn deserialize(reader: anytype) !ComponentMessage {
        const type_byte = try reader.readByte();
        const component_type: ComponentType = @enumFromInt(type_byte);
        switch (component_type) {
            .Id => {
                const id = try decode.deserializeId(reader);
                return ComponentMessage{ .Id = id };
            },
            .Position => {
                const pos = try decode.deserializePosition(reader);
                return ComponentMessage{ .Position = pos };
            },
            .Velocity => {
                const vel = try decode.deserializeVelocity(reader);
                return ComponentMessage{ .Velocity = vel };
            },
            .Acceleration => {
                const acc = try decode.deserializeAcceleration(reader);
                return ComponentMessage{ .Acceleration = acc };
            },
            .Jerk => {
                const jerk = try decode.deserializeJerk(reader);
                return ComponentMessage{ .Jerk = jerk };
            },
            .ShipSize => {
                const size = try decode.deserializeShipSize(reader);
                return ComponentMessage{ .ShipSize = size };
            },
        }
    }

    pub fn write(self: ComponentMessage, writer: anytype) !void {
        switch (self) {
            .Id => |id| {
                try format.writeId(writer, id);
            },
            .Position => |pos| {
                try format.writePosition(writer, pos);
            },
            .Velocity => |vel| {
                try format.writeVelocity(writer, vel);
            },
            .Acceleration => |acc| {
                try format.writeAcceleration(writer, acc);
            },
            .Jerk => |jerk| {
                try format.writeJerk(writer, jerk);
            },
            .ShipSize => |size| {
                try format.writeShipSize(writer, size);
            },
        }
    }
};

pub const MessageType = enum(u8) {
    Chat,
    Static,
    Linear,
    Accelerated,
    Dynamic,
    Action,
    Component,
};

pub const Message = union(MessageType) {
    Chat: ChatMessage,
    Static: StaticMessage,
    Linear: LinearMessage,
    Accelerated: AcceleratedMessage,
    Dynamic: DynamicMessage,
    Action: ActionMessage,
    Component: ComponentMessage,

    pub fn deinit(self: Message, allocator: *std.mem.Allocator) void {
        switch (self) {
            .Chat => |chat| {
                chat.deinit(allocator);
            },
            .Static => |static| {
                static.deinit();
            },
            .Linear => |linear| {
                linear.deinit();
            },
            .Accelerated => |accelerated| {
                accelerated.deinit();
            },
            .Dynamic => |dynamic| {
                dynamic.deinit();
            },
            .Action => |action| {
                action.deinit();
            },
            .Component => |comp| {
                comp.deinit();
            },
        }
    }

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
            .Component => |comp| {
                try comp.serialize(writer);
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
            .Component => {
                const comp = try ComponentMessage.deserialize(reader);
                return Message{ .Component = comp };
            },
        }
    }

    pub fn print(self: Message, writer: anytype) !void {
        switch (self) {
            .Chat => |chat| {
                try chat.write(writer);
            },
            .Static => |static| {
                try static.write(writer);
            },
            .Linear => |linear| {
                try linear.write(writer);
            },
            .Accelerated => |accelerated| {
                try accelerated.write(writer);
            },
            .Dynamic => |dynamic| {
                try dynamic.write(writer);
            },
            .Action => |action| {
                try action.write(writer);
            },
            .Component => |comp| {
                try comp.write(writer);
            },
        }
    }
};
