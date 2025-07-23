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

// ---------- local ----------
const View = @import("view/view.zig").View;
// ----------------------------

// ---------- shared ----------
const core = @import("shared").core;
const util = @import("shared").util;
const FrontEvent = @import("frontend").FrontEvent;
// ----------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.control);

const name = "editor";
// ╚══════════════════════════════════════════════════════════════════╝

// ┌──────────────────── State ────────────────────┐
const State = struct {
    should_stop: bool = false,
};
// └───────────────────────────────────────────────┘

//const Prefab = struct {
//    name: []const u8,
//    parts: []const Part,
//    colliders: []const Collider,
//};

//const PrefabData = struct {
//    prefab: Prefab,
//    parts_list: std.ArrayList(Part),
//    colliders_list: std.ArrayList(Collider),
//
//    pub fn init(allocator: std.mem.Allocator) !PrefabData {
//        return PrefabData{
//            .prefab = Prefab{
//                .name = "unnamed",
//                .parts = &[_]Part{},
//                .colliders = &[_]Collider{},
//            },
//            .parts_list = try std.ArrayList(Part).init(allocator),
//            .colliders_list = try std.ArrayList(Collider).init(allocator),
//        };
//    }
//
//    pub fn appendPart(self: *PrefabData, part: Part) !void {
//        try self.parts_list.append(part);
//        self.prefab.parts = self.parts_list.items;
//    }
//
//    pub fn appendCollider(self: *PrefabData, collider: Collider) !void {
//        try self.colliders_list.append(collider);
//        self.prefab.colliders = self.colliders_list.items;
//    }
//
//    pub fn deinit(self: *PrefabData) void {
//        self.parts_list.deinit();
//        self.colliders_list.deinit();
//    }
//
//    pub fn from(allocator: std.mem.Allocator, p: ?Prefab) ?PrefabData {
//        if (p) |prefab| {
//            var parts = std.ArrayList(Part).init(allocator);
//            parts.appendSlice(prefab.parts) catch unreachable;
//
//            var colliders = std.ArrayList(Collider).init(allocator);
//            colliders.appendSlice(prefab.colliders) catch unreachable;
//
//            return PrefabData{
//                .prefab = Prefab{
//                    .name = prefab.name,
//                    .parts = parts.items,
//                    .colliders = colliders.items,
//                },
//                .parts_list = parts,
//                .colliders_list = colliders,
//            };
//        } else {
//            return null;
//        }
//    }
//
//    /// Converts the dynamic PrefabData back into a static Prefab (e.g. for serialization)
//    pub fn to(self: *PrefabData) Prefab {
//        return Prefab{
//            .name = self.prefab.name,
//            .parts = self.parts_list.items,
//            .colliders = self.colliders_list.items,
//        };
//    }
//};

//const Part = struct {
//    image_path: []const u8, // path to PNG
//    position: Vec2,
//    rotation: f32 = 0.0, // in degrees or radians (your call)
//    scale: Vec2 = .{ .x = 1.0, .y = 1.0 }, // uniform or non-uniform
//    pivot: Vec2 = .{ .x = 0.5, .y = 0.5 }, // normalized, relative to image
//};
//    points: []const Vec2, // must form a convex polygon or whatever rule you enforce
//};

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
    is_dragging: bool,
    //origin: Vec2,
    start_mouse: util.Vec2,
    start_position: util.Vec2,
    //mode: enum { Move, Scale, Rotate },
};

//const Camera2D = extern struct {
//    offset: rl.Vector2,
//    target: rl.Vector2,
//    rotation: f32,
//    zoom: f32,
//};

//const EditorState = struct {
//    // prefab: Prefab,
//
//    selection: SelectionState,
//    mode: EditorMode,
//    transform: ?TransformState,
//
//    //camera: rl.Camera2D, // für Pan/Zoom
//    // mouse: MouseState,
//
//    is_dirty: bool, // ungespeicherte Änderungen?
//
//    //pub fn init(screen_width: f32, screen_height: f32) EditorState {
//    //    return EditorState{
//    //        .selection = .{},
//    //        .mode = .Idle,
//    //        .transform = null,
//    //        //.camera = rl.Camera2D{
//    //        //    .offset = rl.Vector2{ .x = screen_width / 2.0, .y = screen_height / 2.0 },
//    //        //    .target = rl.Vector2{ .x = 0.0, .y = 0.0 },
//    //        //    .rotation = 0.0,
//    //        //    .zoom = 1.0,
//    //        //},
//    //        .is_dirty = false,
//    //    };
//    //}
//};

const screenWidth = 1920 / 2;
const screenHeight = 1080 / 2;

//var collider: Collider = undefined;
//var handle_state = HandleState{};
//const handle_radius: f32 = 8.0;
//var dragging_offset = Vec2{ .x = 0, .y = 0 };

