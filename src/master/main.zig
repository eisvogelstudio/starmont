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

// ---------- builtin ----------
const builtin = @import("builtin");
// -------------------------

// ---------- std ----------
const std = @import("std");
// -------------------------

// ---------- client ----------
const Control = @import("control.zig").Control;
const QuadTree = @import("quadtree.zig").QuadTree;
const QuadNode = @import("quadtree.zig").QuadNode;
const ServerRegistry = @import("server_registry.zig").ServerRegistry;
// ----------------------------

// ---------- shared ----------
const ServerId = @import("shared").network.ServerId;
const util = @import("shared").util;
// ----------------------------

pub const std_options: std.Options = .{
    .log_level = if (builtin.mode == .Debug) .debug else .info,
    //.log_scope_levels = &.{
    //    .{ .scope = .decimal, .level = .info },
    //    .{ .scope = .proper, .level = .info },
    //},
    .logFn = util.log.logFn,
};

const canvas_width = 1920;
const canvas_height = 1080;

const xo = 800;
const yo = 0;

const raylib = @import("raylib");
const rg = @import("raygui");

var count: i32 = 0;

var last_decay_time: i64 = 0;

var current: ?*QuadNode = undefined;

fn colorFromPosition(node: *QuadNode, currentN: ?*QuadNode) raylib.Color {
    _ = currentN;

    // Mapping der quadranten_in_parent zu leichtem Farbversatz (optional)

    var q_shift: f32 = 5.0;

    if (node.quadrant_in_parent) |n| {
        q_shift = switch (n) {
            .NW => 1.0,
            .NE => 2.0,
            .SW => 3.0,
            .SE => 4.0,
        };
    }

    // Tiefe und Quadrant beeinflussen Grün und Blau
    //const depth_factor = @as(f32, @floatFromInt(node.depth)) / @as(f32, QuadNode.max_depth);
    //const b: u8 = @intFromFloat(50 + (1.0 - depth_factor) * 100);

    //const b: u8 = 0; //@intFromFloat(@min(255, q_shift * 20.0));

    const now = std.time.timestamp();
    const b: u8 = @intCast(255 - @min(255, (@max(0, QuadNode.merge_time - (now - node.below_threshhold_since)) * 80)));

    const g: u8 = @intFromFloat(@min(255, 200.0));

    // Pressure auf 0–1 clampen und auf rot anwenden
    //const clamped_pressure = std.math.clamp(node.pressure, 0.0, 1.0);
    const r: u8 = @intFromFloat(std.math.round(std.math.clamp(node.pressure / QuadNode.split_threshhold, 0.0, 1.0) * 255));

    return raylib.Color{ .r = r, .g = g, .b = b, .a = 255 };
}

fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

fn drawNodeRecursive(node: *QuadNode, random: *std.Random) void {
    if (node.isLeaf()) {
        const color = colorFromPosition(node, current);

        //const scale_x = @as(f32, canvas_width) / @as(f32, QuadNode.cells_per_axis);
        //const scale_y = @as(f32, canvas_height) / @as(f32, QuadNode.cells_per_axis);

        //const scaled_x: i32 = @intFromFloat((@as(f32, @floatFromInt(node.rectangle.x)) - @as(f32, @as(i32, QuadNode.cells_per_axis))) * scale_x);
        //const scaled_y: i32 = @intFromFloat((@as(f32, @floatFromInt(node.rectangle.y)) - @as(f32, @as(i32, QuadNode.cells_per_axis))) * scale_y);
        //const scaled_w: i32 = @intFromFloat(@as(f32, @floatFromInt(node.rectangle.width)) * scale_x);
        //const scaled_h: i32 = @intFromFloat(@as(f32, @floatFromInt(node.rectangle.height)) * scale_y);

        //raylib.drawRectangle(scaled_x, scaled_y, scaled_w * 10, scaled_h * 10, color);
        raylib.drawRectangle(node.rectangle.x + xo, node.rectangle.y + yo, node.rectangle.width, node.rectangle.height, color);

        var col: raylib.Color = undefined;

        if (current != null and node == current.?) {
            col = raylib.Color.light_gray;
        } else {
            col = raylib.Color.black;
        }

        raylib.drawRectangleLines(node.rectangle.x + xo, node.rectangle.y + yo, node.rectangle.width, node.rectangle.height, col);

        //std.log.info("draw {} {} {} {} {}", .{ count, node.rectangle.x, node.rectangle.y, QuadNode.cells_per_axis - node.rectangle.width, QuadNode.cells_per_axis - node.rectangle.height });
    } else if (node.children) |children| {
        for (children) |child| {
            drawNodeRecursive(child, random);
        }
    }
}

pub fn drawTree(tree: *QuadTree) void {
    var prng = std.Random.DefaultPrng.init(0xDEADBEEF); // Konstante für deterministische Farben
    var random = prng.random();
    drawNodeRecursive(&tree.root, &random);
}

fn findLeafAt(node: *QuadNode, x: i32, y: i32) *QuadNode {
    if (node.isLeaf()) return node;

    if (node.children) |children| {
        for (children) |child| {
            const r = child.rectangle;
            if (x >= r.x and y >= r.y and x < r.x + r.width and y < r.y + r.height) {
                return findLeafAt(child, x, y);
            }
        }
    }

    return node; // fallback (kannst auch `unreachable` setzen, je nach Absicherung)
}

