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
const util = @import("util");
const core = @import("shared").core;
const visual = @import("shared").visual;
const editor = @import("shared").editor;

const frontend = @import("frontend");
const Input = @import("frontend").Input;
const Window = @import("frontend").Window;
const TextureCache = @import("frontend").TextureCache;
const FrontEvent = @import("frontend").FrontEvent;
const NodeMeta = @import("shared").NodeMeta;
const NodeData = @import("shared").NodeData;
const rl = @import("frontend").rl;
// ------------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.view);
// ╚══════════════════════════════════════════════════════════════════╝

pub const View = struct {
    gpa: *std.mem.Allocator,
    cache: TextureCache,
    camera: rl.Camera2D,

    //TODO[MISSING] make dynamic
    const screen_width = 1920;
    const screen_height = 1080;

    pub fn init(gpa: *std.mem.Allocator, name: []const u8) View {
        const view = View{
            .gpa = gpa,
            .cache = TextureCache.init(gpa.*),
            .camera = rl.Camera2D{
                .offset = rl.Vector2{ .x = screen_width / 2, .y = screen_height / 2 },
                .target = rl.Vector2{ .x = 0, .y = 0 },
                .rotation = 0,
                .zoom = 1.0,
            },
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
        Window.clear();
        rl.beginMode2D(self.camera);
    }

    pub fn end(self: *View) void {
        _ = self;
        rl.endMode2D();
        Window.endFrame();
    }

    pub fn pollEvents(self: *View) !std.ArrayList(FrontEvent) {
        var list = std.ArrayList(FrontEvent).init(self.gpa.*);

        if (Window.shouldClose()) {
            try list.append(.Quit);
        }

        if (rl.isFileDropped()) {
            const files = rl.loadDroppedFiles();
            defer rl.unloadDroppedFiles(files);
            var i: usize = 0;
            while (i < files.count) : (i += 1) {
                const path = std.mem.span(files.paths[i]);
                const copy = try self.gpa.dupe(u8, path);
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

        if (Input.isKeyPressed(Input.KeyboardKey.escape)) {
            try list.append(.Quit);
        }

        return list;
    }

    pub fn renderPrefab(self: *View, prefab: *const visual.Prefab, selected: ?usize) void {
        for (prefab.assets.items, 0..) |asset, idx| {
            const tex = self.cache.get(asset.path) catch {
                log.warn("texture load failed: {s}", .{asset.path});
                continue;
            };

            const origin = rl.Vector2{
                .x = @as(f32, @floatFromInt(tex.width)) * asset.pivot.x,
                .y = @as(f32, @floatFromInt(tex.height)) * asset.pivot.y,
            };
            const dest = rl.Rectangle{
                .x = asset.position.x,
                .y = asset.position.y,
                .width = @as(f32, @floatFromInt(tex.width)) * asset.scale.x,
                .height = @as(f32, @floatFromInt(tex.height)) * asset.scale.y,
            };

            rl.drawTexturePro(
                tex,
                rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(tex.width), .height = @floatFromInt(tex.height) },
                dest,
                origin,
                asset.rotation.toDegrees(),
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

    pub fn renderPrefabDTO(self: *View, prefab: *const visual.PrefabDTO, data: NodeData, selected: ?usize) void {
        for (prefab.assets, 0..) |asset, idx| {
            const tex = self.cache.get(asset.path) catch {
                log.warn("texture load failed: {s}", .{asset.path});
                continue;
            };

            const origin = rl.Vector2{
                .x = @as(f32, @floatFromInt(tex.width)) * asset.pivot.x,
                .y = @as(f32, @floatFromInt(tex.height)) * asset.pivot.y,
            };
            const dest = rl.Rectangle{
                .x = asset.position.x,
                .y = asset.position.y,
                .width = @as(f32, @floatFromInt(tex.width)) * asset.scale.x,
                .height = @as(f32, @floatFromInt(tex.height)) * asset.scale.y,
            };

            rl.drawTexturePro(
                tex,
                rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(tex.width), .height = @floatFromInt(tex.height) },
                dest,
                origin,
                asset.rotation.toDegrees() + data.rotation.toDegrees(),
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
