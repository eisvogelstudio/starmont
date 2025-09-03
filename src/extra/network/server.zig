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

// ---------- external ----------
const net = @import("network");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ----------
const Batch = @import("batch.zig").Batch;
const message = @import("message.zig");
const primitive = @import("primitive.zig");
// ---------------------------

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

const Protocol = enum {
    tcp,
    udp,
};

const Connection = struct {
    is_fallback: bool = false,
    tcp: net.Socket = undefined,
    udp: net.Socket = undefined,
    last_seen_ns: i64 = 0,
    fallback_ns: i64 = 0,

    const udp_timeout_ns = 1000;
    const udp_try_again_ns = udp_timeout_ns * 10;

    pub fn update(self: *Connection) !void {
        const now = std.time.nanoTimestamp();

        if (now - self.last_seen_ns >= udp_timeout_ns) {
            self.is_fallback = true;
            return error.FallbacK;
        } else if (now - self.fallback_ns >= udp_timeout_ns) {
            self.is_fallback = false;
        }
    }

    pub fn send(self: *Connection, protocol: Protocol, data: []const u8) !void {
        try self.update();

        if (protocol == .tcp or self.is_fallback) {
            self.tcp.send(data);
        } else {
            self.udp.send(data);
        }
    }
};

pub const Server = struct {
    gpa: *std.mem.Allocator,
    tcp_listerner: net.Socket = undefined,
    udp_socket: net.Socket = undefined,
    is_open: bool = false,
    connections: std.AutoHashMap(u64, Connection),
    next_id: u64 = 0,
    //batches: std.AutoHashMap(u64, Batch),
    //batchesToSend: std.ArrayList(TimedBatch),
    //batchesReceived: std.ArrayList(TimedBatch),
    last: i64 = 0,

    pub fn init(gpa: *std.mem.Allocator) Server {
        const server = Server{
            .gpa = gpa,
            .connections = std.AutoHashMap(u64, Connection).init(gpa.*),
            //.batches = std.AutoHashMap(u64, Batch).init(gpa.*),
            //.batchesToSend = std.ArrayList(TimedBatch).init(gpa.*),
            //.batchesReceived = std.ArrayList(TimedBatch).init(gpa.*),
        };

        net.init() catch unreachable;

        return server;
    }

    pub fn deinit(self: *Server) void {
        if (self.is_open) {
            self.close();
        }

        net.deinit();

        //self.batchesReceived.deinit();
        //self.batchesToSend.deinit();
        //self.batches.deinit();

        self.connections.deinit();
    }

    pub fn update(self: *Server) void {
        self.stage();
        self.send();

        self.receive();
    }

    fn create_tcp(port: u16) net.Socket {
        var socket: net.Socket = net.Socket.create(.ipv4, .tcp) catch unreachable;
        socket.enablePortReuse(true) catch unreachable;
        socket.bindToPort(port) catch unreachable;
        socket.setReadTimeout(100) catch unreachable; // 100ns
        socket.setWriteTimeout(100) catch unreachable; // 100ns
        socket.listen() catch unreachable;

        return socket;
    }

    fn create_udp(port: u16) net.Socket {
        var socket: net.Socket = net.Socket.create(.ipv4, .udp) catch unreachable;
        socket.enablePortReuse(true) catch unreachable;
        socket.bindToPort(port) catch unreachable;
        socket.setReadTimeout(100) catch unreachable; // 100ns
        socket.setWriteTimeout(100) catch unreachable; // 100ns

        return socket;
    }

    pub fn open(self: *Server, port: u16) void {
        std.debug.assert(!self.is_open);

        log.info("server ip is {}", .{self.tcp_listerner.endpoint.?.address});

        self.tcp_listerner = create_tcp(port);
        log.info("server listening on tcp port {}", .{self.tcp_listerner.endpoint.?.port});

        self.udp_socket = create_udp(0);
        log.info("server listening on udp port {}", .{self.udp_socket.endpoint.?.port});

        self.is_open = true;
    }

    pub fn close(self: *Server) void {
        std.debug.assert(self.is_open);

        self.tcp_listerner.close();
        self.udp_socket.close();

        log.info("server closed", .{});

        var it = self.connections.iterator();
        while (it.next()) |entry| {
            //const client = entry.value_ptr.*;
            //client.close();
            _ = entry;
        }

        self.connections.deinit();

        self.is_open = false;
    }

    pub fn tcp_accept(self: *Server) void {
        while (true) {
            const client = self.tcp_listerner.accept() catch |err| {
                if (err == error.WouldBlock) {
                    break;
                } else {
                    unreachable;
                }
            };

            log.info("client #{d} connected", .{self.next_id});
            self.connections.put(self.next_id, client) catch unreachable;
            self.batches.put(self.next_id, Batch.init(self.gpa)) catch unreachable;
            self.next_id += 1;
        }
    }

    fn receive(self: *Server) void {
        const now = std.time.milliTimestamp();

        var delete = std.ArrayList(u64).init(self.gpa.*);

        var it = self.connections.iterator();
        while (it.next()) |entry| {
            var client = entry.value_ptr.*;

            const batches = primitive.receive(&client, self.gpa) catch |err| {
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
            _ = self.connections.remove(key);
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

        var it = self.connections.iterator();
        while (it.next()) |entry| {
            self.batches.getPtr(entry.key_ptr.*).?.id = entry.key_ptr.*;

            const timedBatch = TimedBatch{ .batch = self.batches.getPtr(entry.key_ptr.*).?.copy(self.gpa), .stamp = now };

            self.batchesToSend.append(timedBatch) catch unreachable;

            self.batches.getPtr(entry.key_ptr.*).?.clear();
        }
    }

    fn send(self: *Server) void {
        const now = std.time.milliTimestamp();

        var delete = std.ArrayList(usize).init(self.gpa.*);

        for (self.batchesToSend.items, 0..) |*timedBatch, i| {
            if (now - timedBatch.*.stamp < delay) {
                continue;
            }

            if (self.connections.getPtr(timedBatch.*.batch.id)) |id| {
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

    pub fn withdraw(self: *Server, gpa: *std.mem.Allocator) ![]Batch {
        const now = std.time.milliTimestamp();
        var all = std.ArrayList(Batch).init(gpa.*);

        for (self.batchesReceived.items) |*timedBatch| {
            if (now - timedBatch.*.stamp < delay) {
                all.append(timedBatch.*.batch.copy(self.gpa)) catch unreachable;
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

    pub fn getPort(self: *Server) ?u16 {
        if (self.tcp_listerner.endpoint) |end| {
            return end.port;
        }
    }

    pub fn getAddress(self: *Server, gpa: std.mem.Allocator) ?[]const u8 {
        if (self.tcp_listerner.endpoint) |end| {
            return std.fmt.allocPrint(gpa, "{}", .{end.address}) catch null;
        }
        return null;
    }
};
