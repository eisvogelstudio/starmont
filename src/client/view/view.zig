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
// -------------------------

// ---------- shared ----------
const core = @import("shared").core;
// ----------------------------

// ---------- external ----------
const ecs = @import("zflecs");
//const rl = @import("raylib");
//const rg = @import("raygui");
// ------------------------------

const log = std.log.scoped(.view);

pub const View = struct {
    allocator: *std.mem.Allocator,

    const screenWidth = 800;
    const screenHeight = 450;

    pub fn init(allocator: *std.mem.Allocator) View {
        const view = View{
            .allocator = allocator,
        };

        //rl.setTraceLogLevel(rl.TraceLogLevel.none);
        //rl.initWindow(screenWidth, screenHeight, core.name ++ " v" ++ core.version);

        //std.log.info("{any}\n", .{rl.getWindowScaleDPI()});
        //rl.setWindowSize(@as(i32, @as(f32, screenWidth) / rl.getWindowScaleDPI().x), @as(i32, @as(f32, screenHeight) / rl.getWindowScaleDPI().y));
        //const dpiScale = rl.getWindowScaleDPI();

        // Convert scaled width/height to integer using @divFloor
        //const newWidth = @divFloor(@as(f32, screenWidth), dpiScale.x);
        //const newHeight = @divFloor(@as(f32, screenHeight), dpiScale.y);

        //rl.setWindowSize(@intFromFloat(newWidth), @intFromFloat(newHeight));
        //rl.setMouseScale(rl.getWindowScaleDPI().x, rl.getWindowScaleDPI().y);

        //rl.setTargetFPS(60);

        return view;
    }

    pub fn deinit(self: *View) void {
        _ = self;
        //rl.closeWindow();
    }

    pub fn update(self: *View, model: *core.Model) void {
        //rl.beginDrawing();
        //defer rl.endDrawing();
        //rl.clearBackground(rl.Color.white);
        //rl.beginMode2D(camera);
        self.renderShips(model);
        self.renderPlayers(model);
        //rl.drawFPS(100, 100);
        //rl.endMode2D();

        //const scale = @min(rl.getScreenWidth()/rl.gameScreenWidth, (float)GetScreenHeight()/gameScreenHeight);

        //const text = "Welcome to " ++ core.name ++ " - till the stars and far beyond";
        //const fontSize = 20;
        //
        //const textWidth = rl.measureText(text, fontSize);
        //const textHeight = fontSize;
        //const x = @divTrunc((screenWidth - textWidth), 2);
        //const y = @divTrunc((screenHeight - textHeight), 2);
        //
        //rl.drawText(text, x, y, fontSize, rl.Color.light_gray);

        //var buttonPressed = false;
        //var sliderValue: f32 = 50.0;
        //
        //if (rg.guiButton(rl.Rectangle{ .x = 10, .y = 10, .width = 150, .height = 30 }, "Click Me") != 0) {
        //    buttonPressed = !buttonPressed;
        //}
        //_ = rg.guiSlider(rl.Rectangle{ .x = 10, .y = 50, .width = 200, .height = 20 }, "Size", "{:.2}", &sliderValue, 0.0, 100.0);
        //if (buttonPressed) {
        //    rl.drawText("Button Pressed!", 200, 10, 20, rl.Color.red);
        //}
        //
        //if ((sliderValue > 80) or (sliderValue < 20)) {
        //    rl.drawText("AHHHHHH!", 300, 60, 20, rl.Color.red);
        //    //const other = model.createPlayer();
        //    //_ = ecs.set(model.world, other, core.Acceleration, .{ .x = -20, .y = 20 });
        //}
    }

    pub fn shouldStop(self: *View) bool {
        _ = self;

        return true;
        //rl.windowShouldClose();
    }

    fn renderShips(self: *View, model: *core.Model) void {
        _ = self;

        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(core.Position) },
            ecs.term_t{ .id = ecs.id(core.ShipSize) },
            ecs.term_t{ .id = ecs.id(core.Ship) },
            ecs.term_t{ .id = ecs.id(core.Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 28;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(model.world, query);

        while (ecs.query_next(&it)) {
            const ships: []const core.Position = ecs.field(&it, core.Position, 0).?;
            const sizes: []const core.ShipSize = ecs.field(&it, core.ShipSize, 1).?;

            for (0..it.count()) |i| {
                //const entity = it.entities()[i];
                //std.log.info("{?s}", .{ecs.get_name(model.world, entity)});

                const size: f32 = switch (sizes[i]) {
                    .Small => 1,
                    .Medium => 2,
                    .Large => 4,
                    .Capital => 8,
                };

                _ = ships;
                _ = size;

                //rl.drawCircle(@intFromFloat(@mod(ships[i].x, screenWidth * 1.1)), @intFromFloat(@mod(ships[i].y, screenHeight * 1.1)), 5 * size, rl.Color.sky_blue);
            }
        }
    }

    fn renderPlayers(self: *View, model: *core.Model) void {
        const terms: [32]ecs.term_t = [_]ecs.term_t{
            ecs.term_t{ .id = ecs.id(core.Position) },
            ecs.term_t{ .id = ecs.id(core.Player) },
            ecs.term_t{ .id = ecs.id(core.Visible) },
        } ++ [_]ecs.term_t{ecs.term_t{}} ** 29;

        var query_desc = ecs.query_desc_t{
            .terms = terms,
            .cache_kind = ecs.query_cache_kind_t.QueryCacheAuto,
        };

        const query = ecs.query_init(model.world, &query_desc) catch unreachable;
        defer ecs.query_fini(query);

        var it = ecs.query_iter(model.world, query);

        while (ecs.query_next(&it)) {
            const positions: []const core.Position = ecs.field(&it, core.Position, 0).?;

            for (0..it.count()) |i| {
                const entity = it.entities()[i];
                _ = entity;
                //const color: rl.Color = rl.Color.green;
                _ = self;
                _ = positions;
                //rl.drawCircle(@intFromFloat(@mod(positions[i].x, screenWidth)), @intFromFloat(@mod(positions[i].y, screenHeight)), 10, color);
            }
        }
    }
};
