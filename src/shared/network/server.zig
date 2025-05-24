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

// ---------- external ----------
const net = @import("network");
// ------------------------------

const log = std.log.scoped(.network);

const hz = 10;
const interval = 1000 / hz;

pub const Server = struct {
    allocator: *std.mem.Allocator,
    socket: net.Socket = undefined,
    opened: bool = false,
    clients: std.ArrayList(net.Socket),
    batches: std.ArrayList(Batch),
    last: i64 = 0,

    pub fn init(allocator: *std.mem.Allocator) !Server {
        const server = Server{
            .allocator = allocator,
            .clients = std.ArrayList(net.Socket).init(allocator.*),
            .batches = std.ArrayList(Batch).init(allocator.*),
        };

        net.init() catch unreachable;

        return server;
    }

    pub fn deinit(self: *Server) void {
        self.close();

        net.deinit();

        self.clients.deinit();

        for (self.batches.items) |*b| {
            b.*.deinit();
        }

        self.batches.deinit();
    }

    pub fn update(self: *Server) void {
        const now = std.time.milliTimestamp();

        if (self.last != 0 and (now - self.last) < interval) {
            return;
        }

        self.last = now;

        var i: usize = 0;
        while (i < self.clients.items.len) {
            primitive.send(&self.clients.items[i], self.batches.items[i]) catch continue;
            i += 1;
        }

        for (self.batches.items) |*batch| {
            batch.*.messages.clearRetainingCapacity();
        }
    }

    pub fn open(self: *Server, port: u16) !void {
        self.socket = try net.Socket.create(.ipv4, .tcp);
        try self.socket.enablePortReuse(true);
        try self.socket.bindToPort(port);
        try self.socket.setReadTimeout(10);
        try self.socket.listen();

        log.info("server listening on port {}", .{port});

        self.opened = true;
    }

    pub fn close(self: *Server) void {
        self.socket.close();

        for (self.clients.items) |client| {
            client.close();
        }

        self.clients.deinit();

        self.opened = false;
    }

    pub fn accept(self: *Server) !void {
        while (true) {
            const client = self.socket.accept() catch |err| {
                if (err == error.WouldBlock) {
                    break;
                } else {
                    return err;
                }
            };

            log.info("client #{d} connected", .{self.clients.items.len});
            try self.clients.append(client);
            try self.batches.append(Batch.init(self.allocator));
        }
    }

    pub fn receive(self: *Server, allocator: *std.mem.Allocator) ![]Batch {
        var all = std.ArrayList(Batch).init(allocator.*);
        var i: usize = 0;
        while (i < self.clients.items.len) {
            const batches = primitive.receive(&self.clients.items[i], self.allocator) catch |err| {
                if (err == error.ClosedConnection) {
                    _ = self.clients.swapRemove(i);
                    _ = self.batches.swapRemove(i);
                    log.info("client #{d} disconnected", .{i});
                    //i += 1;
                    continue;
                } else if (err == error.WouldBlock) {
                    i += 1;

                    continue;
                } else {
                    return err;
                }
            };

            for (batches) |*b| {
                b.*.id = i;
            }

            try all.appendSlice(batches);
            i += 1;
        }

        if (0 == all.items.len) {
            return error.WouldBlock;
        }

        return all.toOwnedSlice();
    }

    pub fn submit(self: *Server, client: usize, msg: message.Message) !void {
        try self.batches.items[client].append(msg);
        //try primitive.sendMessage(&self.clients.items[client], msg);
    }
};
