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
const Batch = @import("batch.zig").Batch;
const message = @import("message.zig");
const primitive = @import("primitive.zig");
// -----------------------------

// ---------- shared ----------
const util = @import("../util/root.zig");
// ----------------------------

// ---------- external ----------
const net = @import("network");
// ------------------------------

const log = std.log.scoped(.network);

const hz = 10;
const interval = 1000 / hz;

const lag_ms = 200;
const delay = lag_ms / 2;

pub const ServerInfo = struct {
    uuid: util.UUID4,
    load: f32,
};

const TimedBatch = struct {
    batch: Batch,
    stamp: i64,
};

pub const Server = struct {
    allocator: *std.mem.Allocator,
    socket: net.Socket = undefined,
    opened: bool = false,
    clients: std.AutoHashMap(u64, net.Socket),
    batches: std.AutoHashMap(u64, Batch),
    batchesToSend: std.ArrayList(TimedBatch),
    batchesReceived: std.ArrayList(TimedBatch),
    last: i64 = 0,
    identifier: u64 = 0,

    pub fn init(allocator: *std.mem.Allocator) Server {
        const server = Server{
            .allocator = allocator,
            .clients = std.AutoHashMap(u64, net.Socket).init(allocator.*),
            .batches = std.AutoHashMap(u64, Batch).init(allocator.*),
            .batchesToSend = std.ArrayList(TimedBatch).init(allocator.*),
            .batchesReceived = std.ArrayList(TimedBatch).init(allocator.*),
        };

        net.init() catch unreachable;

        return server;
    }

    pub fn deinit(self: *Server) void {
        self.close();

        net.deinit();

        self.batchesReceived.deinit();
        self.batchesToSend.deinit();

        self.batches.deinit();
        self.clients.deinit();
    }

    pub fn update(self: *Server) void {
        self.stage();
        self.send();

        self.receive();
    }

    pub fn open(self: *Server, port: u16) void {
        self.socket = net.Socket.create(.ipv4, .tcp) catch unreachable;
        self.socket.enablePortReuse(true) catch unreachable;
        self.socket.bindToPort(port) catch unreachable;
        self.socket.setReadTimeout(100) catch unreachable; // 100ns
        self.socket.setWriteTimeout(100) catch unreachable; // 100ns

        self.socket.listen() catch unreachable;

        log.info("server listening on port {}", .{port});

        self.opened = true;
    }

    pub fn close(self: *Server) void {
        self.socket.close();

        var it = self.clients.iterator();
        while (it.next()) |entry| {
            const client = entry.value_ptr.*;
            client.close();
        }

        self.clients.deinit();

        self.opened = false;
    }

    pub fn accept(self: *Server) void {
        while (true) {
            const client = self.socket.accept() catch |err| {
                if (err == error.WouldBlock) {
                    break;
                } else {
                    unreachable;
                }
            };

            log.info("client #{d} connected", .{self.identifier});
            self.clients.put(self.identifier, client) catch unreachable;
            self.batches.put(self.identifier, Batch.init(self.allocator)) catch unreachable;
            self.identifier += 1;
        }
    }

    fn receive(self: *Server) void {
        const now = std.time.milliTimestamp();

        var delete = std.ArrayList(u64).init(self.allocator.*);

        var it = self.clients.iterator();
        while (it.next()) |entry| {
            var client = entry.value_ptr.*;

            const batches = primitive.receive(&client, self.allocator) catch |err| {
                if (err == error.ClosedConnection) {
                    delete.append(entry.key_ptr.*) catch unreachable;
                    continue;
                } else if (err == error.WouldBlock) {
                    continue;
                } else {
                    unreachable;
                }
            };

            for (batches) |*b| {
                b.*.id = entry.key_ptr.*;

                const timedBatch = TimedBatch{ .batch = b.*, .stamp = now };

                self.batchesReceived.append(timedBatch) catch unreachable;
            }
        }

        for (delete.items) |key| {
            _ = self.clients.remove(key);
            _ = self.batches.remove(key);
            log.info("client #{d} disconnected", .{key});
        }

        delete.deinit();
    }

    fn stage(self: *Server) void {
        const now = std.time.milliTimestamp();

        if (self.last != 0 and (now - self.last) < interval) {
            return;
        }

        self.last = now;

        var it = self.clients.iterator();
        while (it.next()) |entry| {
            self.batches.getPtr(entry.key_ptr.*).?.id = entry.key_ptr.*;

            const timedBatch = TimedBatch{ .batch = self.batches.getPtr(entry.key_ptr.*).?.copy(self.allocator), .stamp = now };

            self.batchesToSend.append(timedBatch) catch unreachable;

            self.batches.getPtr(entry.key_ptr.*).?.clear();
        }
    }

    fn send(self: *Server) void {
        const now = std.time.milliTimestamp();

        var delete = std.ArrayList(usize).init(self.allocator.*);

        for (self.batchesToSend.items, 0..) |*timedBatch, i| {
            if (now - timedBatch.*.stamp < delay) {
                continue;
            }

            if (self.clients.getPtr(timedBatch.*.batch.id)) |id| {
                primitive.send(id, timedBatch.*.batch) catch continue;
            } else {
                continue;
            }

            timedBatch.*.batch.deinit();

            delete.append(i) catch unreachable;
        }

        for (delete.items, 0..) |index, i| {
            _ = self.batchesToSend.swapRemove(index - i);
        }

        delete.deinit();
    }

    pub fn withdraw(self: *Server, allocator: *std.mem.Allocator) ![]Batch {
        const now = std.time.milliTimestamp();
        var all = std.ArrayList(Batch).init(allocator.*);

        for (self.batchesReceived.items) |*timedBatch| {
            if (now - timedBatch.*.stamp < delay) {
                all.append(timedBatch.*.batch.copy(self.allocator)) catch unreachable;
            }
        }

        if (0 == all.items.len) {
            return error.WouldBlock;
        }

        return all.toOwnedSlice() catch unreachable;
    }

    pub fn submit(self: *Server, client: usize, msg: message.Message) !void {
        self.batches.getPtr(client).?.append(msg) catch unreachable;
    }
};
