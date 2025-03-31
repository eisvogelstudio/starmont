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

pub const Client = struct {
    allocator: *std.mem.Allocator,
    socket: net.Socket = undefined,
    connected: bool = false,

    pub fn init(allocator: *std.mem.Allocator) Client {
        const client = Client{
            .allocator = allocator,
        };

        return client;
    }

    pub fn deinit(self: *Client) void {
        self.disconnect();
    }

    pub fn connect(self: *Client, address: []const u8, port: u16) void {
        self.socket = net.connectToHost(self.allocator.*, address, port, .tcp) catch {
            //std.log.warn("Connection failed: {s}\n", .{@errorName(err)});
            return;
        };

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
        var buffer: [1024]u8 = undefined;
        if (self.connected) {
            const available = try self.socket.peek(&buffer);

            if (available == 0) {
                const n = try self.socket.reader().read(&buffer);
                if (n == 0) {
                    std.debug.print("Socket closed by server.\n", .{});
                    self.disconnect();
                    return error.ClosedConnection;
                }
                return receiveMessages(&self.socket, self.allocator);
            }

            const n = try self.socket.reader().read(buffer[0..available]);
            if (n == 0) {
                std.debug.print("Socket closed by server.\n", .{});
                self.disconnect();
                return error.ClosedConnection;
            }
            return receiveMessages(&self.socket, self.allocator);
        } else {
            return error.NotConnected;
        }
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

        std.log.info("Server listening on port {}\n", .{port});

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
        const client = self.socket.accept() catch |err| {
            if (err == error.WouldBlock) {
                return;
            } else {
                return err;
            }
        };
        self.clients.append(client) catch unreachable;
        std.log.info("Client connected\n", .{});
    }

    pub fn receive(self: *Server, allocator: *std.mem.Allocator) ![]util.Message {
        var messages = std.ArrayList(util.Message).init(allocator.*);
        var i: usize = 0;
        while (i < self.clients.items.len) {
            const client = self.clients.items[i];
            var buffer: [1024]u8 = undefined;
            const readResult = client.reader().read(buffer[0..]);
            if (readResult) |n| {
                if (n == 0) {
                    std.debug.print("Client disconnected\n", .{});
                    client.close();
                    _ = self.clients.swapRemove(i);
                    continue;
                } else {
                    std.debug.print("Received {d} bytes from client\n", .{n});
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
                    i += 1;
                    continue;
                } else {
                    std.debug.print("Client read error: {any}, removing client.\n", .{readErr});
                    client.close();
                    _ = self.clients.swapRemove(i);
                    continue;
                }
            }
            i += 1;
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
    var buffer: [1024]u8 = undefined;
    const bytes_read = try socket.reader().read(buffer[0..]);
    if (bytes_read == 0) {
        return Error.ClosedConnection;
    }
    var stream = std.io.fixedBufferStream(buffer[0..bytes_read]);
    const reader = stream.reader();

    var messages = std.ArrayList(util.Message).init(allocator.*);
    while (true) {
        const msg = util.Message.deserialize(reader, allocator) catch {
            break;
        };
        try messages.append(msg);
    }

    return messages.toOwnedSlice();
}
