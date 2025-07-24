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
const util = @import("util");
// ------------------------------

// ---------- local ----------
const frontend = @import("frontend");
const Input = frontend.Input;
const Window = frontend.Window;
const TextureCache = frontend.TextureCache;
const FrontEvent = frontend.FrontEvent;
const rl = frontend.rl;
const fprefab = frontend.prefab;
// ---------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.view);
// ╚══════════════════════════════════════════════════════════════════╝

pub const View = struct {
    allocator: *std.mem.Allocator,
    cache: TextureCache,

    //TODO[MISSING] make dynamic
    const screen_width = 1920 / 2;
    const screen_height = 1080 / 2;

    pub fn init(allocator: *std.mem.Allocator, name: []const u8) View {
        const view = View{
            .allocator = allocator,
            .cache = TextureCache.init(allocator.*),
        };

        Window.open(name, screen_width, screen_height);

        return view;
    }

    pub fn deinit(self: *View) void {
        self.cache.deinit(); //has to be called before `Window.close()`

        Window.close();
    }

    pub fn begin(self: *View) void {
        Window.update();
        Window.beginFrame();
    }

    pub fn end(self: *View) void {
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

        if (Input.isKeyPressed(Input.KeyboardKey.KEY_DELETE)) {
            try list.append(.{ .Editor = .DeleteSelected });
        }

        if (Input.isKeyPressed(Input.KeyboardKey.KEY_ESCAPE)) {
            try list.append(.Quit);
        }

        return list;
    }

    pub fn renderVisualPrefab(self: *View, prefab: *const fprefab.VisualPrefab, selected: ?usize) void {
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
};