//pub fn renderPrefab(prefab: *const Prefab, tex_cache: *TextureCache, allocator: std.mem.Allocator, selected: ?usize) !void {
//    _ = allocator;
//    for (prefab.parts, 0..) |part, i| {
//        const tex = try tex_cache.get(part.image_path);
//
//        const origin = rl.Vector2{
//            .x = @as(f32, @floatFromInt(tex.width)) * part.pivot.x,
//            .y = @as(f32, @floatFromInt(tex.height)) * part.pivot.y,
//        };
//
//        const dest_size = rl.Vector2{
//            .x = @as(f32, @floatFromInt(tex.width)) * part.scale.x,
//            .y = @as(f32, @floatFromInt(tex.height)) * part.scale.y,
//        };
//
//        rl.drawTexturePro(
//            tex,
//            rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(tex.width), .height = @floatFromInt(tex.height) },
//            rl.Rectangle{
//                .x = part.position.x,
//                .y = part.position.y,
//                .width = dest_size.x,
//                .height = dest_size.y,
//            },
//            origin,
//            part.rotation,
//            rl.Color.white,
//        );
//
//        if (selected != null and selected.? == i) {
//            const half_size = rl.Vector2{
//                .x = dest_size.x * 0.5,
//                .y = dest_size.y * 0.5,
//            };
//
//            // Punkte im lokalen Raum (relativ zur Mitte)
//            const corners = [_]rl.Vector2{
//                .{ .x = -half_size.x, .y = -half_size.y },
//                .{ .x = half_size.x, .y = -half_size.y },
//                .{ .x = half_size.x, .y = half_size.y },
//                .{ .x = -half_size.x, .y = half_size.y },
//            };
//
//            // Rotation in Grad → Bogenmaß
//            const rad = part.rotation * std.math.pi / 180.0;
//
//            // vorberechnete Sinus/Cosinus
//            const cos_theta = @cos(rad);
//            const sin_theta = @sin(rad);
//
//            // Transformierte Punkte
//            var transformed: [4]rl.Vector2 = undefined;
//            for (corners, 0..) |corner, j| {
//                const rotated = rl.Vector2{
//                    .x = corner.x * cos_theta - corner.y * sin_theta,
//                    .y = corner.x * sin_theta + corner.y * cos_theta,
//                };
//                transformed[j] = rl.Vector2{
//                    .x = part.position.x + rotated.x,
//                    .y = part.position.y + rotated.y,
//                };
//            }
//
//            // Linien zeichnen
//            for (transformed, 0..) |p, j| {
//                const next = transformed[(j + 1) % 4];
//                rl.drawLineEx(p, next, 4.0, rl.Color.yellow);
//            }
//        }
//    }
//}

