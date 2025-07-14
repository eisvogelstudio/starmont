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

// ---------- shared ----------
const ServerId = @import("shared").network.ServerId;
const ServerInfo = @import("shared").network.ServerInfo;
// ----------------------------

pub const ServerRegistry = struct {
    allocator: *std.mem.Allocator,
    servers: std.ArrayList(ServerInfo),

    pub fn init(allocator: *std.mem.Allocator) !ServerRegistry {
        return ServerRegistry{
            .allocator = allocator,
            .servers = try std.ArrayList(ServerInfo).initCapacity(allocator.*, 8),
        };
    }

    pub fn deinit(self: *ServerRegistry) void {
        self.servers.deinit();
    }

    pub fn getLeastLoaded(self: *ServerRegistry) ServerInfo {
        if (self.servers.items.len == 0) {
            unreachable;
        }

        var min = self.servers.items[0];
        for (self.servers.items) |server| {
            if (server.load < min.load) {
                min = server;
            }
        }
        return min;
    }

    pub fn getServerBelowThreshold(self: *ServerRegistry, threshold: f32) ?ServerInfo {
        for (self.servers.items) |server| {
            if (server.load < threshold) {
                return server;
            }
        }
        return null;
    }

    pub fn get(self: *ServerRegistry, id: ServerId) ?ServerInfo {
        for (self.servers.items) |server| {
            if (server.id == id) return server;
        }
        return null;
    }

    pub fn update(self: *ServerRegistry, id: ServerId, load: f32) !void {
        for (self.servers.items) |*server| {
            if (server.id.id == id.id) {
                server.load = load;
                return;
            }
        }
        try self.servers.append(ServerInfo{ .id = id, .load = load });
    }
};
