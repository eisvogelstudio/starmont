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

// ---------- starmont ----------
const core = @import("shared").core;
const util = @import("util");
// ------------------------------

// ---------- local ----------
const serial = @import("serial/serial.zig");
// ---------------------------

pub const Channel = enum(u8) {
    reliabel,
    unreliable,

    pub const Class = enum { reliable, unreliable };
    pub const Priority = enum { high, mid, low };

    pub fn class(self: Channel) Class {
        return switch (self) {
            .reliabel => Class.reliable,
            .unreliable => Class.unreliable,
        };
    }

    pub fn priority(self: Channel) Priority {
        return switch (self) {
            .reliabel => .high,
            .unreliable => .low,
        };
    }
};

//TODO[IMPROVE] write functions

pub const AssignMessage = struct {
    quad: u64,

    pub fn init(quad: u64) Message {
        const assign = AssignMessage{
            .quad = quad,
        };

        return Message{ .Assign = assign };
    }

    fn deinit(self: AssignMessage) void {
        _ = self;
    }

    fn wireSize(_: AssignMessage) usize {
        return serial.wireSizeU64();
    }

    fn serialize(self: AssignMessage, buffer: []u8) serial.SerializeError!void {
        try serial.serializeU64(self.quad, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!AssignMessage {
        const quad = try serial.deserializeU64(buffer[0..serial.wireSizeU64()]);
        return AssignMessage{ .quad = quad };
    }

    pub fn write(self: AssignMessage, writer: anytype) void {
        writer.print("Assign: {d}", .{self.quad}) catch unreachable;
    }
};

pub const UnassignMessage = struct {
    quad: u64,

    pub fn init(quad: u64) Message {
        const unassign = UnassignMessage{ .quad = quad };

        return Message{ .Unassign = unassign };
    }

    fn deinit(self: UnassignMessage) void {
        _ = self;
    }

    fn wireSize(_: UnassignMessage) usize {
        return serial.wireSizeU64();
    }

    fn serialize(self: UnassignMessage, buffer: []u8) serial.SerializeError!void {
        try serial.serializeU64(self.quad, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!UnassignMessage {
        const quad = try serial.deserializeU64(buffer[0..serial.wireSizeU64()]);
        return UnassignMessage{ .quad = quad };
    }

    pub fn write(self: UnassignMessage, writer: anytype) void {
        writer.print("Unassign: {d}", .{self.quad}) catch unreachable;
    }
};

pub const NeighbourMessage = struct {
    quad: u64,
    //TODO[MISSING]

    pub fn init(quad: u64) Message {
        const neighbour = NeighbourMessage{ .quad = quad };

        return Message{ .Neighbour = neighbour };
    }

    fn deinit(self: NeighbourMessage) void {
        _ = self;
    }

    fn wireSize(_: NeighbourMessage) usize {
        return serial.wireSizeU64();
    }

    fn serialize(self: NeighbourMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeU64(self.quad, buffer[0..8]);
    }

    fn deserialize(buffer: []const u8, gpa: std.mem.Allocator) serial.Error!NeighbourMessage {
        _ = gpa;

        if (buffer.len < serial.wireSizeU64()) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeU64(buffer[0..8]);

        return NeighbourMessage{ .quad = id };
    }

    pub fn write(self: NeighbourMessage, writer: anytype) void {
        writer.print("Neighbour: {d}", .{self.quad}) catch unreachable;
    }
};

pub const MasterInfoMessage = struct {
    pub fn init() Message {
        const info = MasterInfoMessage{};
        return Message{ .MasterInfo = info };
    }

    fn deinit(self: MasterInfoMessage) void {
        _ = self;
    }

    fn wireSize(_: MasterInfoMessage) usize {
        return 0;
    }

    fn serialize(self: MasterInfoMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!MasterInfoMessage {
        _ = buffer;
        return MasterInfoMessage{};
    }

    pub fn write(self: MasterInfoMessage, writer: anytype) void {
        _ = self;
        writer.print("MasterInfo", .{}) catch unreachable;
    }
};

pub const MasterDebugMessage = struct {
    pub fn init() Message {
        const debug = MasterDebugMessage{};

        return Message{ .MasterDebug = debug };
    }

    fn deinit(self: MasterDebugMessage) void {
        _ = self;
    }

    fn wireSize(_: MasterDebugMessage) usize {
        return 0;
    }

    fn serialize(self: MasterDebugMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!MasterDebugMessage {
        _ = buffer;
        return MasterDebugMessage{};
    }

    pub fn write(self: MasterDebugMessage, writer: anytype) void {
        _ = self;
        writer.print("MasterDebug", .{}) catch unreachable;
    }
};

pub const RegisterMessage = struct {
    pub fn init() Message {
        const register = RegisterMessage{};

        return Message{ .Register = register };
    }

    fn deinit(self: RegisterMessage) void {
        _ = self;
    }

    fn wireSize(_: RegisterMessage) usize {
        return 0;
    }

    fn serialize(self: RegisterMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!RegisterMessage {
        _ = buffer;
        return RegisterMessage{};
    }

    pub fn write(self: RegisterMessage, writer: anytype) void {
        _ = self;
        writer.print("Register", .{}) catch unreachable;
    }
};

pub const UnregisterMessage = struct {
    pub fn init() Message {
        const unregister = UnregisterMessage{};

        return Message{ .Unregister = unregister };
    }

    fn deinit(self: UnregisterMessage) void {
        _ = self;
    }

    fn wireSize(_: UnregisterMessage) usize {
        return 0;
    }

    fn serialize(self: UnregisterMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!UnregisterMessage {
        _ = buffer;
        return UnregisterMessage{};
    }

    pub fn write(self: UnregisterMessage, writer: anytype) void {
        _ = self;
        writer.print("Unregister", .{}) catch unreachable;
    }
};

pub const HeartbeatMessage = struct {
    load: f32,

    pub fn init(load: f32) Message {
        const beat = HeartbeatMessage{ .load = load };

        return Message{ .Heartbeat = beat };
    }

    fn deinit(self: HeartbeatMessage) void {
        _ = self;
    }

    fn wireSize(_: HeartbeatMessage) usize {
        return serial.wireSizeF32();
    }

    fn serialize(self: HeartbeatMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeF32(self.load, buffer[0..serial.wireSizeF32()]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!HeartbeatMessage {
        if (buffer.len < serial.wireSizeF32()) return serial.DeserializeError.Truncated;
        const load = try serial.deserializeF32(buffer[0..serial.wireSizeF32()]);
        return HeartbeatMessage{ .load = load };
    }

    pub fn write(self: HeartbeatMessage, writer: anytype) void {
        writer.print("Heartbeat: {d}", .{self.load}) catch unreachable;
    }
};

pub const QuadInfoMessage = struct {
    quad: u64,
    pressure: f32,

    pub fn init(quad: u64, pressure: f32) Message {
        const msg = QuadInfoMessage{ .quad = quad, .pressure = pressure };
        return Message{ .QuadInfo = msg };
    }

    fn deinit(self: QuadInfoMessage) void {
        _ = self;
    }

    fn wireSize(_: QuadInfoMessage) usize {
        return serial.wireSizeU64() + serial.wireSizeF32();
    }

    fn serialize(self: QuadInfoMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const q = serial.wireSizeU64();
        try serial.serializeU64(self.quad, buffer[offset .. offset + q]);
        offset += q;
        const p = serial.wireSizeF32();
        try serial.serializeF32(self.pressure, buffer[offset .. offset + p]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!QuadInfoMessage {
        var offset: usize = 0;
        const q = serial.wireSizeU64();
        if (buffer.len < offset + q) return serial.DeserializeError.Truncated;
        const quad = try serial.deserializeU64(buffer[offset .. offset + q]);
        offset += q;
        const p = serial.wireSizeF32();
        if (buffer.len < offset + p) return serial.DeserializeError.Truncated;
        const pressure = try serial.deserializeF32(buffer[offset .. offset + p]);
        return QuadInfoMessage{ .quad = quad, .pressure = pressure };
    }

    pub fn write(self: QuadInfoMessage, writer: anytype) void {
        writer.print("QuadInfo: quad={d} pressure={d}", .{ self.quad, self.pressure }) catch unreachable;
    }
};

pub const EntityHandoverMessage = struct {
    id: core.Id,

    pub fn init(entity_id: core.Id) Message {
        const msg = EntityHandoverMessage{
            .id = entity_id,
        };

        return Message{ .EntityHandover = msg };
    }

    fn deinit(self: EntityHandoverMessage) void {
        _ = self;
    }

    fn wireSize(_: EntityHandoverMessage) usize {
        return serial.wireSizeId();
    }

    fn serialize(self: EntityHandoverMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeId(self.id, buffer[0..serial.wireSizeId()]);
    }

    fn deserialize(buffer: []const u8) !EntityHandoverMessage {
        if (buffer.len < serial.wireSizeId()) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[0..serial.wireSizeId()]);
        return EntityHandoverMessage{ .id = id };
    }

    pub fn write(self: EntityHandoverMessage, writer: anytype) void {
        writer.print("EntityHandover: ", .{}) catch unreachable;
        util.format.writeId(writer, self.id);
    }
};

pub const EntityClaimMessage = struct {
    id: core.Id,

    pub fn init(id: util.UUID4) Message {
        const msg = EntityClaimMessage{
            .id = id,
        };

        return Message{ .EntityClaim = msg };
    }

    fn deinit(self: EntityClaimMessage) void {
        _ = self;
    }

    fn wireSize(_: EntityClaimMessage) usize {
        return serial.wireSizeId();
    }

    fn serialize(self: EntityClaimMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeId(self.id, buffer[0..serial.wireSizeId()]);
    }

    fn deserialize(buffer: []const u8) !EntityClaimMessage {
        if (buffer.len < serial.wireSizeId()) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[0..serial.wireSizeId()]);
        return EntityClaimMessage{ .id = id };
    }

    pub fn write(self: EntityClaimMessage, writer: anytype) void {
        writer.print("EntityClaim: {s}", .{self.id.toString()}) catch unreachable;
    }
};

pub const EntityFailoverMessage = struct {
    id: core.Id,

    pub fn init(entity_id: util.UUID4) Message {
        const msg = EntityFailoverMessage{
            .id = entity_id,
        };
        return Message{ .EntityFailover = msg };
    }

    fn deinit(self: EntityFailoverMessage) void {
        _ = self;
    }

    fn wireSize(_: EntityFailoverMessage) usize {
        return serial.wireSizeId();
    }

    fn serialize(self: EntityFailoverMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeId(self.id, buffer[0..serial.wireSizeId()]);
    }

    fn deserialize(buffer: []const u8) !EntityFailoverMessage {
        if (buffer.len < serial.wireSizeId()) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[0..serial.wireSizeId()]);
        return EntityFailoverMessage{ .id = id };
    }

    pub fn write(self: EntityFailoverMessage, writer: anytype) void {
        writer.print("EntityFailover: {s}", .{self.id.toString()}) catch unreachable;
    }
};

pub const ServerInfoMessage = struct {
    pub fn init() Message {
        const info = ServerInfoMessage{};
        return Message{ .ServerInfo = info };
    }

    fn deinit(self: ServerInfoMessage) void {
        _ = self;
    }

    fn wireSize(_: ServerInfoMessage) usize {
        return 0;
    }

    fn serialize(self: ServerInfoMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!ServerInfoMessage {
        _ = buffer;
        return ServerInfoMessage{};
    }

    pub fn write(self: ServerInfoMessage, writer: anytype) void {
        _ = self;
        writer.print("ServerInfo", .{}) catch unreachable;
    }
};

pub const ServerDebugMessage = struct {
    pub fn init() Message {
        const info = ServerDebugMessage{};
        return Message{ .ServerDebug = info };
    }

    fn deinit(self: ServerDebugMessage) void {
        _ = self;
    }

    fn wireSize(_: ServerDebugMessage) usize {
        return 0;
    }

    fn serialize(self: ServerDebugMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!ServerDebugMessage {
        _ = buffer;
        return ServerDebugMessage{};
    }

    pub fn write(self: ServerDebugMessage, writer: anytype) void {
        _ = self;
        writer.print("ServerDebug", .{}) catch unreachable;
    }
};

pub const ClientInfoMessage = struct {
    pub fn init() Message {
        const info = ClientInfoMessage{};
        return Message{ .ClientInfo = info };
    }

    fn deinit(self: ClientInfoMessage) void {
        _ = self;
    }

    fn wireSize(_: ClientInfoMessage) usize {
        return 0;
    }

    fn serialize(self: ClientInfoMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!ClientInfoMessage {
        _ = buffer;
        return ClientInfoMessage{};
    }

    pub fn write(self: ClientInfoMessage, writer: anytype) void {
        _ = self;
        writer.print("ClientInfo", .{}) catch unreachable;
    }
};

pub const EditorInfoMessage = struct {
    pub fn init() Message {
        const info = EditorInfoMessage{};
        return Message{ .EditorInfo = info };
    }

    fn deinit(self: EditorInfoMessage) void {
        _ = self;
    }

    fn wireSize(_: EditorInfoMessage) usize {
        return 0;
    }

    fn serialize(self: EditorInfoMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!EditorInfoMessage {
        _ = buffer;
        return EditorInfoMessage{};
    }
    pub fn write(self: EditorInfoMessage, writer: anytype) void {
        _ = self;
        writer.print("EditorInfo", .{}) catch unreachable;
    }
};

pub const CommandMessage = struct {
    command: []const u8,

    pub fn init(command: []const u8) Message {
        const cmd = CommandMessage{ .command = command };
        return Message{ .Command = cmd };
    }

    fn deinit(self: CommandMessage) void {
        _ = self;
    }

    fn wireSize(self: CommandMessage) usize {
        return serial.wireSizeText(self.command);
    }

    fn serialize(self: CommandMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeText(self.command, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8, gpa: std.mem.Allocator) !CommandMessage {
        const cmd = try serial.deserializeText(buffer, gpa);
        return CommandMessage{ .command = cmd };
    }

    pub fn write(self: CommandMessage, writer: anytype) void {
        writer.print("Command: {s}", .{self.command}) catch unreachable;
    }
};

pub const NoticeMessage = struct {
    gpa: *std.mem.Allocator,
    duration: i64,
    message: []const u8,

    pub fn init(gpa: *std.mem.Allocator, duration: i64, message: []const u8) Message {
        const dup_message = gpa.dupe(u8, message) catch unreachable;

        const note = NoticeMessage{
            .gpa = gpa,
            .duration = duration,
            .message = dup_message,
        };

        return Message{ .Notice = note };
    }

    fn deinit(self: NoticeMessage) void {
        self.gpa.free(self.message);
    }

    fn wireSize(self: NoticeMessage) usize {
        return serial.wireSizeI64() + serial.wireSizeText(self.message);
    }

    fn serialize(self: NoticeMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const d_sz = serial.wireSizeI64();
        try serial.serializeI64(self.duration, buffer[offset .. offset + d_sz]);
        offset += d_sz;
        const m_sz = serial.wireSizeText(self.message);
        try serial.serializeText(self.message, buffer[offset .. offset + m_sz]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !NoticeMessage {
        var offset: usize = 0;
        const d_sz = serial.wireSizeI64();
        if (buffer.len < offset + d_sz) return serial.DeserializeError.Truncated;
        const duration = try serial.deserializeI64(buffer[offset .. offset + d_sz]);
        offset += d_sz;
        const message = try serial.deserializeText(buffer[offset..], gpa.*);
        return NoticeMessage{ .gpa = gpa, .duration = duration, .message = message };
    }

    pub fn write(self: NoticeMessage, writer: anytype) void {
        writer.print("Notice: duration={d} message={s}", .{ self.duration, self.message }) catch unreachable;
    }
};

pub const ForwardMessage = struct {
    gpa: *std.mem.Allocator,
    server_id: util.UUID4,
    ip: []const u8,
    port: u16,

    pub fn init(gpa: *std.mem.Allocator, server_id: util.UUID4, ip: []const u8, port: u16) Message {
        const forward = ForwardMessage{
            .gpa = gpa,
            .server_id = server_id,
            .ip = ip,
            .port = port,
        };

        return Message{ .Forward = forward };
    }

    fn deinit(self: ForwardMessage) void {
        self.gpa.free(self.ip);
    }

    fn wireSize(self: ForwardMessage) usize {
        return serial.wireSizeUUID4() + serial.wireSizeText(self.ip) + serial.wireSizeU16();
    }

    fn serialize(self: ForwardMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const id_sz = serial.wireSizeUUID4();
        try serial.serializeUUID4(self.server_id, buffer[offset .. offset + id_sz]);
        offset += id_sz;
        const ip_sz = serial.wireSizeText(self.ip);
        try serial.serializeText(self.ip, buffer[offset .. offset + ip_sz]);
        offset += ip_sz;
        const p_sz = serial.wireSizeU16();
        try serial.serializeU16(self.port, buffer[offset .. offset + p_sz]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !ForwardMessage {
        var offset: usize = 0;
        const id_sz = serial.wireSizeUUID4();
        if (buffer.len < offset + id_sz) return serial.DeserializeError.Truncated;
        const server_id = try serial.deserializeUUID4(buffer[offset .. offset + id_sz]);
        offset += id_sz;
        const ip = try serial.deserializeText(buffer[offset..], gpa.*);
        offset += serial.wireSizeText(ip);
        const p_sz = serial.wireSizeU16();
        if (buffer.len < offset + p_sz) return serial.DeserializeError.Truncated;
        const port = try serial.deserializeU16(buffer[offset .. offset + p_sz]);
        return ForwardMessage{ .gpa = gpa, .server_id = server_id, .ip = ip, .port = port };
    }

    pub fn write(self: ForwardMessage, writer: anytype) void {
        writer.print(
            "Forward: server={s} ip={s} port={d}",
            .{ self.id.toString(), self.ip, self.port },
        ) catch unreachable;
    }
};

pub const AlphaMessage = struct {
    gpa: *std.mem.Allocator,
    ephemeral: util.UUID4,
    name: []const u8,

    pub fn init(gpa: *std.mem.Allocator, ephemeral: util.UUID4, name: []const u8) Message {
        const alpha = AlphaMessage{
            .gpa = gpa,
            .ephemeral = ephemeral,
            .name = name,
        };

        return Message{ .Alpha = alpha };
    }

    fn deinit(self: AlphaMessage) void {
        self.gpa.free(self.name);
    }

    fn wireSize(self: AlphaMessage) usize {
        return serial.wireSizeUUID4() + serial.wireSizeText(self.name);
    }

    fn serialize(self: AlphaMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const eph_size = serial.wireSizeUUID4();
        try serial.serializeUUID4(self.ephemeral, buffer[offset .. offset + eph_size]);
        offset += eph_size;
        const name_size = serial.wireSizeText(self.name);
        try serial.serializeText(self.name, buffer[offset .. offset + name_size]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !AlphaMessage {
        var offset: usize = 0;
        const eph_size = serial.wireSizeUUID4();
        if (buffer.len < offset + eph_size) return serial.DeserializeError.Truncated;
        const ephemeral = try serial.deserializeUUID4(buffer[offset .. offset + eph_size]);
        offset += eph_size;
        const name = try serial.deserializeText(buffer[offset..], gpa.*);
        return AlphaMessage{ .gpa = gpa, .ephemeral = ephemeral, .name = name };
    }

    pub fn write(self: AlphaMessage, writer: anytype) void {
        writer.print("Alpha: id={s} name={s}", .{ self.id.toString(), self.name }) catch unreachable;
    }
};

pub const OmegaMessage = struct {
    gpa: *std.mem.Allocator,
    message: []const u8,

    pub fn init(gpa: *std.mem.Allocator, message: []const u8) Message {
        const omega = OmegaMessage{
            .gpa = gpa,
            .message = message,
        };

        return Message{ .Omega = omega };
    }

    fn deinit(self: OmegaMessage) void {
        self.gpa.free(self.message);
    }

    fn wireSize(self: OmegaMessage) usize {
        return serial.wireSizeText(self.message);
    }

    fn serialize(self: OmegaMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeText(self.message, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !OmegaMessage {
        const msg = try serial.deserializeText(buffer, gpa.*);
        return OmegaMessage{ .gpa = gpa, .message = msg };
    }

    pub fn write(self: OmegaMessage, writer: anytype) void {
        writer.print("Omega: {s}", .{self.message}) catch unreachable;
    }
};

pub const KickMessage = struct {
    gpa: *std.mem.Allocator,
    duration: i64,
    message: []const u8,

    pub fn init(gpa: *std.mem.Allocator, duration: i64, message: []const u8) Message {
        const dup_message = gpa.dupe(u8, message) catch unreachable;

        const kick = KickMessage{
            .gpa = gpa,
            .duration = duration,
            .message = dup_message,
        };

        return Message{ .Kick = kick };
    }

    fn deinit(self: KickMessage) void {
        self.gpa.free(self.message);
    }

    fn wireSize(self: KickMessage) usize {
        return serial.wireSizeI64() + serial.wireSizeText(self.message);
    }

    fn serialize(self: KickMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const dur_size = serial.wireSizeI64();
        try serial.serializeI64(self.duration, buffer[offset .. offset + dur_size]);
        offset += dur_size;
        const msg_size = serial.wireSizeText(self.message);
        try serial.serializeText(self.message, buffer[offset .. offset + msg_size]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !KickMessage {
        var offset: usize = 0;
        const dur_size = serial.wireSizeI64();
        if (buffer.len < offset + dur_size) return serial.DeserializeError.Truncated;
        const duration = try serial.deserializeI64(buffer[offset .. offset + dur_size]);
        offset += dur_size;
        const msg = try serial.deserializeText(buffer[offset..], gpa.*);
        return KickMessage{ .gpa = gpa, .duration = duration, .message = msg };
    }

    pub fn write(self: KickMessage, writer: anytype) void {
        writer.print(
            "Kick: duration={d} message={s}",
            .{ self.duration, self.message },
        ) catch unreachable;
    }
};

pub const PingMessage = struct {
    nonce: u64,
    time: i64,

    pub fn init(nonce: u64, time: i64) Message {
        const ping = PingMessage{
            .nonce = nonce,
            .time = time,
        };

        return Message{ .Ping = ping };
    }

    fn deinit(self: PingMessage) void {
        _ = self;
    }

    fn wireSize(_: PingMessage) usize {
        return serial.wireSizeU64() + serial.wireSizeI64();
    }

    fn serialize(self: PingMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const nonce_size = serial.wireSizeU64();
        try serial.serializeU64(self.nonce, buffer[offset .. offset + nonce_size]);
        offset += nonce_size;
        const time_size = serial.wireSizeI64();
        try serial.serializeI64(self.time, buffer[offset .. offset + time_size]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!PingMessage {
        var offset: usize = 0;
        const nonce_size = serial.wireSizeU64();
        if (buffer.len < offset + nonce_size) return serial.DeserializeError.Truncated;
        const nonce = try serial.deserializeU64(buffer[offset .. offset + nonce_size]);
        offset += nonce_size;
        const time_size = serial.wireSizeI64();
        if (buffer.len < offset + time_size) return serial.DeserializeError.Truncated;
        const time = try serial.deserializeI64(buffer[offset .. offset + time_size]);
        return PingMessage{ .nonce = nonce, .time = time };
    }

    pub fn write(self: PingMessage, writer: anytype) void {
        writer.print("Ping: nonce={d} time={d}", .{ self.nonce, self.time }) catch unreachable;
    }
};

pub const PongMessage = struct {
    nonce: u64,
    time: i64,

    pub fn init(nonce: u64, time: i64) Message {
        const pong = PongMessage{
            .nonce = nonce,
            .time = time,
        };

        return Message{ .Pong = pong };
    }

    fn deinit(self: PongMessage) void {
        _ = self;
    }

    fn wireSize(_: PongMessage) usize {
        return serial.wireSizeU64() + serial.wireSizeI64();
    }

    fn serialize(self: PongMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const nonce_size = serial.wireSizeU64();
        try serial.serializeU64(self.nonce, buffer[offset .. offset + nonce_size]);
        offset += nonce_size;
        const time_size = serial.wireSizeI64();
        try serial.serializeI64(self.time, buffer[offset .. offset + time_size]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!PongMessage {
        var offset: usize = 0;
        const nonce_size = serial.wireSizeU64();
        if (buffer.len < offset + nonce_size) return serial.DeserializeError.Truncated;
        const nonce = try serial.deserializeU64(buffer[offset .. offset + nonce_size]);
        offset += nonce_size;
        const time_size = serial.wireSizeI64();
        if (buffer.len < offset + time_size) return serial.DeserializeError.Truncated;
        const time = try serial.deserializeI64(buffer[offset .. offset + time_size]);
        return PongMessage{ .nonce = nonce, .time = time };
    }

    pub fn write(self: PongMessage, writer: anytype) void {
        writer.print("Pong: nonce={d} time={d}", .{ self.nonce, self.time }) catch unreachable;
    }
};

pub const VersionCheckMessage = struct {
    gpa: *std.mem.Allocator,
    version: []const u8,

    pub fn init(gpa: *std.mem.Allocator, version: []const u8) Message {
        const dup_version = gpa.dupe(u8, version) catch unreachable;

        const vers = VersionCheckMessage{
            .gpa = gpa,
            .version = dup_version,
        };

        return Message{ .VersionCheck = vers };
    }

    fn deinit(self: VersionCheckMessage) void {
        self.gpa.free(self.version);
    }

    fn wireSize(self: VersionCheckMessage) usize {
        return serial.wireSizeText(self.version);
    }

    fn serialize(self: VersionCheckMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeText(self.version, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !VersionCheckMessage {
        const version = try serial.deserializeText(buffer, gpa.*);
        return VersionCheckMessage{ .gpa = gpa, .version = version };
    }

    pub fn write(self: VersionCheckMessage, writer: anytype) void {
        writer.print("VersionCheck: {s}", .{self.version}) catch unreachable;
    }
};

pub const VersionResultMessage = struct {
    gpa: *std.mem.Allocator,
    is_match: bool,
    version: []const u8,
    message: []const u8,

    pub fn init(gpa: *std.mem.Allocator, is_match: bool, version: []const u8, message: []const u8) Message {
        const dup_version = gpa.dupe(u8, version) catch unreachable;
        const dup_message = gpa.dupe(u8, message) catch unreachable;

        const vers = VersionResultMessage{
            .gpa = gpa,
            .is_match = is_match,
            .version = dup_version,
            .message = dup_message,
        };

        return Message{ .VersionResult = vers };
    }

    fn deinit(self: VersionResultMessage) void {
        self.gpa.free(self.version);
        self.gpa.free(self.message);
    }

    fn wireSize(self: VersionResultMessage) usize {
        return serial.wireSizeBool() + serial.wireSizeText(self.version) + serial.wireSizeText(self.message);
    }

    fn serialize(self: VersionResultMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const bool_size = serial.wireSizeBool();
        try serial.serializeBool(self.is_match, buffer[offset .. offset + bool_size]);
        offset += bool_size;
        const ver_size = serial.wireSizeText(self.version);
        try serial.serializeText(self.version, buffer[offset .. offset + ver_size]);
        offset += ver_size;
        const msg_size = serial.wireSizeText(self.message);
        try serial.serializeText(self.message, buffer[offset .. offset + msg_size]);
    }

    fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !VersionResultMessage {
        var offset: usize = 0;
        const bool_size = serial.wireSizeBool();
        if (buffer.len < offset + bool_size) return serial.DeserializeError.Truncated;
        const is_match = try serial.deserializeBool(buffer[offset .. offset + bool_size]);
        offset += bool_size;
        const version = try serial.deserializeText(buffer[offset..], gpa.*);
        offset += version.len;
        const message = try serial.deserializeText(buffer[offset..], gpa.*);
        return VersionResultMessage{ .gpa = gpa, .is_match = is_match, .version = version, .message = message };
    }

    pub fn write(self: VersionResultMessage, writer: anytype) void {
        writer.print(
            "VersionResult: match={b} version={s} message={s}",
            .{ self.is_match, self.version, self.message },
        ) catch unreachable;
    }
};

pub const AuthChallengeMessage = struct {
    auth_id: u64,
    //TODO

    pub fn init(auth_id: u64) Message {
        const auth = AuthChallengeMessage{
            .auth_id = auth_id,
        };

        return Message{ .AuthChallenge = auth };
    }

    fn deinit(self: AuthChallengeMessage) void {
        _ = self;
    }

    fn wireSize(_: AuthChallengeMessage) usize {
        return serial.wireSizeU64();
    }

    fn serialize(self: AuthChallengeMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeU64(self.auth_id, buffer[0..serial.wireSizeU64()]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!AuthChallengeMessage {
        if (buffer.len < serial.wireSizeU64()) return serial.DeserializeError.Truncated;
        const auth_id = try serial.deserializeU64(buffer[0..serial.wireSizeU64()]);
        return AuthChallengeMessage{ .auth_id = auth_id };
    }

    pub fn write(self: AuthChallengeMessage, writer: anytype) void {
        writer.print("AuthChallenge: id={d}", .{self.auth_id}) catch unreachable;
    }
};

pub const AuthResultMessage = struct {
    auth_id: u64,
    //TODO

    pub fn init(auth_id: u64) Message {
        const auth = AuthResultMessage{
            .auth_id = auth_id,
        };

        return Message{ .AuthResult = auth };
    }

    fn deinit(self: AuthResultMessage) void {
        _ = self;
    }

    fn wireSize(_: AuthResultMessage) usize {
        return serial.wireSizeU64();
    }

    fn serialize(self: AuthResultMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeU64(self.auth_id, buffer[0..serial.wireSizeU64()]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!AuthResultMessage {
        if (buffer.len < serial.wireSizeU64()) return serial.DeserializeError.Truncated;
        const auth_id = try serial.deserializeU64(buffer[0..serial.wireSizeU64()]);
        return AuthResultMessage{ .auth_id = auth_id };
    }

    pub fn write(self: AuthResultMessage, writer: anytype) void {
        writer.print("AuthResult: id={d}", .{self.auth_id}) catch unreachable;
    }
};

pub const AuthResponseMessage = struct {
    auth_id: u64,
    is_success: bool,

    pub fn init(auth_id: u64, is_success: bool) Message {
        const auth = AuthResponseMessage{
            .auth_id = auth_id,
            .is_success = is_success,
        };

        return Message{ .AuthResponse = auth };
    }

    fn deinit(self: AuthResponseMessage) void {
        _ = self;
    }

    fn wireSize(_: AuthResponseMessage) usize {
        return serial.wireSizeU64() + serial.wireSizeBool();
    }

    fn serialize(self: AuthResponseMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const id_size = serial.wireSizeU64();
        try serial.serializeU64(self.auth_id, buffer[offset .. offset + id_size]);
        offset += id_size;
        const bool_size = serial.wireSizeBool();
        try serial.serializeBool(self.is_success, buffer[offset .. offset + bool_size]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!AuthResponseMessage {
        var offset: usize = 0;
        const id_size = serial.wireSizeU64();
        if (buffer.len < offset + id_size) return serial.DeserializeError.Truncated;
        const auth_id = try serial.deserializeU64(buffer[offset .. offset + id_size]);
        offset += id_size;
        const bool_size = serial.wireSizeBool();
        if (buffer.len < offset + bool_size) return serial.DeserializeError.Truncated;
        const is_success = try serial.deserializeBool(buffer[offset .. offset + bool_size]);
        return AuthResponseMessage{ .auth_id = auth_id, .is_success = is_success };
    }

    pub fn write(self: AuthResponseMessage, writer: anytype) void {
        writer.print(
            "AuthResponse: id={d} success={b}",
            .{ self.auth_id, self.is_success },
        ) catch unreachable;
    }
};

pub const TickMessage = struct {
    tick: u64,
    time: i64,

    pub fn init(tick: u64, time: i64) Message {
        const tickmsg = TickMessage{
            .tick = tick,
            .time = time,
        };

        return Message{ .Tick = tickmsg };
    }

    fn deinit(self: TickMessage) void {
        _ = self;
    }

    fn wireSize(_: TickMessage) usize {
        return serial.wireSizeU64() + serial.wireSizeI64();
    }

    fn serialize(self: TickMessage, buffer: []u8) serial.SerializeError!void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const tick_size = serial.wireSizeU64();
        try serial.serializeU64(self.tick, buffer[offset .. offset + tick_size]);
        offset += tick_size;
        const time_size = serial.wireSizeI64();
        try serial.serializeI64(self.time, buffer[offset .. offset + time_size]);
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!TickMessage {
        var offset: usize = 0;
        const tick_size = serial.wireSizeU64();
        if (buffer.len < offset + tick_size) return serial.DeserializeError.Truncated;
        const tick = try serial.deserializeU64(buffer[offset .. offset + tick_size]);
        offset += tick_size;
        const time_size = serial.wireSizeI64();
        if (buffer.len < offset + time_size) return serial.DeserializeError.Truncated;
        const time = try serial.deserializeI64(buffer[offset .. offset + time_size]);
        return TickMessage{ .tick = tick, .time = time };
    }
    pub fn write(self: TickMessage, writer: anytype) void {
        writer.print("Tick: {d} time={d}", .{ self.tick, self.time }) catch unreachable;
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

    fn wireSize(_: StaticMessage) usize {
        return serial.wireSizePosition();
    }

    fn serialize(self: StaticMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializePosition(self.position, buffer[0..serial.wireSizePosition()]);
    }

    fn deserialize(buffer: []const u8) !StaticMessage {
        if (buffer.len < serial.wireSizePosition()) return serial.DeserializeError.Truncated;
        const pos = try serial.deserializePosition(buffer[0..serial.wireSizePosition()]);
        return StaticMessage{ .position = pos };
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

    fn wireSize(_: LinearMessage) usize {
        return serial.wireSizePosition() + serial.wireSizeVelocity();
    }

    fn serialize(self: LinearMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const pos_size = serial.wireSizePosition();
        try serial.serializePosition(self.position, buffer[offset .. offset + pos_size]);
        offset += pos_size;
        const vel_size = serial.wireSizeVelocity();
        try serial.serializeVelocity(self.velocity, buffer[offset .. offset + vel_size]);
    }

    fn deserialize(buffer: []const u8) !LinearMessage {
        var offset: usize = 0;
        const pos_size = serial.wireSizePosition();
        if (buffer.len < offset + pos_size) return serial.DeserializeError.Truncated;
        const pos = try serial.deserializePosition(buffer[offset .. offset + pos_size]);
        offset += pos_size;
        const vel_size = serial.wireSizeVelocity();
        if (buffer.len < offset + vel_size) return serial.DeserializeError.Truncated;
        const vel = try serial.deserializeVelocity(buffer[offset .. offset + vel_size]);
        return LinearMessage{ .position = pos, .velocity = vel };
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

    fn wireSize(_: AcceleratedMessage) usize {
        return serial.wireSizePosition() + serial.wireSizeVelocity() + serial.wireSizeAcceleration();
    }

    fn serialize(self: AcceleratedMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;

        var offset: usize = 0;

        const pos_size = serial.wireSizePosition();
        try serial.serializePosition(self.position, buffer[offset .. offset + pos_size]);
        offset += pos_size;

        const vel_size = serial.wireSizeVelocity();
        try serial.serializeVelocity(self.velocity, buffer[offset .. offset + vel_size]);
        offset += vel_size;

        const acc_size = serial.wireSizeAcceleration();
        try serial.serializeAcceleration(self.acceleration, buffer[offset .. offset + acc_size]);
    }

    fn deserialize(buffer: []const u8) !AcceleratedMessage {
        var offset: usize = 0;

        const pos_size = serial.wireSizePosition();
        if (buffer.len < offset + pos_size) return serial.DeserializeError.Truncated;
        const pos = try serial.deserializePosition(buffer[offset .. offset + pos_size]);
        offset += pos_size;

        const vel_size = serial.wireSizeVelocity();
        if (buffer.len < offset + vel_size) return serial.DeserializeError.Truncated;
        const vel = try serial.deserializeVelocity(buffer[offset .. offset + vel_size]);
        offset += vel_size;

        const acc_size = serial.wireSizeAcceleration();
        if (buffer.len < offset + acc_size) return serial.DeserializeError.Truncated;
        const acc = try serial.deserializeAcceleration(buffer[offset .. offset + acc_size]);

        return AcceleratedMessage{
            .position = pos,
            .velocity = vel,
            .acceleration = acc,
        };
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

    fn wireSize(_: DynamicMessage) usize {
        return serial.wireSizePosition() + serial.wireSizeVelocity() + serial.wireSizeAcceleration() + serial.wireSizeJerk();
    }

    fn serialize(self: DynamicMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize())
            return serial.SerializeError.BufferTooSmall;

        var offset: usize = 0;

        const pos_size = serial.wireSizePosition();
        try serial.serializePosition(self.position, buffer[offset .. offset + pos_size]);
        offset += pos_size;

        const vel_size = serial.wireSizeVelocity();
        try serial.serializeVelocity(self.velocity, buffer[offset .. offset + vel_size]);
        offset += vel_size;

        const acc_size = serial.wireSizeAcceleration();
        try serial.serializeAcceleration(self.acceleration, buffer[offset .. offset + acc_size]);
        offset += acc_size;

        const jerk_size = serial.wireSizeJerk();
        try serial.serializeJerk(self.jerk, buffer[offset .. offset + jerk_size]);
    }

    fn deserialize(buffer: []const u8) !DynamicMessage {
        var offset: usize = 0;

        const pos_size = serial.wireSizePosition();
        if (buffer.len < offset + pos_size) return serial.DeserializeError.Truncated;
        const pos = try serial.deserializePosition(buffer[offset .. offset + pos_size]);
        offset += pos_size;

        const vel_size = serial.wireSizeVelocity();
        if (buffer.len < offset + vel_size) return serial.DeserializeError.Truncated;
        const vel = try serial.deserializeVelocity(buffer[offset .. offset + vel_size]);
        offset += vel_size;

        const acc_size = serial.wireSizeAcceleration();
        if (buffer.len < offset + acc_size) return serial.DeserializeError.Truncated;
        const acc = try serial.deserializeAcceleration(buffer[offset .. offset + acc_size]);
        offset += acc_size;

        const jerk_size = serial.wireSizeJerk();
        if (buffer.len < offset + jerk_size) return serial.DeserializeError.Truncated;
        const jerk = try serial.deserializeJerk(buffer[offset .. offset + jerk_size]);

        return DynamicMessage{
            .position = pos,
            .velocity = vel,
            .acceleration = acc,
            .jerk = jerk,
        };
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
    id: core.Id,
    action: core.Action,

    pub fn init(id: core.Id, action: core.Action) Message {
        const msg = ActionMessage{
            .id = id,
            .action = action,
        };

        return Message{ .Action = msg };
    }

    fn deinit(self: ActionMessage) void {
        _ = self;
    }

    fn wireSize(_: ActionMessage) usize {
        return serial.wireSizeId() + serial.wireSizeEnum(core.Action);
    }

    fn serialize(self: ActionMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;

        var offset: usize = 0;

        const id_size = serial.wireSizeId();
        try serial.serializeId(self.id, buffer[offset .. offset + id_size]);
        offset += id_size;

        const action_size = serial.wireSizeEnum(core.Action);
        try serial.serializeEnum(core.Action, self.action, buffer[offset .. offset + action_size]);
    }

    fn deserialize(buffer: []const u8) !ActionMessage {
        var offset: usize = 0;

        const id_size = serial.wireSizeId();
        if (buffer.len < offset + id_size) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[offset .. offset + id_size]);
        offset += id_size;

        const action_size = serial.wireSizeEnum(core.Action);
        if (buffer.len < offset + action_size) return serial.DeserializeError.Truncated;
        const action = try serial.deserializeEnum(core.Action, buffer[offset .. offset + action_size]);

        return ActionMessage{ .id = id, .action = action };
    }

    pub fn write(self: ActionMessage, writer: anytype) void {
        writer.print("Action: ", .{}) catch unreachable;
        util.format.writeId(writer, self.id);
        writer.print(" {s}", .{@tagName(self.action)}) catch unreachable;
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

    fn wireSize(_: EntityMessage) usize {
        return serial.wireSizeId();
    }

    fn serialize(self: EntityMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeId(self.id, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8) !EntityMessage {
        if (buffer.len < serial.wireSizeId()) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[0..serial.wireSizeId()]);
        return EntityMessage{ .id = id };
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

    fn wireSize(_: EntityRemoveMessage) usize {
        return serial.wireSizeId();
    }

    fn serialize(self: EntityRemoveMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        try serial.serializeId(self.id, buffer[0..self.wireSize()]);
    }

    fn deserialize(buffer: []const u8) !EntityRemoveMessage {
        if (buffer.len < serial.wireSizeId()) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[0..serial.wireSizeId()]);
        return EntityRemoveMessage{ .id = id };
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
        Rotation: core.Rotation,
        AngularVelocity: core.AngularVelocity,
        AngularAcceleration: core.AngularAcceleration,
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

    pub fn fromJerk(id: core.Id, jerk: core.Jerk) Message {
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

    fn wireSize(self: ComponentMessage) usize {
        const id_size = serial.wireSizeId();
        const comp_type_size = serial.wireSizeEnum(core.ComponentType);

        const payload_size = switch (self.component) {
            .Position => serial.wireSizePosition(),
            .Velocity => serial.wireSizeVelocity(),
            .Acceleration => serial.wireSizeAcceleration(),
            .Jerk => serial.wireSizeJerk(),
            .Rotation => serial.wireSizeRotation(),
            .AngularVelocity => serial.wireSizeAngularVelocity(),
            .AngularAcceleration => serial.wireSizeAngularAcceleration(),
            .ShipSize => serial.wireSizeShipSize(),
        };

        return id_size + comp_type_size + payload_size;
    }

    fn serialize(self: ComponentMessage, buffer: []u8) !void {
        var offset: usize = 0;

        const id_size = serial.wireSizeId();
        if (buffer.len < offset + id_size) return serial.SerializeError.BufferTooSmall;
        try serial.serializeId(self.id, buffer[offset .. offset + id_size]);
        offset += id_size;

        const comp_type_size = serial.wireSizeEnum(core.ComponentType);
        if (buffer.len < offset + comp_type_size) return serial.SerializeError.BufferTooSmall;
        const comp_type: core.ComponentType = self.component;
        try serial.serializeEnum(core.ComponentType, comp_type, buffer[offset .. offset + comp_type_size]);
        offset += comp_type_size;

        switch (self.component) {
            .Position => |v| try serial.serializePosition(v, buffer[offset .. offset + serial.wireSizePosition()]),
            .Velocity => |v| try serial.serializeVelocity(v, buffer[offset .. offset + serial.wireSizeVelocity()]),
            .Acceleration => |v| try serial.serializeAcceleration(v, buffer[offset .. offset + serial.wireSizeAcceleration()]),
            .Jerk => |v| try serial.serializeJerk(v, buffer[offset .. offset + serial.wireSizeJerk()]),
            .Rotation => |v| try serial.serializeRotation(v, buffer[offset .. offset + serial.wireSizeRotation()]),
            .AngularVelocity => |v| try serial.serializeAngularVelocity(v, buffer[offset .. offset + serial.wireSizeAngularVelocity()]),
            .AngularAcceleration => |v| try serial.serializeAngularAcceleration(v, buffer[offset .. offset + serial.wireSizeAngularAcceleration()]),
            .ShipSize => |v| try serial.serializeShipSize(v, buffer[offset .. offset + serial.wireSizeShipSize()]),
        }
    }

    fn deserialize(buffer: []const u8) !ComponentMessage {
        var offset: usize = 0;

        const id_size = serial.wireSizeId();
        if (buffer.len < offset + id_size) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[offset .. offset + id_size]);
        offset += id_size;

        const comp_type_size = serial.wireSizeEnum(core.ComponentType);
        if (buffer.len < offset + comp_type_size) return serial.DeserializeError.Truncated;
        const comp_type = try serial.deserializeEnum(core.ComponentType, buffer[offset .. offset + comp_type_size]);
        offset += comp_type_size;

        const comp = switch (comp_type) {
            .Position => blk: {
                const size = serial.wireSizePosition();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .Position = try serial.deserializePosition(buffer[offset .. offset + size]) };
            },
            .Velocity => blk: {
                const size = serial.wireSizeVelocity();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .Velocity = try serial.deserializeVelocity(buffer[offset .. offset + size]) };
            },
            .Acceleration => blk: {
                const size = serial.wireSizeAcceleration();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .Acceleration = try serial.deserializeAcceleration(buffer[offset .. offset + size]) };
            },
            .Jerk => blk: {
                const size = serial.wireSizeJerk();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .Jerk = try serial.deserializeJerk(buffer[offset .. offset + size]) };
            },
            .Rotation => blk: {
                const size = serial.wireSizeRotation();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .Rotation = try serial.deserializeRotation(buffer[offset .. offset + size]) };
            },
            .AngularVelocity => blk: {
                const size = serial.wireSizeAngularVelocity();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .AngularVelocity = try serial.deserializeAngularVelocity(buffer[offset .. offset + size]) };
            },
            .AngularAcceleration => blk: {
                const size = serial.wireSizeAngularAcceleration();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .AngularAcceleration = try serial.deserializeAngularAcceleration(buffer[offset .. offset + size]) };
            },
            .ShipSize => blk: {
                const size = serial.wireSizeShipSize();
                if (buffer.len < offset + size) return serial.DeserializeError.Truncated;
                break :blk Component{ .ShipSize = try serial.deserializeShipSize(buffer[offset .. offset + size]) };
            },
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
            .Rotation => |jerk| {
                util.format.writeRotation(writer, jerk);
            },
            .RotationalVelocity => |jerk| {
                util.format.writeRotationalVelocity(writer, jerk);
            },
            .RotationalAcceleration => |jerk| {
                util.format.writeRotationalAcceleration(writer, jerk);
            },
            .ShipSize => |size| {
                util.format.writeShipSize(writer, size);
            },
        }
    }

    pub fn apply(self: ComponentMessage, registry: *core.Registry) void {
        switch (self.component) {
            .Position => {
                registry.setComponent(self.id, core.Position, self.component.Position);
            },
            .Velocity => {
                registry.setComponent(self.id, core.Velocity, self.component.Velocity);
            },
            .Acceleration => {
                registry.setComponent(self.id, core.Acceleration, self.component.Acceleration);
            },
            .Jerk => {
                registry.setComponent(self.id, core.Jerk, self.component.Jerk);
            },
            .Rotation => {
                registry.setComponent(self.id, core.Rotation, self.component.Rotation);
            },
            .AngularVelocity => {
                registry.setComponent(self.id, core.AngularVelocity, self.component.AngularVelocity);
            },
            .AngularAcceleration => {
                registry.setComponent(self.id, core.AngularAcceleration, self.component.AngularAcceleration);
            },
            .ShipSize => {
                registry.setComponent(self.id, core.ShipSize, self.component.ShipSize);
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

    fn wireSize(_: ComponentRemoveMessage) usize {
        return serial.wireSizeId() + serial.wireSizeEnum(core.ComponentType);
    }

    fn serialize(self: ComponentRemoveMessage, buffer: []u8) !void {
        if (buffer.len < self.wireSize()) return serial.SerializeError.BufferTooSmall;
        var offset: usize = 0;
        const id_sz = serial.wireSizeId();
        try serial.serializeId(self.id, buffer[offset .. offset + id_sz]);
        offset += id_sz;
        const comp_sz = serial.wireSizeEnum(core.ComponentType);
        try serial.serializeEnum(core.ComponentType, self.component, buffer[offset .. offset + comp_sz]);
    }

    fn deserialize(buffer: []const u8) !ComponentRemoveMessage {
        var offset: usize = 0;
        const id_sz = serial.wireSizeId();
        if (buffer.len < offset + id_sz) return serial.DeserializeError.Truncated;
        const id = try serial.deserializeId(buffer[offset .. offset + id_sz]);
        offset += id_sz;
        const comp_sz = serial.wireSizeEnum(core.ComponentType);
        if (buffer.len < offset + comp_sz) return serial.DeserializeError.Truncated;
        const ctype = try serial.deserializeEnum(core.ComponentType, buffer[offset .. offset + comp_sz]);
        return ComponentRemoveMessage{ .id = id, .component = ctype };
    }

    pub fn write(self: ComponentRemoveMessage, writer: anytype) void {
        writer.print("ComponentRemove: {}", .{self.component}) catch unreachable;
    }

    pub fn apply(self: ComponentRemoveMessage, registry: *core.Registry) void {
        switch (self.component) {
            .Position => {
                registry.removeComponent(self.id, core.Position);
            },
            .Velocity => {
                registry.removeComponent(self.id, core.Velocity);
            },
            .Acceleration => {
                registry.removeComponent(self.id, core.Acceleration);
            },
            .Jerk => {
                registry.removeComponent(self.id, core.Jerk);
            },
            .Rotation => {
                registry.removeComponent(self.id, core.Rotation);
            },
            .AngularVelocity => {
                registry.removeComponent(self.id, core.AngularVelocity);
            },
            .AngularAcceleration => {
                registry.removeComponent(self.id, core.AngularAcceleration);
            },
            .ShipSize => {
                registry.removeComponent(self.id, core.ShipSize);
            },
        }
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

    fn wireSize(_: SnapshotRequestMessage) usize {
        return 0;
    }

    fn serialize(self: SnapshotRequestMessage, buffer: []u8) serial.SerializeError!void {
        _ = self;
        _ = buffer;
    }

    fn deserialize(buffer: []const u8) serial.DeserializeError!SnapshotRequestMessage {
        _ = buffer;
        return SnapshotRequestMessage{};
    }

    pub fn write(self: SnapshotRequestMessage, writer: anytype) void {
        _ = self;

        writer.print("SnapshotRequestMessage", .{}) catch unreachable;
    }
};

pub const MessageType = enum(u8) {
    // ##### master #####
    // => server
    Assign,
    Unassign, // flush-request
    Neighbour,
    // => client
    MasterInfo,
    // => editor
    MasterDebug,

    // ##### server #####
    // => master
    Register,
    Unregister,
    Heartbeat,
    QuadInfo,
    // => server
    EntityHandover,
    EntityClaim, //mit dringlichkeit, bzw rattenschwanzlänge
    EntityFailover, //nur wenn Claim
    // => client
    ServerInfo,
    // => editor
    ServerDebug,

    // ##### client #####
    // => server
    ClientInfo,

    // ##### editor #####
    // => server
    EditorInfo,
    Command,

    // ##### meta #####
    Notice,
    Forward, //durch server und master
    Alpha,
    Omega, // Leaving und ConnectionClosed
    Kick,
    Ping,
    Pong,
    VersionCheck,
    VersionResult,
    AuthChallenge,
    AuthResult,
    AuthResponse,

    // ##### core #####
    Tick,
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
    Assign: AssignMessage,
    Unassign: UnassignMessage,
    Neighbour: NeighbourMessage,
    MasterInfo: MasterInfoMessage,
    MasterDebug: MasterDebugMessage,
    Register: RegisterMessage,
    Unregister: UnregisterMessage,
    Heartbeat: HeartbeatMessage,
    QuadInfo: QuadInfoMessage,
    EntityHandover: EntityHandoverMessage,
    EntityClaim: EntityClaimMessage,
    EntityFailover: EntityFailoverMessage,
    ServerInfo: ServerInfoMessage,
    ServerDebug: ServerDebugMessage,
    ClientInfo: ClientInfoMessage,
    EditorInfo: EditorInfoMessage,
    Command: CommandMessage,
    Notice: NoticeMessage,
    Forward: ForwardMessage,
    Alpha: AlphaMessage,
    Omega: OmegaMessage,
    Kick: KickMessage,
    Ping: PingMessage,
    Pong: PongMessage,
    VersionCheck: VersionCheckMessage,
    VersionResult: VersionResultMessage,
    AuthChallenge: AuthChallengeMessage,
    AuthResult: AuthResultMessage,
    AuthResponse: AuthResponseMessage,
    Tick: TickMessage,
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
            .Assign => |assign| {
                assign.deinit();
            },
            .Unassign => |unassign| {
                unassign.deinit();
            },
            .Neighbour => |neighbour| {
                neighbour.deinit();
            },
            .MasterInfo => |info| {
                info.deinit();
            },
            .MasterDebug => |debug| {
                debug.deinit();
            },
            .Register => |register| {
                register.deinit();
            },
            .Unregister => |unregister| {
                unregister.deinit();
            },
            .Heartbeat => |beat| {
                beat.deinit();
            },
            .QuadInfo => |info| {
                info.deinit();
            },
            .EntityHandover => |id| {
                id.deinit();
            },
            .EntityClaim => |id| {
                id.deinit();
            },
            .EntityFailover => |id| {
                id.deinit();
            },
            .ServerInfo => |info| {
                info.deinit();
            },
            .ServerDebug => |debug| {
                debug.deinit();
            },
            .ClientInfo => |info| {
                info.deinit();
            },
            .EditorInfo => |info| {
                info.deinit();
            },
            .Command => |cmd| {
                cmd.deinit();
            },
            .Notice => |note| {
                note.deinit();
            },
            .Forward => |forward| {
                forward.deinit();
            },
            .Alpha => |alpha| {
                alpha.deinit();
            },
            .Omega => |omega| {
                omega.deinit();
            },
            .Kick => |kick| {
                kick.deinit();
            },
            .Ping => |ping| {
                ping.deinit();
            },
            .Pong => |pong| {
                pong.deinit();
            },
            .VersionCheck => |vers| {
                vers.deinit();
            },
            .VersionResult => |vers| {
                vers.deinit();
            },
            .AuthChallenge => |auth| {
                auth.deinit();
            },
            .AuthResult => |auth| {
                auth.deinit();
            },
            .AuthResponse => |auth| {
                auth.deinit();
            },
            .Tick => |tick| {
                tick.deinit();
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
            .Entity => |entity| {
                entity.deinit();
            },
            .EntityRemove => |entity| {
                entity.deinit();
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

    pub fn wireSize(self: Message) usize {
        var size: usize = serial.wireSizeEnum(MessageType);

        size += switch (self) {
            .Assign => |assign| assign.wireSize(),
            .Unassign => |unassign| unassign.wireSize(),
            .Neighbour => |neighbour| neighbour.wireSize(),
            .MasterInfo => |info| info.wireSize(),
            .MasterDebug => |debug| debug.wireSize(),
            .Register => |register| register.wireSize(),
            .Unregister => |unregister| unregister.wireSize(),
            .Heartbeat => |beat| beat.wireSize(),
            .QuadInfo => |info| info.wireSize(),
            .EntityHandover => |id| id.wireSize(),
            .EntityClaim => |id| id.wireSize(),
            .EntityFailover => |id| id.wireSize(),
            .ServerInfo => |info| info.wireSize(),
            .ServerDebug => |debug| debug.wireSize(),
            .ClientInfo => |info| info.wireSize(),
            .EditorInfo => |info| info.wireSize(),
            .Command => |cmd| cmd.wireSize(),
            .Notice => |note| note.wireSize(),
            .Forward => |forward| forward.wireSize(),
            .Alpha => |alpha| alpha.wireSize(),
            .Omega => |omega| omega.wireSize(),
            .Kick => |kick| kick.wireSize(),
            .Ping => |ping| ping.wireSize(),
            .Pong => |pong| pong.wireSize(),
            .VersionCheck => |vers| vers.wireSize(),
            .VersionResult => |vers| vers.wireSize(),
            .AuthChallenge => |auth| auth.wireSize(),
            .AuthResult => |auth| auth.wireSize(),
            .AuthResponse => |auth| auth.wireSize(),
            .Tick => |tick| tick.wireSize(),
            .Static => |st| st.wireSize(),
            .Linear => |lin| lin.wireSize(),
            .Accelerated => |acc| acc.wireSize(),
            .Dynamic => |dyn| dyn.wireSize(),
            .Action => |action| action.wireSize(),
            .Entity => |id| id.wireSize(),
            .EntityRemove => |id| id.wireSize(),
            .Component => |comp| comp.wireSize(),
            .ComponentRemove => |comp| comp.wireSize(),
            .SnapshotRequest => |snap| snap.wireSize(),
        };

        return size;
    }

    pub fn serialize(self: Message, buffer: []u8) !void {
        try serial.serializeEnum(MessageType, self, buffer);
        switch (self) {
            .Assign => |assign| {
                try assign.serialize(buffer);
            },
            .Unassign => |unassign| {
                try unassign.serialize(buffer);
            },
            .Neighbour => |neighbour| {
                try neighbour.serialize(buffer);
            },
            .MasterInfo => |info| {
                try info.serialize(buffer);
            },
            .MasterDebug => |debug| {
                try debug.serialize(buffer);
            },
            .Register => |register| {
                try register.serialize(buffer);
            },
            .Unregister => |unregister| {
                try unregister.serialize(buffer);
            },
            .Heartbeat => |beat| {
                try beat.serialize(buffer);
            },
            .QuadInfo => |info| {
                try info.serialize(buffer);
            },
            .EntityHandover => |id| {
                try id.serialize(buffer);
            },
            .EntityClaim => |id| {
                try id.serialize(buffer);
            },
            .EntityFailover => |id| {
                try id.serialize(buffer);
            },
            .ServerInfo => |info| {
                try info.serialize(buffer);
            },
            .ServerDebug => |debug| {
                try debug.serialize(buffer);
            },
            .ClientInfo => |info| {
                try info.serialize(buffer);
            },
            .EditorInfo => |info| {
                try info.serialize(buffer);
            },
            .Command => |cmd| {
                try cmd.serialize(buffer);
            },
            .Notice => |note| {
                try note.serialize(buffer);
            },
            .Forward => |forward| {
                try forward.serialize(buffer);
            },
            .Alpha => |alpha| {
                try alpha.serialize(buffer);
            },
            .Omega => |omega| {
                try omega.serialize(buffer);
            },
            .Kick => |kick| {
                try kick.serialize(buffer);
            },
            .Ping => |ping| {
                try ping.serialize(buffer);
            },
            .Pong => |pong| {
                try pong.serialize(buffer);
            },
            .VersionCheck => |vers| {
                try vers.serialize(buffer);
            },
            .VersionResult => |vers| {
                try vers.serialize(buffer);
            },
            .AuthChallenge => |auth| {
                try auth.serialize(buffer);
            },
            .AuthResult => |auth| {
                try auth.serialize(buffer);
            },
            .AuthResponse => |auth| {
                try auth.serialize(buffer);
            },
            .Tick => |tick| {
                try tick.serialize(buffer);
            },
            .Static => |static| {
                try static.serialize(buffer);
            },
            .Linear => |linear| {
                try linear.serialize(buffer);
            },
            .Accelerated => |accelerated| {
                try accelerated.serialize(buffer);
            },
            .Dynamic => |dynamic| {
                try dynamic.serialize(buffer);
            },
            .Action => |action| {
                try action.serialize(buffer);
            },
            .Entity => |id| {
                try id.serialize(buffer);
            },
            .EntityRemove => |id| {
                try id.serialize(buffer);
            },
            .Component => |comp| {
                try comp.serialize(buffer);
            },
            .ComponentRemove => |comp| {
                try comp.serialize(buffer);
            },
            .SnapshotRequest => |snap| {
                try snap.serialize(buffer);
            },
        }
    }

    pub fn deserialize(buffer: []const u8, gpa: *std.mem.Allocator) !Message {
        const message_type: MessageType = serial.deserializeEnum(MessageType, buffer) catch unreachable;
        switch (message_type) {
            .Assign => {
                const assign = try AssignMessage.deserialize(buffer);
                return Message{ .Assign = assign };
            },
            .Unassign => {
                const unassign = try UnassignMessage.deserialize(buffer);
                return Message{ .Unassign = unassign };
            },
            .Neighbour => {
                const neighbour = NeighbourMessage.deserialize(buffer, gpa.*) catch unreachable;
                return Message{ .Neighbour = neighbour };
            },
            .MasterInfo => {
                const info = try MasterInfoMessage.deserialize(buffer);
                return Message{ .MasterInfo = info };
            },
            .MasterDebug => {
                const debug = try MasterDebugMessage.deserialize(buffer);
                return Message{ .MasterDebug = debug };
            },
            .Register => {
                const register = try RegisterMessage.deserialize(buffer);
                return Message{ .Register = register };
            },
            .Unregister => {
                const unregister = try UnregisterMessage.deserialize(buffer);
                return Message{ .Unregister = unregister };
            },
            .Heartbeat => {
                const beat = try HeartbeatMessage.deserialize(buffer);
                return Message{ .Heartbeat = beat };
            },
            .QuadInfo => {
                const info = try QuadInfoMessage.deserialize(buffer);
                return Message{ .QuadInfo = info };
            },
            .EntityHandover => {
                const id = try EntityHandoverMessage.deserialize(buffer);
                return Message{ .EntityHandover = id };
            },
            .EntityClaim => {
                const id = try EntityClaimMessage.deserialize(buffer);
                return Message{ .EntityClaim = id };
            },
            .EntityFailover => {
                const id = try EntityFailoverMessage.deserialize(buffer);
                return Message{ .EntityFailover = id };
            },
            .ServerInfo => {
                const info = try ServerInfoMessage.deserialize(buffer);
                return Message{ .ServerInfo = info };
            },
            .ServerDebug => {
                const debug = try ServerDebugMessage.deserialize(buffer);
                return Message{ .ServerDebug = debug };
            },
            .ClientInfo => {
                const info = try ClientInfoMessage.deserialize(buffer);
                return Message{ .ClientInfo = info };
            },
            .EditorInfo => {
                const info = try EditorInfoMessage.deserialize(buffer);
                return Message{ .EditorInfo = info };
            },
            .Command => {
                const cmd = try CommandMessage.deserialize(buffer, gpa.*);
                return Message{ .Command = cmd };
            },
            .Notice => {
                const note = try NoticeMessage.deserialize(buffer, gpa);
                return Message{ .Notice = note };
            },
            .Forward => {
                const forward = try ForwardMessage.deserialize(buffer, gpa);
                return Message{ .Forward = forward };
            },
            .Alpha => {
                const alpha = try AlphaMessage.deserialize(buffer, gpa);
                return Message{ .Alpha = alpha };
            },
            .Omega => {
                const omega = try OmegaMessage.deserialize(buffer, gpa);
                return Message{ .Omega = omega };
            },
            .Kick => {
                const kick = try KickMessage.deserialize(buffer, gpa);
                return Message{ .Kick = kick };
            },
            .Ping => {
                const ping = try PingMessage.deserialize(buffer);
                return Message{ .Ping = ping };
            },
            .Pong => {
                const pong = try PongMessage.deserialize(buffer);
                return Message{ .Pong = pong };
            },
            .VersionCheck => {
                const vers = try VersionCheckMessage.deserialize(buffer, gpa);
                return Message{ .VersionCheck = vers };
            },
            .VersionResult => {
                const vers = try VersionResultMessage.deserialize(buffer, gpa);
                return Message{ .VersionResult = vers };
            },
            .AuthChallenge => {
                const auth = try AuthChallengeMessage.deserialize(buffer);
                return Message{ .AuthChallenge = auth };
            },
            .AuthResult => {
                const auth = try AuthResultMessage.deserialize(buffer);
                return Message{ .AuthResult = auth };
            },
            .AuthResponse => {
                const auth = try AuthResponseMessage.deserialize(buffer);
                return Message{ .AuthResponse = auth };
            },
            .Tick => {
                const tick = try TickMessage.deserialize(buffer);
                return Message{ .Tick = tick };
            },
            .Static => {
                const pos = try StaticMessage.deserialize(buffer);
                return Message{ .Static = pos };
            },
            .Linear => {
                const vel = try LinearMessage.deserialize(buffer);
                return Message{ .Linear = vel };
            },
            .Accelerated => {
                const acc = try AcceleratedMessage.deserialize(buffer);
                return Message{ .Accelerated = acc };
            },
            .Dynamic => {
                const dyn = try DynamicMessage.deserialize(buffer);
                return Message{ .Dynamic = dyn };
            },
            .Action => {
                const act = try ActionMessage.deserialize(buffer);
                return Message{ .Action = act };
            },
            .Entity => {
                const id = try EntityMessage.deserialize(buffer);
                return Message{ .Entity = id };
            },
            .EntityRemove => {
                const id = try EntityRemoveMessage.deserialize(buffer);
                return Message{ .EntityRemove = id };
            },
            .Component => {
                const comp = try ComponentMessage.deserialize(buffer);
                return Message{ .Component = comp };
            },
            .ComponentRemove => {
                const comp = try ComponentRemoveMessage.deserialize(buffer);
                return Message{ .ComponentRemove = comp };
            },
            .SnapshotRequest => {
                const snap = try SnapshotRequestMessage.deserialize(buffer);
                return Message{ .SnapshotRequest = snap };
            },
        }
    }

    pub fn print(self: Message, writer: anytype) void {
        switch (self) {
            .Assign => |assign| {
                assign.write(writer);
            },
            .Unassign => |unassign| {
                unassign.write(writer);
            },
            .Neighbour => |neighbour| {
                neighbour.write(writer);
            },
            .MasterInfo => |info| {
                info.write(writer);
            },
            .MasterDebug => |debug| {
                debug.write(writer);
            },
            .Register => |register| {
                register.write(writer);
            },
            .Unregister => |unregister| {
                unregister.write(writer);
            },
            .Heartbeat => |beat| {
                beat.write(writer);
            },
            .QuadInfo => |info| {
                info.write(writer);
            },
            .EntityHandover => |id| {
                id.write(writer);
            },
            .EntityHandover => |id| {
                id.write(writer);
            },
            .EntityClaim => |id| {
                id.write(writer);
            },
            .EntityFailover => |id| {
                id.write(writer);
            },
            .ServerInfo => |info| {
                info.write(writer);
            },
            .ServerDebug => |debug| {
                debug.write(writer);
            },
            .ClientInfo => |info| {
                info.write(writer);
            },
            .EditorInfo => |info| {
                info.write(writer);
            },
            .Command => |cmd| {
                cmd.write(writer);
            },
            .Notice => |note| {
                note.write(writer);
            },
            .Forward => |forward| {
                forward.write(writer);
            },
            .Alpha => |alpha| {
                alpha.write(writer);
            },
            .Omega => |omega| {
                omega.write(writer);
            },
            .Kick => |kick| {
                kick.write(writer);
            },
            .Ping => |ping| {
                ping.write(writer);
            },
            .Pong => |pong| {
                pong.write(writer);
            },
            .VersionCheck => |vers| {
                vers.write(writer);
            },
            .VersionResult => |vers| {
                vers.write(writer);
            },
            .AuthChallenge => |auth| {
                auth.write(writer);
            },
            .AuthResult => |auth| {
                auth.write(writer);
            },
            .AuthResponse => |auth| {
                auth.write(writer);
            },
            .Tick => |tick| {
                tick.write(writer);
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