pub const Control = struct {
    allocator: *std.mem.Allocator,
    state: State,

    should_request_snapshot: bool = true,

    arena_allocator: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator),

    //current: ?PrefabData = null,

    //editor: EditorState,

    pub fn init(allocator: *std.mem.Allocator) Control {
        var control = Control{
            .allocator = allocator,
            .state = State{},
            //.editor = EditorState.init(screenWidth, screenHeight),
        };

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        //const temp = util.ziggy.load(control.arena_allocator.allocator(), "res/prefab/test/visual.ziggy", Prefab) catch unreachable;
        //control.current = PrefabData.from(allocator.*, temp);
        control = control;
        return control;
    }

    pub fn deinit(self: *Control) void {
        //if (self.current) |*cur| {
        //    util.ziggy.save(self.arena_allocator.allocator(), "res/prefab/test/visual.ziggy", cur.to()) catch unreachable;
        //}

        log.info("stopped sucessfully", .{});

        //self.current.?.deinit();

        self.arena_allocator.deinit();
    }

    pub fn update(self: *Control) void {
        //const actions = captureInput(self.allocator);
        //actions.deinit();

        //Window.update();
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
        self.handleSelection();
        self.handleDragging();

        //const wheel = frontend.Input.getMouseWheelMove();
        //
        //if (Input.isKeyDown(Input.KeyboardKey.left_control) and Input.isKeyDown(Input.KeyboardKey.left_shift)) {
        //    if (self.current) |*cur| {
        //        if (self.editor.selection.selected_part) |val| {
        //            cur.parts_list.items[val].rotation = @mod(std.math.round(cur.parts_list.items[val].rotation + wheel), 360);
        //        }
        //    }
        //} else {
        //    self.handleZoom(wheel);
        //}

        // --- Drawing ---
        //Window.beginFrame();
        ////rl.clearBackground(rl.DARKGRAY);
        //rl.clearBackground(rl.Color.dark_brown);
        //
        //rl.beginMode2D(self.editor.camera);
        //// Render your prefab here
        //if (self.current) |*cur| {
        //    renderPrefab(&cur.to(), &self.cache, self.allocator.*, self.editor.selection.selected_part) catch unreachable;
        //}
        //rl.endMode2D();

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

        //Window.endFrame();
    }

    pub fn shouldStop(self: *Control) bool {
        return self.state.should_stop;
    }

    pub fn handleZoom(self: *Control, wheel: f32) void {
        if (wheel != 0) {
            const zoomFactor = 1.1;
            if (wheel > 0) {
                self.editor.camera.zoom *= zoomFactor;
            } else {
                self.editor.camera.zoom /= zoomFactor;
            }

            // Clamp zoom to avoid inversion or nan
            if (self.editor.camera.zoom < 0.05) self.editor.camera.zoom = 0.05;
            if (self.editor.camera.zoom > 15.0) self.editor.camera.zoom = 15.0;
        }
    }

    pub fn handleSelection(self: *Control) void {
        _ = self;
        //if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
        //    const mouse_world = rl.getScreenToWorld2D(rl.getMousePosition(), self.editor.camera);
        //
        //    if (self.current) |*cur| {
        //        var selected: ?usize = null;
        //
        //        select: for (0..cur.parts_list.items.len) |rev_index| {
        //            const i = cur.parts_list.items.len - 1 - rev_index;
        //            const part = cur.parts_list.items[i];
        //
        //            const tex = self.cache.get(part.image_path) catch continue;
        //
        //            const tex_size = rl.Vector2{
        //                .x = @as(f32, @floatFromInt(tex.width)) * part.scale.x,
        //                .y = @as(f32, @floatFromInt(tex.height)) * part.scale.y,
        //            };
        //
        //            const half = rl.Vector2{
        //                .x = tex_size.x * 0.5,
        //                .y = tex_size.y * 0.5,
        //            };
        //
        //            const rad = part.rotation * std.math.pi / 180.0;
        //            const cos_theta = @cos(rad);
        //            const sin_theta = @sin(rad);
        //
        //            const rel = rl.Vector2{
        //                .x = mouse_world.x - part.position.x,
        //                .y = mouse_world.y - part.position.y,
        //            };
        //
        //            const local = rl.Vector2{
        //                .x = rel.x * cos_theta + rel.y * sin_theta,
        //                .y = -rel.x * sin_theta + rel.y * cos_theta,
        //            };
        //
        //            const local_with_pivot = rl.Vector2{
        //                .x = local.x + tex_size.x * (part.pivot.x - 0.5),
        //                .y = local.y + tex_size.y * (part.pivot.y - 0.5),
        //            };
        //
        //            if (local_with_pivot.x >= -half.x and local_with_pivot.x <= half.x and
        //                local_with_pivot.y >= -half.y and local_with_pivot.y <= half.y)
        //            {
        //                selected = i;
        //                break :select;
        //            }
        //        }
        //
        //        self.editor.selection.selected_part = selected;
        //    }
        //}
    }

    pub fn handleDragging(self: *Control) void {
        _ = self;
        //if (rl.isMouseButtonPressed(rl.MouseButton.left) and rl.isKeyDown(rl.KeyboardKey.left_alt)) {
        //    const mouse_world = rl.getScreenToWorld2D(rl.getMousePosition(), self.editor.camera);
        //
        //    if (self.current) |*cur| {
        //        if (self.editor.selection.selected_part) |i| {
        //            const part = cur.parts_list.items[i];
        //            self.editor.transform = TransformState{
        //                .is_dragging = true,
        //                .start_mouse = mouse_world,
        //                .start_position = part.position,
        //            };
        //        }
        //    }
        //}
        //
        //if (rl.isMouseButtonDown(rl.MouseButton.left)) {
        //    if (self.editor.transform) |t| {
        //        if (t.is_dragging) {
        //            if (self.current) |*cur| {
        //                if (self.editor.selection.selected_part) |i| {
        //                    var part = &cur.parts_list.items[i];
        //
        //                    const mouse_world = rl.getScreenToWorld2D(rl.getMousePosition(), self.editor.camera);
        //                    const delta = Vec2{
        //                        .x = mouse_world.x - t.start_mouse.x,
        //                        .y = mouse_world.y - t.start_mouse.y,
        //                    };
        //
        //                    const snapping = !rl.isKeyDown(rl.KeyboardKey.left_shift);
        //                    const snap: f32 = if (snapping) 400.0 else 1.0;
        //
        //                    const new_pos = Vec2{
        //                        .x = t.start_position.x + delta.x,
        //                        .y = t.start_position.y + delta.y,
        //                    };
        //
        //                    part.position = Vec2{
        //                        .x = @round(new_pos.x / snap) * snap,
        //                        .y = @round(new_pos.y / snap) * snap,
        //                    };
        //
        //                    self.editor.is_dirty = true;
        //                }
        //            }
        //        }
        //    }
        //} else {
        //    if (self.editor.transform) |*t| {
        //        t.is_dragging = false;
        //    }
        //}
    }
};
