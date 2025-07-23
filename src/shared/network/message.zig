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
const serial = @import("serial.zig");
// -----------------------------

// ---------- shared ----------
const core = @import("../core/core.zig");
const util = @import("../util/util.zig");
// ----------------------------

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

    fn serialize(self: AssignMessage, writer: anytype) void {
        serial.serializeU64(writer, self.quad);
    }

    fn deserialize(reader: anytype) AssignMessage {
        const quad = serial.deserializeU64(reader);
        return init(quad).Assign;
    }

    pub fn write(self: AssignMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: UnassignMessage, writer: anytype) void {
        serial.serializeU64(writer, self.quad);
    }

    fn deserialize(reader: anytype) UnassignMessage {
        const quad = serial.deserializeU64(reader);
        return init(quad).Unassign;
    }

    pub fn write(self: UnassignMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
};

pub const NeighbourMessage = struct {
    quad: u64,
    //neighbours: []const util.UUID4,

    pub fn init(quad: u64) Message {
        const neighbour = NeighbourMessage{ .quad = quad };

        return Message{ .Neighbour = neighbour };
    }

    fn deinit(self: NeighbourMessage) void {
        _ = self;
    }

    fn serialize(self: NeighbourMessage, writer: anytype) void {
        serial.serializeU64(writer, self.quad);
        //serial.serializeU16(writer, @intCast(u16, self.neighbours.len));
        //for (self.neighbours) |n| n.serialize(writer);
    }
    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) NeighbourMessage {
        _ = allocator;
        const id = serial.deserializeU64(reader);
        //const len = serial.deserializeU16(reader);
        //const arr = allocator.alloc(util.UUID4, len) catch unreachable;
        //for (arr) |*n| n.* = util.UUID4.deserialize(reader);
        return init(id).Neighbour;
    }

    pub fn write(self: NeighbourMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: MasterInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }

    fn deserialize(reader: anytype) MasterInfoMessage {
        _ = reader;
        return init().MasterInfo;
    }

    pub fn write(self: MasterInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: MasterDebugMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }

    fn deserialize(reader: anytype) MasterDebugMessage {
        _ = reader;
        return init().MasterDebug;
    }

    pub fn write(self: MasterDebugMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: RegisterMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
    fn deserialize(reader: anytype) RegisterMessage {
        _ = reader;
        return init().Register;
    }

    pub fn write(self: RegisterMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: UnregisterMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
    fn deserialize(reader: anytype) UnregisterMessage {
        _ = reader;
        return init().Unregister;
    }

    pub fn write(self: UnregisterMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: HeartbeatMessage, writer: anytype) void {
        serial.serializeF32(writer, self.load);
    }

    fn deserialize(reader: anytype) HeartbeatMessage {
        const load = serial.deserializeF32(reader);
        return init(load).Heartbeat;
    }

    pub fn write(self: HeartbeatMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: QuadInfoMessage, writer: anytype) void {
        serial.serializeU64(writer, self.id);
        serial.serializeF32(writer, self.pressure);
    }
    fn deserialize(reader: anytype) QuadInfoMessage {
        const id = serial.deserializeU64(reader);
        const pressure = serial.deserializeF32(reader);
        return init(id, pressure).QuadInfo;
    }

    pub fn write(self: QuadInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
};

pub const EntityHandoverMessage = struct {
    id: util.UUID4,

    pub fn init(entity_id: util.UUID4) Message {
        const msg = EntityHandoverMessage{
            .id = entity_id,
        };

        return Message{ .EntityHandover = msg };
    }

    fn deinit(self: EntityHandoverMessage) void {
        _ = self;
    }

    fn serialize(self: EntityHandoverMessage, writer: anytype) void {
        self.id.serialize(writer);
    }

    fn deserialize(reader: anytype) EntityHandoverMessage {
        const id = util.UUID4.deserialize(reader);
        return init(id).EntityHandover;
    }

    pub fn write(self: EntityHandoverMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
};

pub const EntityClaimMessage = struct {
    id: util.UUID4,

    pub fn init(id: util.UUID4) Message {
        const msg = EntityClaimMessage{
            .id = id,
        };

        return Message{ .EntityClaim = msg };
    }

    fn deinit(self: EntityClaimMessage) void {
        _ = self;
    }

    fn serialize(self: EntityClaimMessage, writer: anytype) void {
        self.id.serialize(writer);
    }

    fn deserialize(reader: anytype) EntityClaimMessage {
        const id = util.UUID4.deserialize(reader);
        return init(id).EntityClaim;
    }

    pub fn write(self: EntityClaimMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
};

pub const EntityFailoverMessage = struct {
    id: util.UUID4,

    pub fn init(entity_id: util.UUID4) Message {
        const msg = EntityFailoverMessage{
            .id = entity_id,
        };
        return Message{ .EntityFailover = msg };
    }

    fn deinit(self: EntityFailoverMessage) void {
        _ = self;
    }

    fn serialize(self: EntityFailoverMessage, writer: anytype) void {
        self.id.serialize(writer);
    }

    fn deserialize(reader: anytype) EntityFailoverMessage {
        const id = util.UUID4.deserialize(reader);
        return init(id).EntityFailover;
    }

    pub fn write(self: EntityFailoverMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: ServerInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }

    fn deserialize(reader: anytype) ServerInfoMessage {
        _ = reader;
        return init().ServerInfo;
    }

    pub fn write(self: ServerInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: ServerDebugMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }

    fn deserialize(reader: anytype) ServerDebugMessage {
        _ = reader;
        return init().ServerDebug;
    }

    pub fn write(self: ServerDebugMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: ClientInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }

    fn deserialize(reader: anytype) ClientInfoMessage {
        _ = reader;
        return init().ClientInfo;
    }

    pub fn write(self: ClientInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: EditorInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }

    fn deserialize(reader: anytype) EditorInfoMessage {
        _ = reader;
        return init().EditorInfo;
    }

    pub fn write(self: EditorInfoMessage, writer: anytype) void {
        _ = self;
        _ = writer;
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

    fn serialize(self: CommandMessage, writer: anytype) void {
        serial.serializeText(writer, self.command);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) CommandMessage {
        const cmd = serial.deserializeText(reader, allocator);
        return init(cmd).Command;
    }

    pub fn write(self: CommandMessage, writer: anytype) void {
        _ = self;
        _ = writer;
    }
};

pub const NoticeMessage = struct {
    allocator: *std.mem.Allocator,
    duration: i64,
    message: []const u8,

    pub fn init(allocator: *std.mem.Allocator, duration: i64, message: []const u8) Message {
        const dup_message = allocator.dupe(u8, message) catch unreachable;

        const note = NoticeMessage{
            .allocator = allocator,
            .duration = duration,
            .message = dup_message,
        };

        return Message{ .Notice = note };
    }

    fn deinit(self: NoticeMessage) void {
        self.allocator.free(self.message);
    }

    fn serialize(self: NoticeMessage, writer: anytype) void {
        serial.serializeI64(writer, self.duration);
        serial.serializeText(writer, self.message);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) NoticeMessage {
        const until = serial.deserializeI64(reader);
        const message = serial.deserializeText(reader, allocator);
        return init(allocator, until, message).Notice;
    }

    pub fn write(self: NoticeMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("VersionResult: {d}", .{self.is_match}) catch unreachable;
    }
};

pub const ForwardMessage = struct {
    allocator: *std.mem.Allocator,
    serverId: util.UUID4,
    ip: []const u8,
    port: u16,

    pub fn init(allocator: *std.mem.Allocator, serverId: util.UUID4, ip: []const u8, port: u16) Message {
        const forward = ForwardMessage{
            .allocator = allocator,
            .serverId = serverId,
            .ip = ip,
            .port = port,
        };

        return Message{ .Forward = forward };
    }

    fn deinit(self: ForwardMessage) void {
        self.allocator.free(self.ip);
    }

    fn serialize(self: ForwardMessage, writer: anytype) void {
        self.serverId.serialize(writer);
        serial.serializeText(writer, self.ip);
        serial.serializeU16(writer, self.port);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) ForwardMessage {
        const serverId = util.UUID4.deserialize(reader);
        const ip = serial.deserializeText(reader, allocator);
        const port = serial.deserializeU16(reader);
        return init(allocator, serverId, ip, port).Forward;
    }

    pub fn write(self: ForwardMessage, writer: anytype) void {
        //writer.print("Alpha: {d}", .{self.tick}) catch unreachable;
        _ = self;
        _ = writer;
    }
};

pub const AlphaMessage = struct {
    allocator: *std.mem.Allocator,
    ephemeral: util.UUID4,
    name: []const u8,

    pub fn init(allocator: *std.mem.Allocator, ephemeral: util.UUID4, name: []const u8) Message {
        const alpha = AlphaMessage{
            .allocator = allocator,
            .ephemeral = ephemeral,
            .name = name,
        };

        return Message{ .Alpha = alpha };
    }

    fn deinit(self: AlphaMessage) void {
        self.allocator.free(self.name);
    }

    fn serialize(self: AlphaMessage, writer: anytype) void {
        self.ephemeral.serialize(writer);
        serial.serializeText(writer, self.name);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) AlphaMessage {
        const ephemeral = util.UUID4.deserialize(reader);
        const name = serial.deserializeText(reader, allocator);
        return init(allocator, ephemeral, name).Alpha;
    }

    pub fn write(self: AlphaMessage, writer: anytype) void {
        //writer.print("Alpha: {d}", .{self.tick}) catch unreachable;
        _ = self;
        _ = writer;
    }
};

pub const OmegaMessage = struct {
    allocator: *std.mem.Allocator,
    message: []const u8,

    pub fn init(allocator: *std.mem.Allocator, message: []const u8) Message {
        const omega = OmegaMessage{
            .allocator = allocator,
            .message = message,
        };

        return Message{ .Omega = omega };
    }

    fn deinit(self: OmegaMessage) void {
        self.allocator.free(self.message);
    }

    fn serialize(self: OmegaMessage, writer: anytype) void {
        serial.serializeText(writer, self.message);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) OmegaMessage {
        const message = serial.deserializeText(reader, allocator);
        return init(allocator, message).Omega;
    }

    pub fn write(self: OmegaMessage, writer: anytype) void {
        //writer.print("Alpha: {d}", .{self.tick}) catch unreachable;
        _ = self;
        _ = writer;
    }
};

pub const KickMessage = struct {
    allocator: *std.mem.Allocator,
    duration: i64,
    message: []const u8,

    pub fn init(allocator: *std.mem.Allocator, duration: i64, message: []const u8) Message {
        const dup_message = allocator.dupe(u8, message) catch unreachable;

        const kick = KickMessage{
            .allocator = allocator,
            .duration = duration,
            .message = dup_message,
        };

        return Message{ .Kick = kick };
    }

    fn deinit(self: KickMessage) void {
        self.allocator.free(self.message);
    }

    fn serialize(self: KickMessage, writer: anytype) void {
        serial.serializeI64(writer, self.duration);
        serial.serializeText(writer, self.message);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) KickMessage {
        const until = serial.deserializeI64(reader);
        const message = serial.deserializeText(reader, allocator);
        return init(allocator, until, message).Kick;
    }

    pub fn write(self: KickMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("VersionResult: {d}", .{self.is_match}) catch unreachable;
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

    fn serialize(self: PingMessage, writer: anytype) void {
        serial.serializeU64(writer, self.nonce);
        serial.serializeI64(writer, self.time);
    }

    fn deserialize(reader: anytype) PingMessage {
        const nonce = serial.deserializeU64(reader);
        const time = serial.deserializeI64(reader);
        return init(nonce, time).Ping;
    }

    pub fn write(self: PingMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("AuthChallenge: {d}", .{self.auth_id}) catch unreachable;
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

    fn serialize(self: PongMessage, writer: anytype) void {
        serial.serializeU64(writer, self.nonce);
        serial.serializeI64(writer, self.time);
    }

    fn deserialize(reader: anytype) PongMessage {
        const nonce = serial.deserializeU64(reader);
        const time = serial.deserializeI64(reader);
        return init(nonce, time).Pong;
    }

    pub fn write(self: PongMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("AuthChallenge: {d}", .{self.auth_id}) catch unreachable;
    }
};

pub const VersionCheckMessage = struct {
    allocator: *std.mem.Allocator,
    version: []const u8,

    pub fn init(allocator: *std.mem.Allocator, version: []const u8) Message {
        const dup_version = allocator.dupe(u8, version) catch unreachable;

        const vers = VersionCheckMessage{
            .allocator = allocator,
            .version = dup_version,
        };

        return Message{ .VersionCheck = vers };
    }

    fn deinit(self: VersionCheckMessage) void {
        self.allocator.free(self.version);
    }

    fn serialize(self: VersionCheckMessage, writer: anytype) void {
        serial.serializeText(writer, self.version);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) VersionCheckMessage {
        const version = serial.deserializeText(reader, allocator);
        return init(allocator, version).VersionCheck;
    }

    pub fn write(self: VersionCheckMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("VersionResult: {d}", .{self.is_match}) catch unreachable;
    }
};

pub const VersionResultMessage = struct {
    allocator: *std.mem.Allocator,
    is_match: bool,
    version: []const u8,
    message: []const u8,

    pub fn init(allocator: *std.mem.Allocator, is_match: bool, version: []const u8, message: []const u8) Message {
        const dup_version = allocator.dupe(u8, version) catch unreachable;
        const dup_message = allocator.dupe(u8, message) catch unreachable;

        const vers = VersionResultMessage{
            .allocator = allocator,
            .is_match = is_match,
            .version = dup_version,
            .message = dup_message,
        };

        return Message{ .VersionResult = vers };
    }

    fn deinit(self: VersionResultMessage) void {
        self.allocator.free(self.version);
        self.allocator.free(self.message);
    }

    fn serialize(self: VersionResultMessage, writer: anytype) void {
        serial.serializeBool(writer, self.is_match);
        serial.serializeText(writer, self.version);
        serial.serializeText(writer, self.message);
    }

    fn deserialize(reader: anytype, allocator: *std.mem.Allocator) VersionResultMessage {
        const is_match = serial.deserializeBool(reader);
        const version = serial.deserializeText(reader, allocator);
        const message = serial.deserializeText(reader, allocator);
        return init(allocator, is_match, version, message).VersionResult;
    }

    pub fn write(self: VersionResultMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("VersionResult: {d}", .{self.is_match}) catch unreachable;
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

    fn serialize(self: AuthChallengeMessage, writer: anytype) void {
        serial.serializeU64(writer, self.is_success);
    }

    fn deserialize(reader: anytype) AuthChallengeMessage {
        const auth_id = serial.deserializeU64(reader);
        return init(auth_id).AuthChallenge;
    }

    pub fn write(self: AuthChallengeMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("AuthChallenge: {d}", .{self.auth_id}) catch unreachable;
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

    fn serialize(self: AuthResultMessage, writer: anytype) void {
        serial.serializeU64(writer, self.auth_id);
    }

    fn deserialize(reader: anytype) AuthResultMessage {
        const auth_id = serial.deserializeU64(reader);
        return init(auth_id).AuthResult;
    }

    pub fn write(self: AuthResultMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("AuthResult: {d}", .{self.auth_id}) catch unreachable;
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

    fn serialize(self: AuthResponseMessage, writer: anytype) void {
        serial.serializeU64(writer, self.auth_id);
        serial.serializeBool(writer, self.is_success);
    }

    fn deserialize(reader: anytype) AuthResponseMessage {
        const auth_id = serial.deserializeU64(reader);
        const is_success = serial.deserializeBool(reader);
        return init(auth_id, is_success).AuthResponse;
    }

    pub fn write(self: AuthResponseMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("AuthResponse: {d}", .{self.is_success}) catch unreachable;
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

    fn serialize(self: TickMessage, writer: anytype) void {
        serial.serializeU64(writer, self.tick);
        serial.serializeI64(writer, self.time);
    }

    fn deserialize(reader: anytype) TickMessage {
        const tick = serial.deserializeU64(reader);
        const time = serial.deserializeI64(reader);
        return init(tick, time).Tick;
    }

    pub fn write(self: TickMessage, writer: anytype) void {
        _ = self;
        _ = writer;
        //writer.print("Tick: {d}", .{self.tick}) catch unreachable;
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
        serial.serializePosition(writer, self.position);
    }

    fn deserialize(reader: anytype) StaticMessage {
        const pos = serial.deserializePosition(reader);
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
        serial.serializePosition(writer, self.position);
        serial.serializeVelocity(writer, self.velocity);
    }

    fn deserialize(reader: anytype) LinearMessage {
        const pos = serial.deserializePosition(reader);
        const vel = serial.deserializeVelocity(reader);
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
        serial.serializePosition(writer, self.position);
        serial.serializeVelocity(writer, self.velocity);
        serial.serializeAcceleration(writer, self.acceleration);
    }

    fn deserialize(reader: anytype) AcceleratedMessage {
        const pos = serial.deserializePosition(reader);
        const vel = serial.deserializeVelocity(reader);
        const acc = serial.deserializeAcceleration(reader);
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
        serial.serializePosition(writer, self.position);
        serial.serializeVelocity(writer, self.velocity);
        serial.serializeAcceleration(writer, self.acceleration);
        serial.serializeJerk(writer, self.jerk);
    }

    fn deserialize(reader: anytype) DynamicMessage {
        const pos = serial.deserializePosition(reader);
        const vel = serial.deserializeVelocity(reader);
        const acc = serial.deserializeAcceleration(reader);
        const jerk = serial.deserializeJerk(reader);
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
    id: util.UUID4,

    pub fn init(id: util.UUID4) Message {
        const msg = EntityMessage{
            .id = id,
        };

        return Message{ .Entity = msg };
    }

    fn deinit(self: EntityMessage) void {
        _ = self;
    }

    fn serialize(self: EntityMessage, writer: anytype) void {
        self.id.serialize(writer);
    }

    fn deserialize(reader: anytype) EntityMessage {
        const id = util.UUID4.deserialize(reader);
        return init(id).Entity;
    }

    pub fn write(self: EntityMessage, writer: anytype) void {
        writer.print("EntityMessage: {}", .{self.id}) catch unreachable;
    }
};

pub const EntityRemoveMessage = struct {
    id: util.UUID4,

    pub fn init(id: util.UUID4) Message {
        const msg = EntityRemoveMessage{
            .id = id,
        };

        return Message{ .EntityRemove = msg };
    }

    fn deinit(self: EntityRemoveMessage) void {
        _ = self;
    }

    fn serialize(self: EntityRemoveMessage, writer: anytype) void {
        self.id.serialize(writer);
    }

    fn deserialize(reader: anytype) EntityRemoveMessage {
        const id = util.UUID4.deserialize(reader);
        return init(id).EntityRemove;
    }

    pub fn write(self: EntityRemoveMessage, writer: anytype) void {
        writer.print("EntityRemoveMessage: {}", .{self.id}) catch unreachable;
    }
};

pub const ComponentMessage = struct {
    id: util.UUID4,
    component: Component,

    pub const Component = union(core.ComponentType) {
        Position: core.Position,
        Velocity: core.Velocity,
        Acceleration: core.Acceleration,
        Jerk: core.Jerk,
        Rotation: core.Rotation,
        RotationalVelocity: core.RotationalVelocity,
        RotationalAcceleration: core.RotationalAcceleration,
        ShipSize: core.ShipSize,
    };

    pub fn fromPosition(id: util.UUID4, pos: core.Position) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{ .Position = pos },
        };

        return Message{ .Component = comp };
    }

    pub fn fromVelocity(id: util.UUID4, vel: core.Velocity) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .Velocity = vel,
            },
        };

        return Message{ .Component = comp };
    }

    pub fn fromAcceleration(id: util.UUID4, acc: core.Acceleration) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .Acceleration = acc,
            },
        };

        return Message{ .Component = comp };
    }

    pub fn fromJerk(id: util.UUID4, jerk: core.Jerk) Message {
        const comp = ComponentMessage{
            .id = id,
            .component = .{
                .Jerk = jerk,
            },
        };

        return Message{ .Component = comp };
    }

    pub fn fromShipSize(id: util.UUID4, size: core.ShipSize) Message {
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
        self.id.serialize(writer);
        writer.writeByte(@intFromEnum(self.component)) catch unreachable;
        switch (self.component) {
            .Position => |pos| {
                serial.serializePosition(writer, pos);
            },
            .Velocity => |vel| {
                serial.serializeVelocity(writer, vel);
            },
            .Acceleration => |acc| {
                serial.serializeAcceleration(writer, acc);
            },
            .Jerk => |jerk| {
                serial.serializeJerk(writer, jerk);
            },
            .Rotation => |rot| {
                serial.serializeRotation(writer, rot);
            },
            .RotationalVelocity => |rotv| {
                serial.serializeRotationalVelocity(writer, rotv);
            },
            .RotationalAcceleration => |rota| {
                serial.serializeRotationalAcceleration(writer, rota);
            },
            .ShipSize => |size| {
                serial.serializeShipSize(writer, size);
            },
        }
    }

    pub fn deserialize(reader: anytype) ComponentMessage {
        const id = util.UUID4.deserialize(reader);
        const type_byte = reader.readByte() catch unreachable;
        const comp_type: core.ComponentType = @enumFromInt(type_byte);
        const comp = switch (comp_type) {
            .Position => Component{ .Position = serial.deserializePosition(reader) },
            .Velocity => Component{ .Velocity = serial.deserializeVelocity(reader) },
            .Acceleration => Component{ .Acceleration = serial.deserializeAcceleration(reader) },
            .Jerk => Component{ .Jerk = serial.deserializeJerk(reader) },
            .Rotation => Component{ .Rotation = serial.deserializeRotation(reader) },
            .RotationalVelocity => Component{ .RotationalVelocity = serial.deserializeRotationalVelocity(reader) },
            .RotationalAcceleration => Component{ .RotationalAcceleration = serial.deserializeRotationalAcceleration(reader) },
            .ShipSize => Component{ .ShipSize = serial.deserializeShipSize(reader) },
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

    pub fn apply(self: ComponentMessage, model: *core.Model) void {
        switch (self.component) {
            .Position => {
                model.setComponent(self.id, core.Position, self.component.Position);
            },
            .Velocity => {
                model.setComponent(self.id, core.Velocity, self.component.Velocity);
            },
            .Acceleration => {
                model.setComponent(self.id, core.Acceleration, self.component.Acceleration);
            },
            .Jerk => {
                model.setComponent(self.id, core.Jerk, self.component.Jerk);
            },
            .Rotation => {
                model.setComponent(self.id, core.Rotation, self.component.Rotation);
            },
            .RotationalVelocity => {
                model.setComponent(self.id, core.RotationalVelocity, self.component.RotationalVelocity);
            },
            .RotationalAcceleration => {
                model.setComponent(self.id, core.RotationalAcceleration, self.component.RotationalAcceleration);
            },
            .ShipSize => {
                model.setComponent(self.id, core.ShipSize, self.component.ShipSize);
            },
        }
    }
};

pub const ComponentRemoveMessage = struct {
    id: util.UUID4,
    component: core.ComponentType,

    pub fn init(id: util.UUID4, comp: core.ComponentType) Message {
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
        self.id.serialize(writer);
        writer.writeByte(@intFromEnum(self.component)) catch unreachable;
    }

    fn deserialize(reader: anytype) ComponentRemoveMessage {
        const id = util.UUID4.deserialize(reader);
        const type_byte = reader.readByte() catch unreachable;
        return init(id, @enumFromInt(type_byte)).ComponentRemove;
    }

    pub fn write(self: ComponentRemoveMessage, writer: anytype) void {
        writer.print("ComponentRemove: {}", .{self.component}) catch unreachable;
    }

    pub fn apply(self: ComponentRemoveMessage, model: *core.Model) void {
        switch (self.component) {
            .Position => {
                model.removeComponent(self.id, core.Position);
            },
            .Velocity => {
                model.removeComponent(self.id, core.Velocity);
            },
            .Acceleration => {
                model.removeComponent(self.id, core.Acceleration);
            },
            .Jerk => {
                model.removeComponent(self.id, core.Jerk);
            },
            .Rotation => {
                model.removeComponent(self.id, core.Rotation);
            },
            .RotationalVelocity => {
                model.removeComponent(self.id, core.RotationalVelocity);
            },
            .RotationalAcceleration => {
                model.removeComponent(self.id, core.RotationalAcceleration);
            },
            .ShipSize => {
                model.removeComponent(self.id, core.ShipSize);
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

    pub fn serialize(self: Message, writer: anytype) void {
        writer.writeByte(@intFromEnum(self)) catch unreachable;
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
                tick.serialize(writer);
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
            .Assign => {
                const assign = AssignMessage.deserialize(reader);
                return Message{ .Assign = assign };
            },
            .Unassign => {
                const unassign = UnassignMessage.deserialize(reader);
                return Message{ .Unassign = unassign };
            },
            .Neighbour => {
                const neighbour = NeighbourMessage.deserialize(reader, allocator);
                return Message{ .Neighbour = neighbour };
            },
            .MasterInfo => {
                const info = MasterInfoMessage.deserialize(reader);
                return Message{ .MasterInfo = info };
            },
            .MasterDebug => {
                const debug = MasterDebugMessage.deserialize(reader);
                return Message{ .MasterDebug = debug };
            },
            .Register => {
                const register = RegisterMessage.deserialize(reader);
                return Message{ .Register = register };
            },
            .Unregister => {
                const unregister = UnregisterMessage.deserialize(reader);
                return Message{ .Unregister = unregister };
            },
            .Heartbeat => {
                const beat = HeartbeatMessage.deserialize(reader);
                return Message{ .Heartbeat = beat };
            },
            .QuadInfo => {
                const info = QuadInfoMessage.deserialize(reader);
                return Message{ .QuadInfo = info };
            },
            .EntityHandover => {
                const id = EntityHandoverMessage.deserialize(reader);
                return Message{ .EntityHandover = id };
            },
            .EntityClaim => {
                const id = EntityClaimMessage.deserialize(reader);
                return Message{ .EntityClaim = id };
            },
            .EntityFailover => {
                const id = EntityFailoverMessage.deserialize(reader);
                return Message{ .EntityFailover = id };
            },
            .ServerInfo => {
                const info = ServerInfoMessage.deserialize(reader);
                return Message{ .ServerInfo = info };
            },
            .ServerDebug => {
                const debug = ServerDebugMessage.deserialize(reader);
                return Message{ .ServerDebug = debug };
            },
            .ClientInfo => {
                const info = ClientInfoMessage.deserialize(reader);
                return Message{ .ClientInfo = info };
            },
            .EditorInfo => {
                const info = EditorInfoMessage.deserialize(reader);
                return Message{ .EditorInfo = info };
            },
            .Command => {
                const cmd = CommandMessage.deserialize(reader, allocator);
                return Message{ .Command = cmd };
            },
            .Notice => {
                const note = NoticeMessage.deserialize(reader, allocator);
                return Message{ .Notice = note };
            },
            .Forward => {
                const forward = ForwardMessage.deserialize(reader, allocator);
                return Message{ .Forward = forward };
            },
            .Alpha => {
                const alpha = AlphaMessage.deserialize(reader, allocator);
                return Message{ .Alpha = alpha };
            },
            .Omega => {
                const omega = OmegaMessage.deserialize(reader, allocator);
                return Message{ .Omega = omega };
            },
            .Kick => {
                const kick = KickMessage.deserialize(reader, allocator);
                return Message{ .Kick = kick };
            },
            .Ping => {
                const ping = PingMessage.deserialize(reader);
                return Message{ .Ping = ping };
            },
            .Pong => {
                const pong = PongMessage.deserialize(reader);
                return Message{ .Pong = pong };
            },
            .VersionCheck => {
                const vers = VersionCheckMessage.deserialize(reader, allocator);
                return Message{ .VersionCheck = vers };
            },
            .VersionResult => {
                const vers = VersionResultMessage.deserialize(reader, allocator);
                return Message{ .VersionResult = vers };
            },
            .AuthChallenge => {
                const auth = AuthChallengeMessage.deserialize(reader);
                return Message{ .AuthChallenge = auth };
            },
            .AuthResult => {
                const auth = AuthResultMessage.deserialize(reader);
                return Message{ .AuthResult = auth };
            },
            .AuthResponse => {
                const auth = AuthResponseMessage.deserialize(reader);
                return Message{ .AuthResponse = auth };
            },
            .Tick => {
                const tick = TickMessage.deserialize(reader);
                return Message{ .Tick = tick };
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
