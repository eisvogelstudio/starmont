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
const util = @import("shared").util;
// ----------------------------

// ---------- shared ----------
const view = @import("view");
const Input = view.Input;
const Window = view.Window;
// ----------------------------

const log = std.log.scoped(.control);

const name = "editor";

//const Vec2 = struct {
//    x: f32,
//    y: f32,
//
//    pub fn distance(a: Vec2, b: Vec2) f32 {
//        return @sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
//    }
//
//    pub fn toRayVec(self: Vec2) rl.Vector2 {
//        return rl.Vector2{ .x = self.x, .y = self.y };
//    }
//};

//const Collider = struct {
//    points: []Vec2,
//};

const HandleState = struct {
    dragging: bool = false,
    selected_index: usize = 0,
};

const screenWidth = 800;
const screenHeight = 600;

//var collider: Collider = undefined;
//var handle_state = HandleState{};
//const handle_radius: f32 = 8.0;
//var dragging_offset = Vec2{ .x = 0, .y = 0 };

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    snapshotRequired: bool = true,

    arena_allocator: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator),

    pub fn init(allocator: *std.mem.Allocator) Control {
        var control = Control{
            .allocator = allocator,
            .model = core.Model.init(allocator),
        };

        Window.open("editor", screenWidth, screenHeight);

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        //collider = Collider{
        //    .points = allocator.alloc(Vec2, 4) catch unreachable,
        //};
        //collider.points[0] = .{ .x = 200, .y = 200 };
        //collider.points[1] = .{ .x = 300, .y = 200 };
        //collider.points[2] = .{ .x = 300, .y = 300 };
        //collider.points[3] = .{ .x = 200, .y = 300 };

        util.asset.loadAsset(&control.arena_allocator) catch |err| {
            std.debug.print("error: {s}\n", .{@errorName(err)});
        };

        return control;
    }

    pub fn deinit(self: *Control) void {
        //_ = self;

        Window.close();

        log.info("stopped sucessfully", .{});

        //self.allocator.free(collider.points);

        self.arena_allocator.deinit();
    }

    pub fn update(self: *Control) void {
        //const actions = captureInput(self.allocator);
        //actions.deinit();
        _ = self;

        Window.update();

        //const mouse = rl.getMousePosition();
        //const mouse_vec = Vec2{ .x = mouse.x, .y = mouse.y };

        // --- Input Handling ---
        //if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
        //    for (collider.points, 0..) |p, i| {
        //        if (Vec2.distance(mouse_vec, p) < handle_radius * 1.5) {
        //            handle_state.dragging = true;
        //            handle_state.selected_index = i;
        //            dragging_offset = Vec2{ .x = p.x - mouse.x, .y = p.y - mouse.y };
        //            break;
        //        }
        //    }
        //}

        //if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
        //    handle_state.dragging = false;
        //}

        //if (handle_state.dragging) {
        //    collider.points[handle_state.selected_index] = Vec2{
        //       .x = mouse.x + dragging_offset.x,
        //        .y = mouse.y + dragging_offset.y,
        //    };
        //}

        // --- Drawing ---
        Window.beginFrame();

        //rl.clearBackground(rl.Color.ray_white);

        //rl.drawText("Starmont Editor", 10, 10, 20, rl.Color.dark_gray);

        // Linien des Colliders
        //for (collider.points, 0..) |p, i| {
        //    const next = collider.points[(i + 1) % collider.points.len];
        //    rl.drawLineV(p.toRayVec(), next.toRayVec(), rl.Color.black);
        //}

        // Punkte (Handles)
        //for (collider.points) |p| {
        //    rl.drawCircleV(p.toRayVec(), handle_radius, rl.Color.red);
        //}

        Window.endFrame();
    }

    pub fn shouldStop(self: *Control) bool {
        _ = self;

        return Window.shouldClose();
    }
};
