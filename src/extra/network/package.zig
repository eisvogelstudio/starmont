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
const Message = @import("message.zig").Message;
const Channel = @import("message.zig").Channel;
const serial = @import("serial/serial.zig");
// ---------------------------

fn magicFrom(tag: []const u8) comptime_int {
    @setEvalBranchQuota(10_000);
    var out: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(tag, &out, .{});
    return std.mem.readInt(u32, out[0..4], .big);
}

pub const PackageError = error{
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

pub const Ack = struct {
    head: u16 = 0,
    bits: u32 = 0,

    pub fn markReceived(self: *Ack, seq: u16) void {
        if (util.seqGreater(u16, seq, self.head)) {
            const shift = seq - self.head;
            if (shift >= 32) {
                self.bits = 1;
            } else {
                self.bits = (self.bits << shift) | 1;
            }
            self.head = seq;
        } else {
            const diff = self.head - seq;
            if (diff < 32) {
                self.bits |= (1 << diff);
            }
        }
    }

    pub fn wireSize() usize {
        return serial.wireSizeU16() + serial.wireSizeU32();
    }

    pub fn serialize(self: Ack, buffer: []u8) !void {
        try serial.serializeU16(self.head, buffer);
        try serial.serializeU32(self.bits, buffer);
    }

    pub fn deserialize(buffer: []const u8) Ack {
        return Ack{
            .head = serial.deserializeU16(buffer) catch unreachable,
            .bits = serial.deserializeU32(buffer) catch unreachable,
        };
    }

    pub fn isAcked(self: Ack, seq: u16) bool {
        if (seq == self.head) return true;
        if (util.seqGreater(u16, seq, self.head)) return false;

        const diff = self.head - seq;
        if (diff >= 32) return false;
        return (self.bits & (1 << diff)) != 0;
    }
};

pub const Header = struct {
    magic: u32,
    version: u8,
    channel: Channel,
    sequence: u16,
    ack: Ack,

    pub const MAGIC: u32 = magicFrom("all your starbase are belong to us");
    pub const VERSION = 1;

    pub fn wireSize() usize {
        return serial.wireSizeU32() + serial.wireSizeU8() + serial.wireSizeEnum(Channel) + serial.wireSizeU16() + Ack.wireSize();
    }

    pub fn serialize(self: *const Header, buffer: []u8) serial.SerializeError!void {
        var off: usize = 0;

        try serial.serializeU32(self.magic, buffer[off..]);
        off += serial.wireSizeU32();

        try serial.serializeU8(self.version, buffer[off..]);
        off += serial.wireSizeU8();

        try serial.serializeEnum(Channel, self.channel, buffer[off..]);
        off += serial.wireSizeEnum(Channel);

        try serial.serializeU16(self.sequence, buffer[off..]);
        off += serial.wireSizeU16();

        try self.ack.serialize(buffer[off..]);
        off += Ack.wireSize();

        std.debug.assert(wireSize() == off);
    }

    pub fn deserialize(buffer: []const u8) serial.DeserializeError!Header {
        var header: Header = undefined;
        var off: usize = 0;

        header.magic = try serial.deserializeU32(buffer[off..]);
        off += serial.wireSizeU32();

        header.version = try serial.deserializeU8(buffer[off..]);
        off += serial.wireSizeU8();

        header.channel = try serial.deserializeEnum(Channel, buffer[off..]);
        off += serial.wireSizeEnum(Channel);

        header.sequence = try serial.deserializeU16(buffer[off..]);
        off += serial.wireSizeU16();

        header.ack = Ack.deserialize(buffer[off..]);
        off += Ack.wireSize();

        std.debug.assert(wireSize() == off);

        return header;
    }
};

pub const Identifier = packed struct {
    sequence: u16,
    channel: Channel,

    pub fn successor(self: Identifier) Identifier {
        return Identifier{ .sequence = self.sequence +| 1, .channel = self.channel };
    }

    pub fn equals(self: Identifier, other: Identifier) bool {
        return self.channel == other.channel and self.sequence == other.sequence;
    }
};

pub const TimedIdentifier = struct {
    until_us: i64,
    ident: Identifier,
};

pub const TimedPackage = struct {
    until_us: i64,
    ident: Identifier,
    package: Package,
};

pub const Package = struct {
    msg_count: u8 = 0,
    buffer: [max_byte]u8 = undefined,
    offset: usize = reserved,

    const reserved = Header.wireSize() + serial.wireSizeU8();

    pub const max_byte = 1200;

    pub fn init() Package {
        return Package{};
    }

    pub fn wireSize(self: Package) usize {
        return self.offset;
    }

    pub fn append(self: *Package, msg: Message) PackageError!void {
        const size = msg.wireSize();
        if (max_byte - self.offset < size) return PackageError.OutOfSpace;
        msg.serialize(self.buffer[self.offset .. self.offset + size]) catch unreachable;
        self.offset += size;

        self.msg_count += 1;
    }

    pub fn pop(self: *Package, gpa: *std.mem.Allocator) !Message {
        if (self.msg_count == 0) return PackageError.Empty;

        self.msg_count -= 1;

        const slice = self.buffer[self.offset..];

        const msg = try Message.deserialize(slice, gpa);
        self.offset += msg.wireSize();

        std.debug.assert(self.offset <= max_byte);

        return msg;
    }

    fn prepare(self: *Package, identifier: Identifier, ack: Ack) void {
        const header = Header{
            .magic = Header.MAGIC,
            .version = Header.VERSION,
            .channel = identifier.channel,
            .sequence = identifier.sequence,
            .ack = ack,
        };

        header.serialize(self.buffer[0..Header.wireSize()]) catch unreachable;
        serial.serializeU8(self.msg_count, self.buffer[Header.wireSize() .. Header.wireSize() + serial.wireSizeU8()]) catch unreachable;
    }

    pub fn sendTo(self: *Package, identifier: Identifier, ack: Ack, socket: *net.Socket, endpoint: net.EndPoint) NetError!void {
        self.prepare(identifier, ack);

        _ = socket.sendTo(endpoint, self.buffer[0..self.offset]) catch return NetError.SendFailed;
    }

    pub fn send(self: *Package, identifier: Identifier, ack: Ack, socket: *net.Socket) NetError!void {
        self.prepare(identifier, ack);

        _ = socket.send(self.buffer[0..self.offset]) catch return NetError.SendFailed;
    }

    const Result = struct {
        sender: net.EndPoint,
        package: Package,
    };

    pub fn receive(socket: *net.Socket) Error!Result {
        var package = Package{};

        const result = socket.receiveFrom(&package.buffer) catch |err| {
            switch (err) {
                error.WouldBlock => return NetError.WouldBlock,
                else => unreachable,
            }
        };

        if (result.numberOfBytes < reserved) return Error.GarbargeReceived;

        package.msg_count = try serial.deserializeU8(package.buffer[Header.wireSize() .. Header.wireSize() + serial.wireSizeU8()]);

        return Result{ .sender = result.sender, .package = package };
    }

    pub fn receiveFrom(socket: *net.Socket) Error!Result {
        var package = Package{};

        const result = socket.receiveFrom(&package.buffer) catch |err| {
            switch (err) {
                error.WouldBlock => return NetError.WouldBlock,
                else => unreachable,
            }
        };

        if (result.numberOfBytes < reserved) return Error.GarbargeReceived;

        package.msg_count = try serial.deserializeU8(package.buffer[Header.wireSize() .. Header.wireSize() + serial.wireSizeU8()]);

        return Result{ .sender = result.sender, .package = package };
    }

    pub fn deserializeHeader(self: Package) Error!Header {
        std.debug.assert(self.buffer.len > reserved);

        const header = try Header.deserialize(self.buffer[0..Header.wireSize()]);

        if (header.magic != Header.MAGIC) {
            return PackageError.GarbargeReceived;
        }

        if (header.version != Header.VERSION) {
            return PackageError.VersionMismatch;
        }

        return header;
    }
};

//const buffer_size = 4096;

//pub fn send(socket: *net.Socket, batch: Batch) !void {
//    var buffer: [buffer_size]u8 = undefined;
//    var stream = std.io.fixedBufferStream(&buffer);
//    const writer = stream.writer();
//    batch.serialize(writer);
//
//    const data = buffer[0..stream.pos];
//    var total: usize = 0;
//    while (total < data.len) {
//        const bytes_written = socket.writer().write(data[total..]) catch |err| {
//            switch (err) {
//                error.ConnectionResetByPeer, error.BrokenPipe => return Error.ClosedConnection,
//                error.WouldBlock => return Error.WouldBlock,
//                else => return err,
//            }
//        };
//        if (bytes_written == 0) {
//            return Error.ClosedConnection;
//        }
//        total += bytes_written;
//    }
//}
//
//pub fn receive(socket: *net.Socket, gpa: *std.mem.Allocator) ![]Batch {
//    var batches = std.ArrayList(Batch).init(gpa.*);
//    var buffer: [buffer_size]u8 = undefined;
//    const readResult = socket.reader().read(buffer[0..]);
//    if (readResult) |n| {
//        if (n == 0) {
//            socket.close();
//            return error.ClosedConnection;
//        } else {
//            var stream = std.io.fixedBufferStream(buffer[0..n]);
//            const reader = stream.reader();
//
//            while (stream.pos < stream.buffer.len) {
//                std.log.info("HELLO", .{});
//                const msg = Batch.deserialize(reader, gpa);
//                try batches.append(msg);
//            }
//        }
//    } else |readErr| {
//        if (readErr == error.WouldBlock) {
//            return Error.WouldBlock;
//        } else {
//            socket.close();
//            return Error.ClosedConnection;
//        }
//    }
//    return batches.toOwnedSlice();
//}
