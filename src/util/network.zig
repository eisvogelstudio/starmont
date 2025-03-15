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

const std = @import("std");
const testing = std.testing;

const znet = @import("network");

const MyError = error{
    NotConnected,
};

pub const Client = struct {
    /// Optionally holds an active socket; nil means not connected.
    sock: ?znet.Socket,
    allocator: *std.mem.Allocator,
    serverAddress: []const u8,
    port: u16,
    connected: bool = false,

    /// Create a new client instance. Does not connect yet.
    pub fn init(allocator: *std.mem.Allocator, serverAddress: []const u8, port: u16) Client {
        return Client{
            .sock = null,
            .allocator = allocator,
            .serverAddress = serverAddress,
            .port = port,
        };
    }

    /// Clean up resources. Closes any open connection.
    pub fn deinit(self: *Client) void {
        self.disconnect();
    }

    /// Connects to the remote server. Enables port reuse after connection.
    pub fn connect(self: *Client) !void {
        self.sock = znet.connectToHost(self.allocator.*, self.serverAddress, self.port, .tcp) catch |err| {
            std.debug.print("Client connection failed: {s}\n", .{@errorName(err)});
            return err;
        };
        try self.sock.?.enablePortReuse(true);
        try self.sock.?.setReadTimeout(10);
        std.debug.print("Client connected to {s}:{d}\n", .{ self.serverAddress, self.port });
        self.connected = true;
    }

    /// Disconnects from the server if connected.
    pub fn disconnect(self: *Client) void {
        if (self.sock) |s| {
            s.close();
            self.sock = null;
            std.debug.print("Client disconnected\n", .{});
            self.connected = false;
        }
    }

    /// Sends data to the server.
    pub fn send(self: *Client, data: []const u8) !void {
        if (self.sock) |s| {
            try s.writer().writeAll(data);
        } else {
            return MyError.NotConnected;
        }
    }

    /// Receives data into the provided buffer.
    /// First checks if data is available using peek(), then performs a non-blocking read.
    pub fn receive(self: *Client, buffer: []u8) !usize {
        if (self.sock) |s| {
            // Use peek to check for available data.
            const available = s.peek(buffer) catch |err| {
                std.debug.print("err1: {}\n", .{err});
                return err;
            };

            if (available == 0) {
                // No data is immediately available.
                // Do an actual read to check if the socket is closed.
                const n = s.reader().read(buffer) catch |err| {
                    std.debug.print("read error: {}\n", .{err});
                    return err;
                };
                if (n == 0) {
                    std.debug.print("Socket closed by server.\n", .{});
                    self.disconnect();
                    return error.ClosedConnection;
                }
                return n;
            }

            // If peek indicated data is available, read exactly that many bytes.
            const n = s.reader().read(buffer[0..available]) catch |err| {
                return err;
            };
            if (n == 0) {
                std.debug.print("Socket closed by server.\n", .{});
                self.disconnect();
                return error.ClosedConnection;
            }
            return n;
        } else {
            self.disconnect();
            return MyError.NotConnected;
        }
    }
};

pub const Server = struct {
    sock: znet.Socket,
    port: u16,
    allocator: *std.mem.Allocator,
    clients: std.ArrayList(znet.Socket),

    /// Initializes the server: creates a TCP socket, enables port reuse, binds, listens,
    /// and sets the socket to non-blocking mode.
    pub fn init(allocator: *std.mem.Allocator, port: u16) !Server {
        var s = try znet.Socket.create(.ipv4, .tcp);
        try s.enablePortReuse(true);
        try s.bindToPort(port);
        try s.listen();
        try s.setReadTimeout(10);
        // Set the server socket to non-blocking so that accept() returns immediately.
        //try s.setBlocking(false);
        std.debug.print("Server listening on port {}\n", .{port});
        return Server{
            .sock = s,
            .port = port,
            .allocator = allocator,
            .clients = std.ArrayList(znet.Socket).init(allocator.*),
        };
    }

    /// Closes the server and all client sockets.
    pub fn close(self: *Server) void {
        self.sock.close();
        // Close each client socket.
        for (self.clients.items) |client| {
            client.close();
        }
        self.clients.deinit();
    }

    /// Clean up resources.
    pub fn deinit(self: *Server) void {
        self.close();
    }

    pub fn run(self: *Server) !void {
        while (true) {
            // Try to accept a new connection.
            // If no connection is pending, accept() may return an error like EAGAIN.
            const newClientResult = self.sock.accept();
            if (newClientResult) |newClient| {
                // Optionally set the client socket to non-blocking mode.
                // try newClient.setBlocking(false);
                try self.clients.append(newClient);
                std.debug.print("Accepted new client. Total clients: {d}\n", .{self.clients.items.len});
            } else |err| {
                // Only log unexpected errors; if it's EAGAIN (or similar), no connection is waiting.
                if (err != error.EAGAIN) {
                    std.debug.print("Accept error: {any}\n", .{err});
                    continue;
                }
            }

            // Process each connected client.
            var i: usize = 0;
            while (i < self.clients.items.len) {
                const client = self.clients.items[i];
                var buffer: [1024]u8 = undefined;
                const readResult = client.reader().read(&buffer);
                if (readResult) |n| {
                    if (n == 0) {
                        std.debug.print("Client disconnected, removing client.\n", .{});
                        // Close the client socket and remove it from the list.
                        client.close();
                        //self.clients.items.swapRemove(i);
                        _ = self.clients.swapRemove(i);
                        // Don't increment i because the last client has been swapped in.
                        continue;
                    } else {
                        std.debug.print("Received {d} bytes from client: {s}\n", .{ n, buffer[0..n] });
                    }
                } else |readErr| {
                    // For non-blocking sockets, EAGAIN (or equivalent) means no data available right now.
                    if (readErr == error.WouldBlock) {
                        continue;
                    }

                    if (readErr == error.EAGAIN) {
                        // No data; simply move on to the next client.
                        i += 1;
                        continue;
                    } else {
                        std.debug.print("Client read error: {any}, removing client.\n", .{readErr});
                        client.close();
                        //self.clients.items.swapRemove(i);
                        continue;
                    }
                }
                i += 1;
            }

            // Sleep or yield to avoid busy looping.
            //std.time.sleep(100 * std.time.millisecond);
        }
    }
};
