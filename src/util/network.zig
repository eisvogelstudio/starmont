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
// ------------------------------

// ---------- external ----------
const net = @import("network");
// ------------------------------

pub const Error = error{
    EndOfBuffer,
    ClosedConnection,
    NotConnected,
};

const cooldown = 1;

pub const Client = struct {
    allocator: *std.mem.Allocator,
    socket: net.Socket = undefined,
    connected: bool = false,
    stamp: i64 = 0,

    pub fn init(allocator: *std.mem.Allocator) Client {
        const client = Client{
            .allocator = allocator,
        };

        return client;
    }

    pub fn deinit(self: *Client) void {
        self.disconnect();
    }

    pub fn connect(self: *Client, address: []const u8, port: u16) !void {
        if (self.stamp != 0) {
            if (std.time.timestamp() - self.stamp < cooldown) {
                return error.Cooldown;
            }
        }

        self.stamp = std.time.timestamp();

        self.socket = try net.connectToHost(self.allocator.*, address, port, .tcp);

        self.socket.enablePortReuse(true) catch @panic("failed to configure socket");
        self.socket.setReadTimeout(10) catch @panic("failed to configure socket");

        std.log.info("Connected to {s}:{d}\n", .{ address, port });

        self.connected = true;
    }

    pub fn disconnect(self: *Client) void {
        if (self.connected) {
            self.socket.close();

            std.debug.print("Disconnected\n", .{});

            self.connected = false;
        }
    }

    pub fn receive(self: *Client) ![]util.Message {
        const messages = receiveMessages(&self.socket, self.allocator) catch |err| {
            if (err == error.ClosedConnection) {
                self.connected = false;
            }

            return err;
        };

        return messages;
    }

    pub fn send(self: *Client, msg: util.Message) !void {
        try sendMessage(&self.socket, msg);
    }
};

pub const Server = struct {
    allocator: *std.mem.Allocator,
    socket: net.Socket = undefined,
    opened: bool = false,
    clients: std.ArrayList(net.Socket),

    pub fn init(allocator: *std.mem.Allocator) !Server {
        const server = Server{
            .allocator = allocator,
            .clients = std.ArrayList(net.Socket).init(allocator.*),
        };

        return server;
    }

    pub fn deinit(self: *Server) void {
        self.close();
    }

    pub fn open(self: *Server, port: u16) !void {
        self.socket = try net.Socket.create(.ipv4, .tcp);
        try self.socket.enablePortReuse(true);
        try self.socket.bindToPort(port);
        try self.socket.setReadTimeout(10);
        try self.socket.listen();

        std.log.info("Server listening on port {}", .{port});

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

            std.log.info("client #{d} connected", .{self.clients.items.len});
            try self.clients.append(client);
        }
    }

    pub fn receive(self: *Server, allocator: *std.mem.Allocator) ![]util.Message {
        var messages = std.ArrayList(util.Message).init(allocator.*);
        var i: usize = 0;
        while (i < self.clients.items.len) {
            const msg = receiveMessages(&self.clients.items[i], self.allocator) catch |err| {
                if (err == error.ClosedConnection) {
                    _ = self.clients.swapRemove(i);
                    std.log.info("client #{d} disconnected", .{i});
                    i += 1;
                    continue;
                } else if (err == error.WouldBlock) {
                    i += 1;
                    continue;
                } else {
                    return err;
                }
            };
            try messages.appendSlice(msg);
            i += 1;
        }

        if (0 == messages.items.len) {
            return error.WouldBlock;
        }

        return messages.toOwnedSlice();
    }

    pub fn send(self: *Server, client: usize, msg: util.Message) !void {
        try sendMessage(&self.clients.items[client], msg);
    }
};

fn sendMessage(socket: *net.Socket, msg: util.Message) !void {
    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const writer = stream.writer();
    try msg.serialize(writer);
    const data = buffer[0..stream.pos];

    var total: usize = 0;
    while (total < data.len) {
        const bytes_written = try socket.writer().write(data[total..]);
        if (bytes_written == 0) {
            return Error.ClosedConnection;
        }
        total += bytes_written;
    }
}

pub fn receiveMessages(socket: *net.Socket, allocator: *std.mem.Allocator) ![]util.Message {
    var messages = std.ArrayList(util.Message).init(allocator.*);
    var buffer: [1024]u8 = undefined;
    const readResult = socket.reader().read(buffer[0..]);
    if (readResult) |n| {
        if (n == 0) {
            socket.close();
            return error.ClosedConnection;
        } else {
            var stream = std.io.fixedBufferStream(buffer[0..n]);
            const reader = stream.reader();

            while (true) {
                const msg = util.Message.deserialize(reader, allocator) catch {
                    break;
                };
                try messages.append(msg);
            }
        }
    } else |readErr| {
        if (readErr == error.WouldBlock) {
            return error.WouldBlock;
        } else {
            socket.close();
            return error.ClosedConnection;
        }
    }
    return messages.toOwnedSlice();
}
