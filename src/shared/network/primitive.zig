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
const Batch = @import("batch.zig").Batch;
// -----------------------------

// ---------- external ----------
const net = @import("network");
// ------------------------------

pub const Error = error{
    ConnectionResetByPeer,
    ClosedConnection,
    WouldBlock,
};

pub fn send(socket: *net.Socket, batch: Batch) !void {
    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const writer = stream.writer();
    batch.serialize(writer);

    const data = buffer[0..stream.pos];
    var total: usize = 0;
    while (total < data.len) {
        const bytes_written = socket.writer().write(data[total..]) catch |err| {
            switch (err) {
                error.ConnectionResetByPeer, error.BrokenPipe => return Error.ClosedConnection,
                error.WouldBlock => return Error.WouldBlock,
                else => return err,
            }
        };
        if (bytes_written == 0) {
            return Error.ClosedConnection;
        }
        total += bytes_written;
    }
}

pub fn receive(socket: *net.Socket, allocator: *std.mem.Allocator) ![]Batch {
    var batches = std.ArrayList(Batch).init(allocator.*);
    var buffer: [1024]u8 = undefined;
    const readResult = socket.reader().read(buffer[0..]);
    if (readResult) |n| {
        if (n == 0) {
            socket.close();
            return error.ClosedConnection;
        } else {
            var stream = std.io.fixedBufferStream(buffer[0..n]);
            const reader = stream.reader();

            while (stream.pos > stream.buffer.len) {
                const msg = Batch.deserialize(reader, allocator);
                try batches.append(msg);
            }
        }
    } else |readErr| {
        if (readErr == error.WouldBlock) {
            return Error.WouldBlock;
        } else {
            socket.close();
            return Error.ClosedConnection;
        }
    }
    return batches.toOwnedSlice();
}
