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

// ---------- external ----------
const net = @import("network");
// ------------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ----------
const message = @import("message.zig");
const serial = @import("serial/serial.zig");
// ---------------------------

fn magicFrom(tag: []const u8) comptime_int {
    var out: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(tag, &out, .{});
    return std.mem.readInt(u32, out[0..4], .big);
}

pub const Channel = enum(u8) {
    core_reliable = 0,
    game_reliable = 1,
    unreliable = 2,
};

const PackageError = error{
    OutOfSpace,
    Empty,
    GarbargeReceived,
    VersionMismatch,
};

const NetError = error{
    ClosedConnection,
    WouldBlock,
    SendFailed,
};

const Error = PackageError || NetError || serial.DeserializeError;

pub const Header = struct {
    magic: u32,
    version: u8,
    channel: Channel,
    sequence: u32,
    msg_count: u8,

    pub const MAGIC = magicFrom("all your starbase are belong to us");
    pub const VERSION = 1;

    pub fn wireSize() usize {
        return 2 * serial.wireSizeU32() + 2 * serial.wireSizeU8() + serial.wireSizeEnum(Channel);
    }

    pub fn serialize(self: *const Header, buffer: []u8) serial.SerializeError!void {
        serial.serializeU32(self.magic, buffer);
        serial.serializeU8(self.version, buffer);
        serial.serializeEnum(Channel, self.channel, buffer);
        serial.serializeU32(self.sequence, buffer);
        serial.serializeU8(self.msg_count, buffer);
    }

    pub fn deserialize(buffer: []const u8) Header {
        var header: Header = undefined;

        header.magic = serial.deserializeU32(buffer);
        header.version = serial.deserializeU8(buffer);
        header.channel = serial.deserializeEnum(Channel, buffer);
        header.sequence = serial.deserializeU32(buffer);
        header.msg_count = serial.deserializeU8(buffer);

        return header;
    }
};

pub const Package = struct {
    buffer: [max_byte]u8 = undefined,
    header: Header,
    offset: u32 = 0,

    pub const max_byte = 1200;

    pub fn init(channel: Channel, sequence: u32) Package {
        var package = Package{ .header = Header{
            .magic = Header.MAGIC,
            .version = Header.VERSION,
            .channel = channel,
            .sequence = sequence,
            .msg_count = 0,
        } };

        package.offset += Header.wireSize();

        return package;
    }

    pub fn append(self: *Package, msg: message.Message) PackageError!void {
        const size = msg.wireSize();
        if (max_byte - self.offset < size) return PackageError.OutOfSpace;

        msg.serialize(self.buffer[self.offset .. self.offset + size]) catch unreachable;
        self.offset += size;

        self.header.msg_count += 1;
    }

    pub fn pop(self: *Package, gpa: *std.mem.Allocator) Error!message.Message {
        if (self.header.msg_count == 0) return PackageError.Empty;

        self.header.msg_count -= 1;

        const msg = try message.Message.deserialize(self.buffer, gpa);
        self.offset += msg.wireSize();

        std.debug.assert(self.offset <= Package.max_byte);
    }

    pub fn send(self: Package, socket: *net.Socket) NetError!void {
        self.header.serialize(self.buffer[0..Header.wireSize()]) catch unreachable;
        socket.send(self.buffer) catch return NetError.SendFailed;
    }

    pub fn receive(socket: *net.Socket) Error!Package {
        var package = Package{ .header = undefined };

        socket.receive(&package.buffer) catch |err| {
            switch (err) {
                error.ConnectionResetByPeer, error.BrokenPipe => return NetError.ClosedConnection,
                error.WouldBlock => return NetError.WouldBlock,
                else => unreachable,
            }
        };

        package.header = try Header.deserialize(package.buffer[0..Header.wireSize()]);
        package.offset += Header.wireSize();

        if (package.header.magic != Header.MAGIC) {
            return PackageError.GarbargeReceived;
        }

        if (package.header.version != Header.VERSION) {
            return PackageError.VersionMismatch;
        }

        return package;
    }
};
