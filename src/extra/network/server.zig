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
const message = @import("message.zig");
const Link = @import("udp.zig").Link;
// ---------------------------

const log = std.log.scoped(.network);

const hz: u32 = 10;
const interval_ns: u64 = std.time.ns_per_s / hz;

const lag_ms: u32 = 200;
const delay_ms: u32 = lag_ms / 2;

pub const ServerInfo = struct {
    uuid: util.UUID4,
    load: f32,
};

const Address = net.Address;

const Protocol = enum {
    tcp, // for auth
    udp, // for game
};

const State = enum {
    auth_pending,
    connected,
    disconnected,
};

const Session = struct {
    udp_link: *Link,
    tcp: net.Socket,

    const udp_timeout_ns = 1000;
    const udp_try_again_ns = udp_timeout_ns * 10;

    pub fn init(gpa: *std.mem.Allocator, tcp: net.Socket) Session {
        return Session{
            .udp_link = Link.init(gpa),
            .tcp = tcp,
        };
    }

    pub fn update(self: *Session) !void {
        //const now = std.time.microTimestamp();

        self.udp_link.update();
    }

    pub fn deinit(self: *Session) void {
        self.udp_link.deinit();
    }
};

pub const Server = struct {
    gpa: *std.mem.Allocator,

    tcp_listerner: net.Socket = undefined,

    is_open: bool = false,

    sessions: std.AutoHashMap(u64, Session),
    next_id: u64 = 0,

    pub fn init(gpa: *std.mem.Allocator) Server {
        const server = Server{
            .gpa = gpa,
            .sessions = std.AutoHashMap(u64, Session).init(gpa.*),
        };

        net.init() catch unreachable;

        return server;
    }

    pub fn deinit(self: *Server) void {
        if (self.is_open) {
            self.close();
        }

        net.deinit();

        self.sessions.deinit();
    }

    pub fn update(self: *Server) void {
        var it = self.sessions.valueIterator();
        while (it.next()) |connection| {
            connection.update() catch unreachable;
            //connection.tcp.send()
            var found = false;
            while (connection.udp_link.withdraw()) |msg| {
                std.debug.print("{any}", .{msg});
                found = true;
            }

            if (!found) continue;

            connection.udp_link.submit(.reliabel, message.PingMessage.init(1, 1));
            std.debug.print("submit {any}", .{connection.udp_link.outbox.len});
        }
        //self.stage();
        //self.send();

        //self.receive();
        //_ = self;
    }

    fn create_tcp(port: u16) net.Socket {
        var socket: net.Socket = net.Socket.create(.ipv4, .tcp) catch unreachable;
        socket.enablePortReuse(true) catch unreachable;
        socket.bindToPort(port) catch unreachable;
        socket.setReadTimeout(100) catch unreachable;
        socket.setWriteTimeout(100) catch unreachable;

        return socket;
    }

    pub fn getLocalIPv4() ?net.EndPoint {
        // 1) Create a UDP socket (no traffic will be sent)
        var s = net.Socket.create(.ipv4, .udp) catch return null;
        defer s.close();

        // 2) "Connect" to a public address to force route selection (no packets sent)
        //    Any reachable IP/port works; Google DNS is a common choice.
        const dst = net.EndPoint{
            .address = .{ .ipv4 = .init(8, 8, 8, 8) },
            .port = 53,
        };
        s.connect(dst) catch return null;

        // 3) Query the chosen local endpoint
        const lep = s.getLocalEndPoint() catch return null;

        // 4) Format as string for logging/UI
        return lep;
    }

    pub fn open(self: *Server, port: u16) void {
        std.debug.assert(!self.is_open);

        self.tcp_listerner = create_tcp(port);
        self.tcp_listerner.listen() catch unreachable;

        const end = self.tcp_listerner.getLocalEndPoint() catch unreachable;

        log.info("server ip is {}", .{getLocalIPv4().?.address});
        log.info("server listening on tcp port {}", .{end.port});

        self.is_open = true;
    }

    pub fn close(self: *Server) void {
        std.debug.assert(self.is_open);

        self.tcp_listerner.close();
        //self.udp_socket.close();

        log.info("server closed", .{});

        var it = self.sessions.iterator();
        while (it.next()) |entry| {
            //const client = entry.value_ptr.*;
            //client.close();
            _ = entry;
        }

        self.sessions.deinit();

        self.is_open = false;
    }

    pub fn accept(self: *Server) void {
        while (true) {
            const client = self.tcp_listerner.accept() catch |err| {
                if (err == error.WouldBlock) {
                    break;
                } else {
                    unreachable;
                }
            };

            log.info("client #{d} connected", .{self.next_id});

            var connection = Session.init(self.gpa, client);
            connection.update() catch unreachable;

            self.sessions.put(self.next_id, connection) catch unreachable;
            self.next_id += 1;
        }
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
