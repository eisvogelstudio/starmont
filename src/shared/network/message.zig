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
// -------------------------

// ---------- network ----------
const decode = @import("decode.zig");
const encode = @import("encode.zig");
// -----------------------------

// ---------- shared ----------
const core = @import("../core/root.zig");
const util = @import("../util/root.zig");
// ----------------------------

pub const AlphaMessage = struct {
    tick: u64,

    pub fn init(tick: u64) Message {
        const alpha = AlphaMessage{
            .tick = tick,
        };

        return Message{ .Alpha = alpha };
    }

    fn deinit(self: AlphaMessage) void {
        _ = self;
    }

    fn serialize(self: AlphaMessage, writer: anytype) void {
        encode.serializeU64(writer, self.tick);
    }

    fn deserialize(reader: anytype) AlphaMessage {
        const tick = decode.deserializeU64(reader);
        return AlphaMessage{ .tick = tick };
    }

    pub fn write(self: AlphaMessage, writer: anytype) void {
        writer.print("Alpha: {d}", .{self.tick}) catch unreachable;
    }
};

pub const ChatMessage = struct {
    allocator: *std.mem.Allocator,
    text: []const u8,

    pub fn init(allocator: *std.mem.Allocator, text: []const u8) Message {
        const dup = allocator.dupe(u8, text) catch unreachable;
        const chat = ChatMessage{
            .text = dup,
        };

        return Message{ .Chat = chat };
    }

    fn deinit(self: ChatMessage) void {
        self.allocator.free(self.text);
    }

    fn serialize(self: ChatMessage, writer: anytype) void {
        const len: u16 = @intCast(self.text.len);
        const buf: [2]u8 = @bitCast(len);
        writer.writeAll(&buf) catch unreachable;
        writer.writeAll(self.text) catch unreachable;
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) ChatMessage {
        var len_buf: [2]u8 = undefined;
        _ = reader.readAll(&len_buf) catch unreachable;
        const len: u16 = @bitCast(len_buf);
        const text = allocator.alloc(u8, len) catch unreachable;
        _ = reader.readAll(text) catch unreachable;
        return ChatMessage{ .allocator = allocator, .text = text };
    }

    pub fn write(self: ChatMessage, writer: anytype) void {
        writer.print("Chat: {s}", .{self.text}) catch unreachable;
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

    fn serialize(self: StaticMessage, writer: anytype) void {
        encode.serializePosition(writer, self.position);
    }

    fn deserialize(reader: anytype) StaticMessage {
        const pos = decode.deserializePosition(reader);
        return init(pos).Static;
    }

    pub fn write(self: StaticMessage, writer: anytype) void {
        writer.print("Linear: ", .{}) catch unreachable;

        writer.print("\n\t", .{}) catch unreachable;
        util.format.writePosition(writer, self.position);
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

    fn serialize(self: LinearMessage, writer: anytype) void {
        encode.serializePosition(writer, self.position);
        encode.serializeVelocity(writer, self.velocity);
    }

    fn deserialize(reader: anytype) LinearMessage {
        const pos = decode.deserializePosition(reader);
        const vel = decode.deserializeVelocity(reader);
        return init(pos, vel).Linear;
    }

    pub fn write(self: LinearMessage, writer: anytype) void {
        writer.print("Linear: ", .{}) catch unreachable;

        writer.print("\n\t", .{}) catch unreachable;
        util.format.writePosition(writer, self.position);
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeVelocity(writer, self.velocity);
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

    fn serialize(self: AcceleratedMessage, writer: anytype) void {
        encode.serializePosition(writer, self.position);
        encode.serializeVelocity(writer, self.velocity);
        encode.serializeAcceleration(writer, self.acceleration);
    }

    fn deserialize(reader: anytype) AcceleratedMessage {
        const pos = decode.deserializePosition(reader);
        const vel = decode.deserializeVelocity(reader);
        const acc = decode.deserializeAcceleration(reader);
        return init(pos, vel, acc).Accelerated;
    }

    pub fn write(self: AcceleratedMessage, writer: anytype) void {
        writer.print("Accelerated: ", .{}) catch unreachable;

        writer.print("\n\t", .{}) catch unreachable;
        util.format.writePosition(writer, self.position);
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeVelocity(writer, self.velocity);
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeAcceleration(writer, self.acceleration);
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

    fn serialize(self: DynamicMessage, writer: anytype) void {
        encode.serializePosition(writer, self.position);
        encode.serializeVelocity(writer, self.velocity);
        encode.serializeAcceleration(writer, self.acceleration);
        encode.serializeJerk(writer, self.jerk);
    }

    fn deserialize(reader: anytype) DynamicMessage {
        const pos = decode.deserializePosition(reader);
        const vel = decode.deserializeVelocity(reader);
        const acc = decode.deserializeAcceleration(reader);
        const jerk = decode.deserializeJerk(reader);
        return init(pos, vel, acc, jerk).Dynamic;
    }

    pub fn write(self: DynamicMessage, writer: anytype) void {
        writer.print("Dynamic: ", .{}) catch unreachable;

        writer.print("\n\t", .{}) catch unreachable;
        util.format.writePosition(writer, self.position);
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeVelocity(writer, self.velocity);
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeAcceleration(writer, self.acceleration);
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeJerk(writer, self.jerk);
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

    fn serialize(self: ActionMessage, writer: anytype) void {
        writer.writeByte(@intFromEnum(self.action)) catch unreachable;
    }

    fn deserialize(reader: anytype) ActionMessage {
        const action_byte = reader.readByte() catch unreachable;
        return init(@enumFromInt(action_byte)).Action;
    }

    pub fn write(self: ActionMessage, writer: anytype) void {
        writer.print("Action: {}", .{self.action}) catch unreachable;
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

    fn serialize(self: EntityMessage, writer: anytype) void {
        encode.serializeId(writer, self.id);
    }

    fn deserialize(reader: anytype) EntityMessage {
        const id = decode.deserializeId(reader);
        return init(id).Entity;
    }

    pub fn write(self: EntityMessage, writer: anytype) void {
        writer.print("EntityMessage: {}", .{self.id}) catch unreachable;
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

    fn serialize(self: EntityRemoveMessage, writer: anytype) void {
        encode.serializeId(writer, self.id);
    }

    fn deserialize(reader: anytype) EntityRemoveMessage {
        const id = decode.deserializeId(reader);
        return init(id).EntityRemove;
    }

    pub fn write(self: EntityRemoveMessage, writer: anytype) void {
        writer.print("EntityRemoveMessage: {}", .{self.id}) catch unreachable;
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

    pub fn serialize(self: ComponentMessage, writer: anytype) void {
        encode.serializeId(writer, self.id);
        writer.writeByte(@intFromEnum(self.component)) catch unreachable;
        switch (self.component) {
            .Position => |pos| {
                encode.serializePosition(writer, pos);
            },
            .Velocity => |vel| {
                encode.serializeVelocity(writer, vel);
            },
            .Acceleration => |acc| {
                encode.serializeAcceleration(writer, acc);
            },
            .Jerk => |jerk| {
                encode.serializeJerk(writer, jerk);
            },
            .ShipSize => |size| {
                encode.serializeShipSize(writer, size);
            },
        }
    }

    pub fn deserialize(reader: anytype) ComponentMessage {
        const id = decode.deserializeId(reader);
        const type_byte = reader.readByte() catch unreachable;
        const comp_type: core.ComponentType = @enumFromInt(type_byte);
        const comp = switch (comp_type) {
            .Position => Component{ .Position = decode.deserializePosition(reader) },
            .Velocity => Component{ .Velocity = decode.deserializeVelocity(reader) },
            .Acceleration => Component{ .Acceleration = decode.deserializeAcceleration(reader) },
            .Jerk => Component{ .Jerk = decode.deserializeJerk(reader) },
            .ShipSize => Component{ .ShipSize = decode.deserializeShipSize(reader) },
        };

        return ComponentMessage{ .id = id, .component = comp };
    }

    pub fn write(self: ComponentMessage, writer: anytype) void {
        writer.print("ComponentMessage: ", .{}) catch unreachable;
        writer.print("\n\t", .{}) catch unreachable;
        util.format.writeId(writer, self.id);
        writer.print("\n\t", .{}) catch unreachable;
        switch (self.component) {
            .Position => |pos| {
                util.format.writePosition(writer, pos);
            },
            .Velocity => |vel| {
                util.format.writeVelocity(writer, vel);
            },
            .Acceleration => |acc| {
                util.format.writeAcceleration(writer, acc);
            },
            .Jerk => |jerk| {
                util.format.writeJerk(writer, jerk);
            },
            .ShipSize => |size| {
                util.format.writeShipSize(writer, size);
            },
        }
    }
};

pub const ComponentRemoveMessage = struct {
    id: core.Id,
    component: core.ComponentType,

    pub fn init(id: core.Id, comp: core.ComponentType) Message {
        const msg = ComponentRemoveMessage{
            .id = id,
            .component = comp,
        };

        return Message{ .ComponentRemove = msg };
    }

    fn deinit(self: ComponentRemoveMessage) void {
        _ = self;
    }

    fn serialize(self: ComponentRemoveMessage, writer: anytype) void {
        encode.serializeId(writer, self.id);
        writer.writeByte(@intFromEnum(self.component)) catch unreachable;
    }

    fn deserialize(reader: anytype) ComponentRemoveMessage {
        const id = decode.deserializeId(reader);
        const type_byte = reader.readByte() catch unreachable;
        return init(id, @enumFromInt(type_byte)).ComponentRemove;
    }

    pub fn write(self: ComponentRemoveMessage, writer: anytype) void {
        writer.print("ComponentRemove: {}", .{self.component}) catch unreachable;
    }
};

pub const SnapshotRequestMessage = struct {
    pub fn init() Message {
        const msg = SnapshotRequestMessage{};

        return Message{ .SnapshotRequest = msg };
    }

    fn deinit(self: SnapshotRequestMessage) void {
        _ = self;
    }

    fn serialize(self: SnapshotRequestMessage, writer: anytype) void {
        _ = self;
        _ = writer;

        return;
    }

    fn deserialize(reader: anytype) SnapshotRequestMessage {
        _ = reader;
        return init().SnapshotRequest;
    }

    pub fn write(self: SnapshotRequestMessage, writer: anytype) void {
        _ = self;

        writer.print("SnapshotRequestMessage", .{}) catch unreachable;
    }
};

pub const MessageType = enum(u8) {
    Alpha,
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
    SnapshotRequest,
};

pub const Message = union(MessageType) {
    Alpha: AlphaMessage,
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
    SnapshotRequest: SnapshotRequestMessage,

    pub fn deinit(self: Message) void {
        switch (self) {
            .Alpha => |alpha| {
                alpha.deinit();
            },
            .Chat => |chat| {
                chat.deinit();
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
            .SnapshotRequest => |snap| {
                snap.deinit();
            },
        }
    }

    pub fn serialize(self: Message, writer: anytype) void {
        writer.writeByte(@intFromEnum(self)) catch unreachable;
        switch (self) {
            .Alpha => |alpha| {
                alpha.serialize(writer);
            },
            .Chat => |chat| {
                chat.serialize(writer);
            },
            .Static => |static| {
                static.serialize(writer);
            },
            .Linear => |linear| {
                linear.serialize(writer);
            },
            .Accelerated => |accelerated| {
                accelerated.serialize(writer);
            },
            .Dynamic => |dynamic| {
                dynamic.serialize(writer);
            },
            .Action => |action| {
                action.serialize(writer);
            },
            .Entity => |id| {
                id.serialize(writer);
            },
            .EntityRemove => |id| {
                id.serialize(writer);
            },
            .Component => |comp| {
                comp.serialize(writer);
            },
            .ComponentRemove => |comp| {
                comp.serialize(writer);
            },
            .SnapshotRequest => |snap| {
                snap.serialize(writer);
            },
        }
    }

    pub fn deserialize(reader: anytype, allocator: *std.mem.Allocator) Message {
        const type_byte = reader.readByte() catch unreachable;
        const message_type: MessageType = @enumFromInt(type_byte);
        switch (message_type) {
            .Alpha => {
                const alpha = AlphaMessage.deserialize(reader);
                return Message{ .Alpha = alpha };
            },
            .Chat => {
                const chat = ChatMessage.deserialize(reader, allocator);
                return Message{ .Chat = chat };
            },
            .Static => {
                const pos = StaticMessage.deserialize(reader);
                return Message{ .Static = pos };
            },
            .Linear => {
                const vel = LinearMessage.deserialize(reader);
                return Message{ .Linear = vel };
            },
            .Accelerated => {
                const acc = AcceleratedMessage.deserialize(reader);
                return Message{ .Accelerated = acc };
            },
            .Dynamic => {
                const dyn = DynamicMessage.deserialize(reader);
                return Message{ .Dynamic = dyn };
            },
            .Action => {
                const act = ActionMessage.deserialize(reader);
                return Message{ .Action = act };
            },
            .Entity => {
                const id = EntityMessage.deserialize(reader);
                return Message{ .Entity = id };
            },
            .EntityRemove => {
                const id = EntityRemoveMessage.deserialize(reader);
                return Message{ .EntityRemove = id };
            },
            .Component => {
                const comp = ComponentMessage.deserialize(reader);
                return Message{ .Component = comp };
            },
            .ComponentRemove => {
                const comp = ComponentRemoveMessage.deserialize(reader);
                return Message{ .ComponentRemove = comp };
            },
            .SnapshotRequest => {
                const snap = SnapshotRequestMessage.deserialize(reader);
                return Message{ .SnapshotRequest = snap };
            },
        }
    }

    pub fn print(self: Message, writer: anytype) void {
        switch (self) {
            .Alpha => |alpha| {
                alpha.write(writer);
            },
            .Chat => |chat| {
                chat.write(writer);
            },
            .Static => |static| {
                static.write(writer);
            },
            .Linear => |linear| {
                linear.write(writer);
            },
            .Accelerated => |accelerated| {
                accelerated.write(writer);
            },
            .Dynamic => |dynamic| {
                dynamic.write(writer);
            },
            .Action => |action| {
                action.write(writer);
            },
            .Entity => |id| {
                id.write(writer);
            },
            .EntityRemove => |id| {
                id.write(writer);
            },
            .Component => |comp| {
                comp.write(writer);
            },
            .ComponentRemove => |comp| {
                comp.write(writer);
            },
            .SnapshotRequest => |snap| {
                snap.write(writer);
            },
        }
    }
};
