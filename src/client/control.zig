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

const core = @import("core");
const component = core.component;
const tag = core.tag;
const Model = core.model.Model;

const util = @import("util");
const Client = util.network.Client;

pub const View = @import("view.zig").View;

const ecs = @import("zflecs");

const name = "client";

const NetworkState = struct {
    entities: []ecs.entity_t,
    positions: []const component.Position,
    velocities: []const component.Velocity,
    accelerations: []const component.Acceleration,
};

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: Model,
    view: View,
    client: Client,

    pub fn init(allocator: *std.mem.Allocator) Control {
        const control = Control{
            .allocator = allocator,
            .model = Model.init(allocator),
            .view = View.init(allocator),
            .client = Client.init(allocator),
        };

        std.log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        std.log.info("All your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        self.client.deinit();
        self.model.deinit();
        self.view.deinit();

        std.log.info("stopped sucessfully", .{});
    }

    pub fn update(self: *Control) void {
        self.model.update();
        self.view.update(&self.model);

        if (!self.client.connected) {
            self.client.connect("127.0.0.1", 11111);
        } else {
            //var buffer: [1024]u8 = undefined;
            //const bytesRead = self.client.receive(buffer[0..]) catch {
            //std.log.info("failed to connect", .{});
            //    return;
            //};
            //std.debug.print("Received {} bytes: {s}\n", .{ bytesRead, buffer[0..bytesRead] });

            const msgs = self.client.receive2() catch return;
            defer {
                // Free each message's allocated fields.
                for (msgs) |msg| {
                    // Use @tag() in Zig 0.14 to distinguish variants.
                    switch (msg) {
                        util.message.Message.Chat => |chat| {
                            // Free the allocated text for a ChatMessage.
                            //self.allocator.free(chat.text);
                            chat.deinit(self.allocator);
                        },
                        util.message.Message.Position => {
                            // No dynamic allocation in PositionMessage in this example.
                        },
                        util.message.Message.Velocity => {
                            // No dynamic allocation in VelocityMessage in this example.
                        },
                        util.message.Message.Acceleration => {
                            // No dynamic allocation in AccelerationMessage in this example.
                        },
                    }
                }
                // Free the slice of messages returned by receive2.
                self.allocator.free(msgs);
            }

            // Process messages.
            for (msgs) |msg| {
                switch (msg) {
                    util.message.Message.Chat => |chat| {
                        std.debug.print("Chat: {s}\n", .{chat.text});
                    },
                    util.message.Message.Position => |pos| {
                        std.debug.print("Position: ({}, {})\n", .{ pos.x, pos.y });
                    },
                    util.message.Message.Velocity => |vel| {
                        std.debug.print("Velocity: ({}, {})\n", .{ vel.x, vel.y });
                    },
                    util.message.Message.Acceleration => |acc| {
                        std.debug.print("Acceleration: ({}, {})\n", .{ acc.x, acc.y });
                    },
                }
            }

            // Create a ChatMessage with a literal message.
            const chatMsg = util.message.ChatMessage{
                .text = "Hello you!",
            };

            // Wrap the ChatMessage in the Message union.
            const msg = util.message.Message{ .Chat = chatMsg };

            self.client.send(msg) catch unreachable;
        }
    }

    pub fn shouldStop(self: *Control) bool {
        return self.view.shouldStop();
    }

    fn getNetworkState(self: *Control) void {
        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(component.Position) },
            ecs.term_t{ .id = ecs.id(component.ShipSize) },
            ecs.term_t{ .id = ecs.id(tag.Ship) },
            ecs.term_t{ .id = ecs.id(tag.Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 28;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(self.model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(self.model.world, query);

        while (ecs.query_next(&it)) {
            const position: []const component.Position = ecs.field(&it, component.Position, 0).?;
            const velocities: []const component.ShipSize = ecs.field(&it, component.Velocity, 1).?;
            const accelerations: []const component.ShipSize = ecs.field(&it, component.Acceleration, 1).?;

            for (0..it.count()) |i| {
                const entity = it.entities()[i];

                _ = entity;
            }

            _ = position;
            _ = velocities;
            _ = accelerations;
        }
    }

    fn setNetworkState(self: *Control, state: *const NetworkState) void {
        const count = state.entities.len;
        for (0..count) |i| {
            const entity = state.entities[i];

            if (ecs.is_alive(self.world, entity)) {
                _ = ecs.set(self.world, entity, component.Position, state.positions[i]);
                _ = ecs.set(self.world, entity, component.Velocity, state.velocities[i]);
                _ = ecs.set(self.world, entity, component.Acceleration, state.accelerations[i]);
            }
        }
    }
};
