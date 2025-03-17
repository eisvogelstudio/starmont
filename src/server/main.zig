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
const util = @import("util");
const message = util.message;
const Message = message.Message;
const ChatMessage = message.ChatMessage;
const PositionMessage = message.PositionMessage;
const VelocityMessage = message.VelocityMessage;
const AccelerationMessage = message.AccelerationMessage;

const name = "server";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    var allocator = gpa.allocator();

    var server = try util.network.Server.init(&allocator);
    server.open(11111) catch @panic("failed to open server");

    std.log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
    std.log.info("All your starbase are belong to us.", .{});

    while (true) {
        server.accept() catch {};
        const msgs = server.process(&allocator) catch unreachable;

        defer {
            // Free each message's allocated fields.
            for (msgs) |msg| {
                // Use @tag() in Zig 0.14 to distinguish variants.
                switch (msg) {
                    util.message.Message.Chat => |chat| {
                        // Free the allocated text for a ChatMessage.
                        //self.allocator.free(chat.text);
                        chat.deinit(&allocator);
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
            allocator.free(msgs);
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

        if (server.clients.items.len > 0) {

            // Create a ChatMessage with a literal message.
            const chatMsg = ChatMessage{
                .text = "Hello, Zig!",
            };

            // Wrap the ChatMessage in the Message union.
            const msg = Message{ .Chat = chatMsg };

            server.send2(0, msg) catch unreachable;
        }
    }

    defer server.deinit();
}
