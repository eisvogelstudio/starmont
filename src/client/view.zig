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

const ecs = @import("zflecs");
const rl = @import("raylib");
const rg = @import("raygui");

const component = core.component;
const tag = core.tag;
const Model = core.model.Model;

pub const View = struct {
    allocator: *std.mem.Allocator,
    player: ecs.entity_t = 0,

    const screenWidth = 800;
    const screenHeight = 450;

    pub fn init(allocator: *std.mem.Allocator) View {
        const view = View{
            .allocator = allocator,
        };

        rl.setTraceLogLevel(rl.TraceLogLevel.warning);

        rl.initWindow(screenWidth, screenHeight, core.name ++ " v" ++ core.version);

        rl.setTargetFPS(60);

        return view;
    }

    pub fn deinit(self: *View) void {
        _ = self;
        rl.closeWindow();
    }

    pub fn update(self: *View, model: *Model) void {
        self.renderShips(model);
        self.renderPlayers(model);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        const text = "Welcome to " ++ core.name ++ " - till the stars and far beyond";
        const fontSize = 20;

        const textWidth = rl.measureText(text, fontSize);
        const textHeight = fontSize;
        const x = @divTrunc((screenWidth - textWidth), 2);
        const y = @divTrunc((screenHeight - textHeight), 2);

        rl.drawText(text, x, y, fontSize, rl.Color.light_gray);

        var buttonPressed = false;
        var sliderValue: f32 = 50.0;

        if (rg.guiButton(rl.Rectangle{ .x = 10, .y = 10, .width = 150, .height = 30 }, "Click Me") != 0) {
            buttonPressed = !buttonPressed;

            self.player = model.createPlayer();
        }
        _ = rg.guiSlider(rl.Rectangle{ .x = 10, .y = 50, .width = 200, .height = 20 }, "Size", "{:.2}", &sliderValue, 0.0, 100.0);
        if (buttonPressed) {
            rl.drawText("Button Pressed!", 200, 10, 20, rl.Color.red);
        }

        if ((sliderValue > 80) or (sliderValue < 20)) {
            rl.drawText("AHHHHHH!", 300, 60, 20, rl.Color.red);
            const other = model.createPlayer();
            _ = ecs.set(model.world, other, component.Acceleration, .{ .x = -20, .y = 20 });
        }

        const Vec = struct { x: f32 = 0.0, y: f32 = 0.0 };

        if (self.player != 0) {
            if (!ecs.is_alive(model.world, self.player)) return;

            const accelerationRate: Vec = .{ .x = 400, .y = 300 }; // Acceleration growth per frame
            const decelerationRate: Vec = .{ .x = 1000, .y = 600 }; // Deceleration when key is released

            var playerAcceleration: Vec = .{ .x = 0, .y = 0 };

            // Modify acceleration based on key input
            if (rl.isKeyDown(rl.KeyboardKey.w)) {
                playerAcceleration.y -= accelerationRate.y;
            } else if (playerAcceleration.y < 0) {
                playerAcceleration.y += decelerationRate.y;
                if (playerAcceleration.y > 0) playerAcceleration.y = 0;
            }

            if (rl.isKeyDown(rl.KeyboardKey.s)) {
                playerAcceleration.y += accelerationRate.y;
            } else if (playerAcceleration.y > 0) {
                playerAcceleration.y -= decelerationRate.y;
                if (playerAcceleration.y < 0) playerAcceleration.y = 0;
            }

            if (rl.isKeyDown(rl.KeyboardKey.a)) {
                playerAcceleration.x -= accelerationRate.x;
            } else if (playerAcceleration.x < 0) {
                playerAcceleration.x += decelerationRate.x;
                if (playerAcceleration.x > 0) playerAcceleration.x = 0;
            }

            if (rl.isKeyDown(rl.KeyboardKey.d)) {
                playerAcceleration.x += accelerationRate.x;
            } else if (playerAcceleration.x > 0) {
                playerAcceleration.x -= decelerationRate.x;
                if (playerAcceleration.x < 0) playerAcceleration.x = 0;
            }

            // Reduce acceleration faster if the opposite key is pressed
            if (rl.isKeyDown(rl.KeyboardKey.w) and rl.isKeyDown(rl.KeyboardKey.s)) {
                playerAcceleration.y = 0;
            }
            if (rl.isKeyDown(rl.KeyboardKey.a) and rl.isKeyDown(rl.KeyboardKey.d)) {
                playerAcceleration.x = 0;
            }

            //_ = ecs.set(self.world, entity, component.Position, state.positions[i]);
            //_ = ecs.set(self.world, entity, component.Velocity, state.velocities[i]);
            _ = ecs.set(model.world, self.player, component.Acceleration, .{ .x = playerAcceleration.x, .y = playerAcceleration.y });
        }
    }

    pub fn shouldStop(self: *View) bool {
        _ = self;

        return rl.windowShouldClose();
    }

    fn renderShips(self: *View, model: *Model) void {
        _ = self;

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

        const query = ecs.query_init(model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(model.world, query);

        while (ecs.query_next(&it)) {
            const ships: []const component.Position = ecs.field(&it, component.Position, 0).?;
            const sizes: []const component.ShipSize = ecs.field(&it, component.ShipSize, 1).?;

            for (0..it.count()) |i| {
                //const entity = it.entities()[i];
                //std.log.info("{?s}", .{ecs.get_name(model.world, entity)});

                const size: f32 = switch (sizes[i]) {
                    .Small => 1,
                    .Medium => 2,
                    .Large => 4,
                    .Capital => 8,
                };

                rl.drawCircle(@intFromFloat(@mod(ships[i].x, screenWidth * 1.1)), @intFromFloat(@mod(ships[i].y, screenHeight * 1.1)), 5 * size, rl.Color.sky_blue);
            }
        }
    }

    fn renderPlayers(self: *View, model: *Model) void {
        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(component.Position) },
            ecs.term_t{ .id = ecs.id(tag.Player) },
            ecs.term_t{ .id = ecs.id(tag.Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 29;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(model.world, query);

        while (ecs.query_next(&it)) {
            const positions: []const component.Position = ecs.field(&it, component.Position, 0).?;

            for (0..it.count()) |i| {
                const entity = it.entities()[i];
                //std.log.info("{?s}", .{ecs.get_name(model.world, entity)});bb
                var color: rl.Color = rl.Color.green;

                if (entity == self.player) {
                    color = rl.Color.red;
                }

                rl.drawCircle(@intFromFloat(@mod(positions[i].x, screenWidth * 1.1)), @intFromFloat(@mod(positions[i].y, screenHeight * 1.1)), 5 * 2, color);
            }
        }
    }
};
