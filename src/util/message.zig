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

pub const ChatMessage = struct {
    text: []const u8,

    pub fn init(allocator: *std.mem.Allocator, text: []const u8) !Message {
        const dup = try allocator.dupe(u8, text);
        const chat = ChatMessage{
            .text = dup,
        };

        return Message{ .Chat = chat };
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

    pub fn init(position: core.Position) Message {
        const static = StaticMessage{
            .position = position,
        };

        return Message{ .Static = static };
    }

    fn deinit(self: StaticMessage) void {
        _ = self;
    }

    fn serialize(self: StaticMessage, writer: anytype) !void {
        try encode.serializePosition(writer, self.position);
    }

    fn deserialize(reader: anytype) !StaticMessage {
        const pos = try decode.deserializePosition(reader);
        return init(pos).Static;
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

    pub fn init(position: core.Position, velocity: core.Velocity) Message {
        const linear = LinearMessage{
            .position = position,
            .velocity = velocity,
        };

        return Message{ .Linear = linear };
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
        return init(pos, vel).Linear;
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

    pub fn init(position: core.Position, velocity: core.Velocity, acceleration: core.Acceleration) Message {
        const accelerated = AcceleratedMessage{
            .position = position,
            .velocity = velocity,
            .acceleration = acceleration,
        };

        return Message{ .Accelerated = accelerated };
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
        return init(pos, vel, acc).Accelerated;
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

    pub fn init(position: core.Position, velocity: core.Velocity, acceleration: core.Acceleration, jerk: core.Jerk) Message {
        const dynamic = DynamicMessage{
            .position = position,
            .velocity = velocity,
            .acceleration = acceleration,
            .jerk = jerk,
        };

        return Message{ .Dynamic = dynamic };
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
        return init(pos, vel, acc, jerk).Dynamic;
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

    pub fn init(action: core.Action) Message {
        const msg = ActionMessage{
            .action = action,
        };

        return Message{ .Action = msg };
    }

    fn deinit(self: ActionMessage) void {
        _ = self;
    }

    fn serialize(self: ActionMessage, writer: anytype) !void {
        try writer.writeByte(@intFromEnum(self.action));
    }

    fn deserialize(reader: anytype) !ActionMessage {
        const action_byte = try reader.readByte();
        return init(@enumFromInt(action_byte)).Action;
    }

    pub fn write(self: ActionMessage, writer: anytype) !void {
        try writer.print("Action: {}", .{self.action});
    }
};

pub const EntityMessage = struct {
    id: core.Id,

    pub fn init(id: core.Id) Message {
        const msg = EntityMessage{
            .id = id,
        };

        return Message{ .Entity = msg };
    }

    fn deinit(self: EntityMessage) void {
        _ = self;
    }

    fn serialize(self: EntityMessage, writer: anytype) !void {
        try encode.serializeId(writer, self.id);
    }

    fn deserialize(reader: anytype) !EntityMessage {
        const id = try decode.deserializeId(reader);
        return init(id).Entity;
    }

    pub fn write(self: EntityMessage, writer: anytype) !void {
        try writer.print("EntityMessage: {}", .{self.id});
    }
};

pub const EntityRemoveMessage = struct {
    id: core.Id,

    pub fn init(id: core.Id) Message {
        const msg = EntityRemoveMessage{
            .id = id,
        };

        return Message{ .EntityRemove = msg };
    }

    fn deinit(self: EntityRemoveMessage) void {
        _ = self;
    }

    fn serialize(self: EntityRemoveMessage, writer: anytype) !void {
        try encode.serializeId(writer, self.id);
    }

    fn deserialize(reader: anytype) !EntityRemoveMessage {
        const id = try decode.deserializeId(reader);
        return init(id).EntityRemove;
    }

    pub fn write(self: EntityRemoveMessage, writer: anytype) !void {
        try writer.print("EntityRemoveMessage: {}", .{self.id});
    }
};

pub const ComponentMessage = struct {
    id: core.Id,
    component: Component,

    pub const Component = union(core.ComponentType) {
        Position: core.Position,
        Velocity: core.Velocity,
        Acceleration: core.Acceleration,
        Jerk: core.Jerk,
        ShipSize: core.ShipSize,
    };

    pub fn fromPosition(id: core.Id, pos: core.Position) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{ .Position = pos },
        };

        return Message{ .Component = comp };
    }

    pub fn fromVelocity(id: core.Id, vel: core.Velocity) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .Velocity = vel,
            },
        };

        return Message{ .Component = comp };
    }

    pub fn fromAcceleration(id: core.Id, acc: core.Acceleration) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .Acceleration = acc,
            },
        };

        return Message{ .Component = comp };
    }

    pub fn fromJerk(id: core.Id, jerk: core.Id) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .Jerk = jerk,
            },
        };

        return Message{ .Component = comp };
    }

    pub fn fromShipSize(id: core.Id, size: core.ShipSize) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .ShipSize = size,
            },
        };

        return Message{ .Component = comp };
    }

    fn deinit(self: ComponentMessage) void {
        _ = self;
    }

    pub fn serialize(self: ComponentMessage, writer: anytype) !void {
        try encode.serializeId(writer, self.id);
        try writer.writeByte(@intFromEnum(self.component));
        switch (self.component) {
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
        const id = try decode.deserializeId(reader);
        const type_byte = try reader.readByte();
        const component_type: core.ComponentType = @enumFromInt(type_byte);
        const component = switch (component_type) {
            .Position => Component{ .Position = try decode.deserializePosition(reader) },
            .Velocity => Component{ .Velocity = try decode.deserializeVelocity(reader) },
            .Acceleration => Component{ .Acceleration = try decode.deserializeAcceleration(reader) },
            .Jerk => Component{ .Jerk = try decode.deserializeJerk(reader) },
            .ShipSize => Component{ .ShipSize = try decode.deserializeShipSize(reader) },
        };

        return ComponentMessage{ .id = id, .component = component };
    }

    pub fn write(self: ComponentMessage, writer: anytype) !void {
        try writer.print("ComponentMessage: ", .{});
        try writer.print("\n\t", .{});
        try format.writeId(writer, self.id);
        switch (self.component) {
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

pub const ComponentRemoveMessage = struct {
    id: core.Id,
    component: core.ComponentType,

    pub fn init(id: core.Id, component: core.ComponentType) Message {
        const msg = ComponentRemoveMessage{
            .id = id,
            .component = component,
        };

        return Message{ .ComponentRemove = msg };
    }

    fn deinit(self: ComponentRemoveMessage) void {
        _ = self;
    }

    fn serialize(self: ComponentRemoveMessage, writer: anytype) !void {
        try encode.serializeId(writer, self.id);
        try writer.writeByte(@intFromEnum(self.component));
    }

    fn deserialize(reader: anytype) !ComponentRemoveMessage {
        const id = try decode.deserializeId(reader);
        const type_byte = try reader.readByte();
        return init(id, @enumFromInt(type_byte)).ComponentRemove;
    }

    pub fn write(self: ComponentRemoveMessage, writer: anytype) !void {
        try writer.print("ComponentRemove: {}", .{self.component});
    }
};

pub const MessageType = enum(u8) {
    Chat,
    Static,
    Linear,
    Accelerated,
    Dynamic,
    Action,
    Entity,
    EntityRemove,
    Component,
    ComponentRemove,
};

pub const Message = union(MessageType) {
    Chat: ChatMessage,
    Static: StaticMessage,
    Linear: LinearMessage,
    Accelerated: AcceleratedMessage,
    Dynamic: DynamicMessage,
    Action: ActionMessage,
    Entity: EntityMessage,
    EntityRemove: EntityRemoveMessage,
    Component: ComponentMessage,
    ComponentRemove: ComponentRemoveMessage,

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
            .Entity => |id| {
                id.deinit();
            },
            .EntityRemove => |id| {
                id.deinit();
            },
            .Component => |comp| {
                comp.deinit();
            },
            .ComponentRemove => |comp| {
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
            .Entity => |id| {
                try id.serialize(writer);
            },
            .EntityRemove => |id| {
                try id.serialize(writer);
            },
            .Component => |comp| {
                try comp.serialize(writer);
            },
            .ComponentRemove => |comp| {
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
            .Entity => {
                const id = try EntityMessage.deserialize(reader);
                return Message{ .Entity = id };
            },
            .EntityRemove => {
                const id = try EntityRemoveMessage.deserialize(reader);
                return Message{ .EntityRemove = id };
            },
            .Component => {
                const comp = try ComponentMessage.deserialize(reader);
                return Message{ .Component = comp };
            },
            .ComponentRemove => {
                const comp = try ComponentRemoveMessage.deserialize(reader);
                return Message{ .ComponentRemove = comp };
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
            .Entity => |id| {
                try id.write(writer);
            },
            .EntityRemove => |id| {
                try id.write(writer);
            },
            .Component => |comp| {
                try comp.write(writer);
            },
            .ComponentRemove => |comp| {
                try comp.write(writer);
            },
        }
    }
};
