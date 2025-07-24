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
const ecs = @import("zflecs");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const core = @import("shared").core;
const visual = @import("shared").visual;
const editor = @import("shared").editor;
const util = @import("util");
const frontend = @import("frontend");
const Input = @import("frontend").Input;
const Window = @import("frontend").Window;
const TextureCache = @import("frontend").TextureCache;
const FrontEvent = @import("frontend").FrontEvent;
const rl = @import("frontend").rl;
// ------------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.view);
// ╚══════════════════════════════════════════════════════════════════╝

pub const View = struct {
    allocator: *std.mem.Allocator,
    cache: TextureCache,
    camera: rl.Camera2D,

    const default_width = 960;
    const default_height = 540;

    pub fn init(allocator: *std.mem.Allocator, name: []const u8) View {
        Window.open(name, default_width, default_height);
        const screen_width = Window.getWidth();
        const screen_height = Window.getHeight();
        return View{
            .allocator = allocator,
            .cache = TextureCache.init(allocator.*),
            .camera = rl.Camera2D{
                .offset = rl.Vector2{ .x = @as(f32, @floatFromInt(screen_width)) / 2, .y = @as(f32, @floatFromInt(screen_height)) / 2 },
                .target = rl.Vector2{ .x = 0, .y = 0 },
                .rotation = 0,
                .zoom = 1.0,
            },
        };
    }

    pub fn deinit(self: *View) void {
        self.cache.deinit(); //has to be called before `Window.close()`

        Window.close();
    }

    pub fn begin(self: *View) void {
        Window.update();
        Window.beginFrame();
        Window.clear();
        rl.beginMode2D(self.camera);
    }

    pub fn end(self: *View) void {
        _ = self;
        rl.endMode2D();
        Window.endFrame();
    }

    pub fn pollEvents(self: *View) !std.ArrayList(FrontEvent) {
        var list = std.ArrayList(FrontEvent).init(self.allocator.*);

        if (Window.shouldClose()) {
            try list.append(.Quit);
        }

        if (rl.isFileDropped()) {
            const files = rl.loadDroppedFiles();
            defer rl.unloadDroppedFiles(files);
            var i: usize = 0;
            while (i < files.count) : (i += 1) {
                const path = std.mem.span(files.paths[i]);
                const copy = try self.allocator.dupe(u8, path);
                try list.append(.{ .Editor = .{ .FileOpen = copy } });
            }
        }

        const wheel = Input.getMouseWheelMove();
        if (wheel != 0) {
            try list.append(.{ .CameraZoom = wheel });
        }

        if (Input.isMouseButtonDown(Input.MouseButton.middle)) {
            const delta = Input.getMouseDelta();
            try list.append(.{ .CameraPan = .{ .x = delta.x, .y = delta.y } });
        }

        if (Input.isKeyPressed(Input.KeyboardKey.delete)) {
            try list.append(.{ .Editor = .DeleteSelected });
        }

        if (Input.isKeyDown(Input.KeyboardKey.left_control) and Input.isKeyPressed(Input.KeyboardKey.s)) {
            try list.append(.{ .Editor = .FileSave });
        }

        if (Input.isKeyPressed(Input.KeyboardKey.tab)) {
            try list.append(.{ .Editor = .ToggleColliderView });
        }

        if (Input.isKeyPressed(Input.KeyboardKey.escape)) {
            try list.append(.Quit);
        }

        return list;
    }

    pub fn renderVisualPrefab(self: *View, prefab: *const visual.VisualPrefab, selected: ?usize) void {
        for (prefab.parts, 0..) |part, idx| {
            const tex = self.cache.get(part.image_path) catch {
                log.warn("texture load failed: {s}", .{part.image_path});
                continue;
            };

            const origin = rl.Vector2{
                .x = @as(f32, @floatFromInt(tex.width)) * part.pivot.x,
                .y = @as(f32, @floatFromInt(tex.height)) * part.pivot.y,
            };
            const dest = rl.Rectangle{
                .x = part.position.x,
                .y = part.position.y,
                .width = @as(f32, @floatFromInt(tex.width)) * part.scale.x,
                .height = @as(f32, @floatFromInt(tex.height)) * part.scale.y,
            };

            rl.drawTexturePro(
                tex,
                rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(tex.width), .height = @floatFromInt(tex.height) },
                dest,
                origin,
                part.rotation.toDegrees(),
                rl.Color.white,
            );

            if (selected != null and selected.? == idx) {
                rl.drawRectangleLines(
                    @intFromFloat(dest.x - origin.x),
                    @intFromFloat(dest.y - origin.y),
                    @intFromFloat(dest.width),
                    @intFromFloat(dest.height),
                    rl.Color.yellow,
                );
            }
        }
    }

    fn drawDottedLine(a: rl.Vector2, b: rl.Vector2, color: rl.Color) void {
        const segments: f32 = 8;
        var i: f32 = 0;
        while (i < segments) : (i += 2) {
            const t1 = i / segments;
            const t2 = (i + 1) / segments;
            const p1 = rl.Vector2{ .x = std.math.lerp(a.x, b.x, t1), .y = std.math.lerp(a.y, b.y, t1) };
            const p2 = rl.Vector2{ .x = std.math.lerp(a.x, b.x, t2), .y = std.math.lerp(a.y, b.y, t2) };
            rl.drawLineEx(p1, p2, 1.0, color);
        }
    }

    pub fn renderCorePrefab(self: *View, prefab: *const core.CorePrefab, dotted: bool) !void {
        const color = if (dotted) rl.Color.gray else rl.Color.red;
        for (prefab.colliders) |c| {
            switch (c.shape) {
                .Box => |b| {
                    const hw = b.size.x / 2;
                    const hh = b.size.y / 2;
                    var corners = [_]rl.Vector2{
                        .{ .x = -hw, .y = -hh },
                        .{ .x = hw, .y = -hh },
                        .{ .x = hw, .y = hh },
                        .{ .x = -hw, .y = hh },
                    };
                    const rad = c.rotation.toRadians();
                    const cos_t = @cos(rad);
                    const sin_t = @sin(rad);
                    for (corners, 0..) |*pt, _| {
                        const x = pt.x;
                        const y = pt.y;
                        pt.* = rl.Vector2{
                            .x = c.offset.x + x * cos_t - y * sin_t,
                            .y = c.offset.y + x * sin_t + y * cos_t,
                        };
                    }
                    var i: usize = 0;
                    while (i < corners.len) : (i += 1) {
                        const next = corners[(i + 1) % corners.len];
                        if (dotted) drawDottedLine(corners[i], next, color) else rl.drawLineEx(corners[i], next, 1.0, color);
                    }
                },
                .Circle => |circle| {
                    rl.drawCircleLines(@intFromFloat(c.offset.x), @intFromFloat(c.offset.y), circle.radius, color);
                },
                .Segment => |s| {
                    const a = rl.Vector2{ .x = c.offset.x + s.a.x, .y = c.offset.y + s.a.y };
                    const b = rl.Vector2{ .x = c.offset.x + s.b.x, .y = c.offset.y + s.b.y };
                    if (dotted) drawDottedLine(a, b, color) else rl.drawLineEx(a, b, 1.0, color);
                },
                .Polygon => |poly| {
                    if (poly.vertices.len == 0) continue;
                    var points = try self.allocator.alloc(rl.Vector2, poly.vertices.len);
                    defer self.allocator.free(points);
                    const rad = c.rotation.toRadians();
                    const cos_t = @cos(rad);
                    const sin_t = @sin(rad);
                    for (poly.vertices, 0..) |v, idx| {
                        const rx = v.x * cos_t - v.y * sin_t;
                        const ry = v.x * sin_t + v.y * cos_t;
                        points[idx] = rl.Vector2{ .x = c.offset.x + rx, .y = c.offset.y + ry };
                    }
                    var i: usize = 0;
                    while (i < points.len) : (i += 1) {
                        const next = points[(i + 1) % points.len];
                        if (dotted) drawDottedLine(points[i], next, color) else rl.drawLineEx(points[i], next, 1.0, color);
                    }
                },
                .Capsule => |cap| {
                    const top = rl.Vector2{ .x = 0, .y = cap.half_height };
                    const bottom = rl.Vector2{ .x = 0, .y = -cap.half_height };
                    const rad = c.rotation.toRadians();
                    const cos_t = @cos(rad);
                    const sin_t = @sin(rad);
                    const t = rl.Vector2{ .x = c.offset.x + top.x * cos_t - top.y * sin_t, .y = c.offset.y + top.x * sin_t + top.y * cos_t };
                    const b = rl.Vector2{ .x = c.offset.x + bottom.x * cos_t - bottom.y * sin_t, .y = c.offset.y + bottom.x * sin_t + bottom.y * cos_t };
                    if (dotted) {
                        drawDottedLine(t, b, color);
                    } else {
                        rl.drawLineEx(t, b, 1.0, color);
                    }
                    rl.drawCircleLines(@intFromFloat(t.x), @intFromFloat(t.y), cap.radius, color);
                    rl.drawCircleLines(@intFromFloat(b.x), @intFromFloat(b.y), cap.radius, color);
                },
            }
        }
    }
};
