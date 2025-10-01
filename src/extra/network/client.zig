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

// ---------- local ----------
//const Batch = @import("batch.zig").Batch;
const message = @import("message.zig");
const Link = @import("udp.zig").Link;
//const primitive = @import("primitive.zig");
// ---------------------------

const log = std.log.scoped(.network);

const cooldown = 1;

const hz = 10;
const interval = 1000 / hz;

pub const Client = struct {
    gpa: *std.mem.Allocator,
    tcp: net.Socket = undefined,
    udp_link: *Link = undefined,
    is_connected: bool = false,
    stamp: i64 = 0,
    last: i64 = 0,

    pub fn init(gpa: *std.mem.Allocator) Client {
        const client = Client{
            .gpa = gpa,
        };

        net.init() catch unreachable;

        return client;
    }

    pub fn deinit(self: *Client) void {
        self.disconnect();

        net.deinit();
    }

    pub fn update(self: *Client) void {
        if (!self.is_connected) return;

        self.udp_link.submit(.reliabel, message.PingMessage.init(1, 1));
        self.udp_link.update();
        //std.debug.print("update\n", .{});

        while (self.udp_link.withdraw()) |msg| {
            std.debug.print("{any}", .{msg});
        }

        const now = std.time.milliTimestamp();

        if (self.last != 0 and (now - self.last) < interval) {
            return;
        }

        self.last = now;

        //primitive.send(&self.socket, self.batch) catch return;
        //self.batch.messages.clearRetainingCapacity();
    }

    pub fn connect(self: *Client, host: []const u8, port: u16) !void {
        if (self.is_connected) {
            return;
        }

        const now = std.time.timestamp();

        if (self.stamp != 0 and now - self.stamp < cooldown) {
            return error.Cooldown;
        }

        var tcp_socket = try net.connectToHost(self.gpa.*, host, port, .tcp);
        //defer if (!self.is_connected) socket.close();

        tcp_socket.setReadTimeout(100) catch unreachable; // 100ns
        tcp_socket.setWriteTimeout(100) catch unreachable; // 100ns

        self.udp_link = Link.init(self.gpa);
        self.udp_link.endpoint = net.EndPoint.parse("127.0.0.1:22222") catch unreachable;

        self.tcp = tcp_socket;
        self.is_connected = true;
        self.stamp = now;

        log.info("connected to {s}:{d}", .{ host, port });
    }

    pub fn disconnect(self: *Client) void {
        if (!self.is_connected) {
            return;
        }

        self.tcp.close();

        log.info("disconnected\n", .{});

        self.is_connected = false;
    }

    //pub fn receive(self: *Client) ![]Batch {
    //    const batches = primitive.receive(&self.socket, self.gpa) catch |err| {
    //        if (err == error.ClosedConnection) {
    //            self.is_connected = false;
    //        }
    //
    //        return err;
    //    };
    //
    //    return batches;
    //}

    pub fn submit(self: *Client, msg: message.Message) void {
        self.batch.append(msg) catch unreachable;
    }
};