fn decayLoadRecursive(node: *QuadNode) void {
    if (node.isLeaf()) {
        if (node.pressure > 0) {
            node.pressure -= (QuadNode.split_threshhold - QuadNode.merge_threshhold) / 10;
        } else {
            node.pressure = 0.0;
        }
    } else if (node.children) |children| {
        for (children) |child| {
            decayLoadRecursive(child);
        }
    }
}

pub fn decayLoad(tree: *QuadTree) void {
    decayLoadRecursive(&tree.root);
}

pub fn test2() !void {
    raylib.initWindow(canvas_width, canvas_height, "Tree Visualizer");

    const dpiScale = raylib.getWindowScaleDPI();
    const newWidth = @divFloor(@as(f32, canvas_width), dpiScale.x);
    const newHeight = @divFloor(@as(f32, canvas_height), dpiScale.y);

    raylib.setWindowSize(@intFromFloat(newWidth), @intFromFloat(newHeight));
    raylib.setMouseScale(dpiScale.x, dpiScale.y);
    raylib.setTargetFPS(60);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var registry = try ServerRegistry.init(&allocator);
    defer registry.deinit();

    try registry.update(ServerId{ .id = 1 }, 5.0);
    try registry.update(ServerId{ .id = 2 }, 3.0);
    try registry.update(ServerId{ .id = 3 }, 7.0);

    var tree = try QuadTree.init(&allocator);
    current = &tree.root;
    defer tree.deinit();

    // Manuell Wurzel mit Kindern initialisieren (Testzweck)
    //tree.root.split();
    //tree.root.children.?[0].split(); // z. B. NW weiter aufspalten
    //tree.root.children.?[1].split(); // z. B. NE weiter aufspalten

    while (!raylib.windowShouldClose()) {
        count += 1;
        if (raylib.isMouseButtonPressed(raylib.MouseButton.left)) {
            const mouse = raylib.getMousePosition();

            // Fenster → Welt-Koordinaten zurückrechnen
            //const world_x = @intFromFloat(mouse.x / scale_x + QuadNode.cells_per_axis);
            //const world_y = @intFromFloat(mouse.y / scale_y + QuadNode.cells_per_axis);

            const clicked_node = findLeafAt(&tree.root, @intFromFloat(mouse.x - xo), @intFromFloat(mouse.y - yo));

            if (raylib.isKeyDown(raylib.KeyboardKey.left_control)) {
                clicked_node.pressure += 255;
            } else {
                current = clicked_node;
            }
        } else if (raylib.isMouseButtonPressed(raylib.MouseButton.right)) {
            current = &tree.root;
        }

        const now = std.time.timestamp();
        if (now - last_decay_time >= 1) { // 1000 ms = 1 Sekunde
            decayLoad(&tree);
            last_decay_time = now;
        }

        QuadTree.tick(&tree, &registry, now);

        raylib.beginDrawing();
        raylib.clearBackground(raylib.Color.white);

        drawTree(&tree);

        //raylib.drawText("Strg + Left click to apply pressure", 10, 10, 20, raylib.Color.dark_gray);

        var buffer: [64:0]u8 = undefined;
        const node_load_text = try std.fmt.bufPrintZ(&buffer, "Main: {d:.2}\tCurrent: {d:.2}", .{ tree.root.pressure / QuadNode.split_threshhold, current.?.*.pressure / QuadNode.split_threshhold });

        raylib.drawText(node_load_text, 10, 10, 40, raylib.Color.dark_gray);

        raylib.endDrawing();
    }

    raylib.closeWindow();
}

//pub fn test2() !void {
//    raylib.initWindow(800, 600, "Tree Visualizer");
//
//    const dpiScale = raylib.getWindowScaleDPI();
//
//    // Convert scaled width/height to integer using @divFloor
//    const newWidth = @divFloor(@as(f32, 800), dpiScale.x);
//    const newHeight = @divFloor(@as(f32, 600), dpiScale.y);
//
//    raylib.setWindowSize(@intFromFloat(newWidth), @intFromFloat(newHeight));
//    raylib.setMouseScale(raylib.getWindowScaleDPI().x, raylib.getWindowScaleDPI().y);
//
//    raylib.setTargetFPS(60);
//
//    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//    var allocator = gpa.allocator();
//
//    var nodes = std.ArrayList(Node).init(allocator);
//
//    try nodes.append(try createTree(&allocator, Vec2{ .x = 400, .y = 300 }, max_depth));
//
//    while (!raylib.windowShouldClose()) {
//        if (raylib.isMouseButtonPressed(raylib.MouseButton.left)) {
//            const mouse = raylib.getMousePosition();
//            try nodes.append(try createTree(&allocator, mouse, max_depth));
//        }
//
//        raylib.beginDrawing();
//        raylib.clearBackground(raylib.Color.white);
//
//        for (nodes.items) |*node| {
//            drawTree(node);
//        }
//
//        raylib.drawText("Left click to grow a new tree", 10, 10, 20, raylib.Color.dark_gray);
//        raylib.endDrawing();
//    }
//
//    raylib.closeWindow();
//}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    //var allocator = gpa.allocator();

    test2() catch unreachable;
    return;

    //var control = Control.init(&allocator);

    //while (!control.shouldStop()) {
    //  control.update();
    //}

    //control.deinit();
}

test {
    std.testing.refAllDecls(@This());
}
