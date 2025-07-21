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

const rl = view.rl;
const TextureCache = view.TextureCache;

const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn distance(a: Vec2, b: Vec2) f32 {
        return @sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    }
};

const Prefab = struct {
    name: []const u8,

    // Visual components: individual PNG parts with transform
    parts: []const Part,

    // Optional physics colliders
    colliders: []const Collider,
};

const Part = struct {
    image_path: []const u8, // path to PNG
    position: Vec2,
    rotation: f32 = 0.0, // in degrees or radians (your call)
    scale: Vec2 = .{ .x = 1.0, .y = 1.0 }, // uniform or non-uniform
    pivot: Vec2 = .{ .x = 0.5, .y = 0.5 }, // normalized, relative to image
};

const Collider = struct {
    kind: ColliderKind,
    // Shape data depending on kind
    data: ColliderData,
    offset: Vec2 = .{ .x = 0.0, .y = 0.0 }, // local offset
};

const ColliderKind = enum {
    Box,
    Circle,
    Polygon,
};

const ColliderData = union(ColliderKind) {
    Box: BoxCollider,
    Circle: CircleCollider,
    Polygon: PolygonCollider,
};

const BoxCollider = struct {
    size: Vec2,
};

const CircleCollider = struct {
    radius: f32,
};

const PolygonCollider = struct {
    points: []const Vec2, // must form a convex polygon or whatever rule you enforce
};

const EditorMode = enum {
    Idle,
    Select,
    Move,
    Scale,
    Rotate,
    AddPart,
    AddCollider,
    EditCollider,
    PanView,
    PlacePivot,
};

const SelectionState = struct {
    selected_part: ?usize = null,
    selected_collider: ?usize = null,

    selected_point_index: ?usize = null, // z. B. bei Polygon
};

const TransformState = struct {
    dragging: bool,
    origin: Vec2,
    start_mouse: Vec2,
    mode: enum { Move, Scale, Rotate },
};

//const Camera2D = extern struct {
//    offset: rl.Vector2,
//    target: rl.Vector2,
//    rotation: f32,
//    zoom: f32,
//};

const EditorState = struct {
    // prefab: Prefab,

    selection: SelectionState,
    mode: EditorMode,

    camera: rl.Camera2D, // für Pan/Zoom
    // mouse: MouseState,

    is_dirty: bool, // ungespeicherte Änderungen?

    pub fn init(screen_width: f32, screen_height: f32) EditorState {
        return EditorState{
            .selection = .{},
            .mode = .Idle,
            .camera = rl.Camera2D{
                .offset = rl.Vector2{ .x = screen_width / 2.0, .y = screen_height / 2.0 },
                .target = rl.Vector2{ .x = 0.0, .y = 0.0 },
                .rotation = 0.0,
                .zoom = 1.0,
            },
            .is_dirty = false,
        };
    }
};

const screenWidth = 1920 / 2;
const screenHeight = 1080 / 2;

//var collider: Collider = undefined;
//var handle_state = HandleState{};
//const handle_radius: f32 = 8.0;
//var dragging_offset = Vec2{ .x = 0, .y = 0 };

pub fn renderPrefab(prefab: *const Prefab, tex_cache: *TextureCache, allocator: std.mem.Allocator) !void {
    for (prefab.parts) |part| {
        const tex = try tex_cache.get(allocator, part.image_path);

        const origin = rl.Vector2{
            .x = @as(f32, @floatFromInt(tex.width)) * part.pivot.x,
            .y = @as(f32, @floatFromInt(tex.height)) * part.pivot.y,
        };

        const dest_size = rl.Vector2{
            .x = @as(f32, @floatFromInt(tex.width)) * part.scale.x,
            .y = @as(f32, @floatFromInt(tex.height)) * part.scale.y,
        };

        rl.drawTexturePro(
            tex,
            rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(tex.width), .height = @floatFromInt(tex.height) },
            rl.Rectangle{
                .x = part.position.x,
                .y = part.position.y,
                .width = dest_size.x,
                .height = dest_size.y,
            },
            origin,
            part.rotation,
            rl.Color.white,
        );
    }
}

pub const Control = struct {
    allocator: *std.mem.Allocator,
    model: core.Model,
    snapshotRequired: bool = true,

    arena_allocator: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator),

    cache: TextureCache,

    current: ?Prefab = null,

    editor: EditorState,

    pub fn init(allocator: *std.mem.Allocator) Control {
        var control = Control{
            .allocator = allocator,
            .model = core.Model.init(allocator),
            .cache = TextureCache.init(allocator.*),
            .editor = EditorState.init(screenWidth, screenHeight),
        };

        Window.open("editor", screenWidth, screenHeight);

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        control.current = util.ziggy.load(control.arena_allocator.allocator(), "prefab.ziggy", Prefab) catch unreachable;

        return control;
    }

    pub fn deinit(self: *Control) void {
        if (self.current) |cur| {
            util.ziggy.save(self.arena_allocator.allocator(), "prefab.ziggy", cur) catch unreachable;
        }

        Window.close();

        log.info("stopped sucessfully", .{});

        self.cache.deinit();

        self.arena_allocator.deinit();
    }

    pub fn update(self: *Control) void {
        //const actions = captureInput(self.allocator);
        //actions.deinit();

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
        const wheel = rl.getMouseWheelMove(); // +1 or -1 per notch
        if (wheel != 0) {
            const zoomFactor = 1.1;
            if (wheel > 0) {
                self.editor.camera.zoom *= zoomFactor;
            } else {
                self.editor.camera.zoom /= zoomFactor;
            }

            // Clamp zoom to avoid inversion or nan
            if (self.editor.camera.zoom < 0.1) self.editor.camera.zoom = 0.1;
            if (self.editor.camera.zoom > 10.0) self.editor.camera.zoom = 10.0;
        }

        // --- Drawing ---
        Window.beginFrame();
        //rl.clearBackground(rl.DARKGRAY);
        rl.clearBackground(rl.Color.dark_brown);

        rl.beginMode2D(self.editor.camera);
        // Render your prefab here
        if (self.current) |cur| {
            renderPrefab(&cur, &self.cache, self.allocator.*) catch unreachable;
        }
        rl.endMode2D();

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
