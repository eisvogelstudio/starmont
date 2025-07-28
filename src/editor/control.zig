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

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const core = @import("shared").core;
const util = @import("util");
const FrontEvent = @import("frontend").FrontEvent;
const visual = @import("shared").visual;
const editor = @import("shared").editor;
const NodeRef = @import("shared").NodeRef;
const NodeMeta = @import("shared").NodeMeta;
const NodeMetaDTO = @import("shared").NodeMetaDTO;
const PrefabCache = @import("shared").PrefabCache;
// ------------------------------

// ---------- local ----------
const View = @import("view/view.zig").View;
// ---------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.control);

const name = "editor";
// ╚══════════════════════════════════════════════════════════════════╝

const Current = struct {
    ref: ?NodeRef = null,
    meta: ?NodeMeta = null,
    core: ?core.Prefab = null,
    visual: ?visual.Prefab = null,
};

// ┌──────────────────── State ────────────────────┐
const State = struct {
    should_stop: bool = false,
    selection: SelectionState = .{},
    current: Current = Current{},
};
// └───────────────────────────────────────────────┘

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

pub const Control = struct {
    allocator: *std.mem.Allocator,
    view: View,
    state: State,
    cache: PrefabCache,

    arena_allocator: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator),

    pub fn init(allocator: *std.mem.Allocator) Control {
        const control = Control{
            .allocator = allocator,
            .view = View.init(allocator, name),
            .state = State{},
            .cache = PrefabCache.init(allocator),
        };

        log.info("{s}-{s} v{s} started sucessfully", .{ core.name, name, core.version });
        log.info("All your starbase are belong to us", .{});

        return control;
    }

    pub fn deinit(self: *Control) void {
        log.info("stopped sucessfully", .{});

        self.cache.deinit();

        //if (self.state.current_ref) |cur| self.allocator.free(cur.getPath());
        if (self.state.current) |cur| cur.deinit();

        self.view.deinit();
        self.arena_allocator.deinit();
    }

    pub fn update(self: *Control) void {
        var events = self.view.pollEvents() catch {
            return;
        };
        defer {
            for (events.items) |e| {
                if (e == .Editor) {
                    switch (e.Editor) {
                        .FileOpen => |p| self.allocator.free(p),
                        else => {},
                    }
                }
            }
            events.deinit();
        }

        for (events.items) |ev| {
            switch (ev) {
                .Quit => self.state.should_stop = true,
                .Editor => |act| self.handleEditorAction(act) catch {},
                .CameraZoom => |z| self.handleZoom(z),
                .CameraPan => |delta| {
                    self.view.camera.target.x -= delta.x / self.view.camera.zoom;
                    self.view.camera.target.y -= delta.y / self.view.camera.zoom;
                },
                else => {},
            }
        }

        self.view.begin();
        if (self.state.current != null) self.view.renderPrefab(self.cache.loadVisual(self.state.current_ref.?), self.state.selection.selected_part);
        self.view.end();
    }

    pub fn shouldStop(self: *Control) bool {
        return self.state.should_stop;
    }

    pub fn handleZoom(self: *Control, wheel: f32) void {
        if (wheel != 0) {
            const zoomFactor = 1.1;
            if (wheel > 0) {
                self.view.camera.zoom *= zoomFactor;
            } else {
                self.view.camera.zoom /= zoomFactor;
            }

            // Clamp zoom to avoid inversion or nan
            if (self.view.camera.zoom < 0.05) self.view.camera.zoom = 0.05;
            if (self.view.camera.zoom > 15.0) self.view.camera.zoom = 15.0;
        }
    }

    fn handleEditorAction(self: *Control, action: editor.Action) !void {
        switch (action) {
            .FileOpen => |path| try self.openFile(path),
            .DeleteSelected => self.deleteSelected(),
            .FileSave => {
                //if (self.state.current_path) |p| {
                //    std.debug.print("{s}\n", .{self.state.current_path.?});
                //    try self.savePrefab(p);
                //}
            },
            .FileSaveAs => |p| {
                //if (self.state.current_path) |old| self.allocator.free(old);
                //self.state.current_path = try self.allocator.dupe(u8, p);
                //std.debug.print("{s}\n", .{self.state.current_path.?});
                //try self.savePrefab(p);
                _ = p;
            },
            else => {},
        }
    }

    fn openFile(self: *Control, path: []const u8) !void {
        const meta_ext = ".ziggy";
        const core_ext = ".core.ziggy";
        const visual_ext = ".visual.ziggy";

        if (std.mem.endsWith(u8, path, meta_ext)) {
            const base = path[0 .. path.len - meta_ext.len];
            const ref = NodeRef.fromPath(util.stripBeforeStarmont(base));
            self.state.current.ref = ref;
            self.state.current.meta = self.cache.loadMeta(ref).toMeta(self.allocator) catch unreachable;
            self.state.current.core = self.cache.loadCore(ref).toPrefab(self.allocator) catch unreachable;
            self.state.current.visual = self.cache.loadVisual(ref).to(self.allocator) catch unreachable;
        } else if (std.mem.endsWith(u8, path, core_ext)) {
            const base = path[0 .. path.len - core_ext.len];
            _ = self.cache.loadCore(NodeRef.fromPath(util.stripBeforeStarmont(base)));
        } else if (std.mem.endsWith(u8, path, visual_ext)) {
            const base = path[0 .. path.len - visual_ext.len];
            _ = self.cache.loadVisual(NodeRef.fromPath(util.stripBeforeStarmont(base)));
        } else if (std.mem.endsWith(u8, path, ".png")) {
            try self.readImage(path);
        } else {
            std.log.err("unsupported file: {s}", .{path});
        }
    }

    // if (!self.state.current.is) {
    //     if (std.mem.endsWith(u8, path, extention)) {
    //         self.state.current.is = true;
    //         const base = path[0 .. path.len - extention.len];
    //         self.state.current.path = try self.allocator.dupe(u8, base[0..base.len]);
    //
    //         try self.readFile(path, true);
    //
    //         const visual_path = try std.fmt.allocPrint(self.allocator.*, "{s}.visual.ziggy", .{base});
    //         defer self.allocator.free(visual_path);
    //         try self.readFile(visual_path, true);
    //
    //         const core_path = try std.fmt.allocPrint(self.allocator.*, "{s}.core.ziggy", .{base});
    //         defer self.allocator.free(core_path);
    //         try self.readFile(core_path, true);
    //     } else {
    //         std.debug.print("open a meta file (" ++ extention ++ ") first", .{});
    //     }
    // } else {
    //     if (std.mem.endsWith(u8, path, extention)) {
    //         const base = path[0 .. path.len - extention.len];
    //         try self.readFile(path, false);
    //
    //         const visual_path = try std.fmt.allocPrint(self.allocator.*, "{s}visual.ziggy", .{base});
    //         defer self.allocator.free(visual_path);
    //         try self.readFile(visual_path, false);
    //
    //         const core_path = try std.fmt.allocPrint(self.allocator.*, "{s}core.ziggy", .{base});
    //         defer self.allocator.free(core_path);
    //         try self.readFile(core_path, false);
    //     } else if (std.mem.endsWith(u8, path, ".png")) {
    //         try self.readImage(path);
    //     } else {
    //         std.debug.print("add a meta file (" ++ extention ++ ") or an image (.png)", .{});
    //     }
    // }
    //}

    fn readImage(self: *Control, path: []const u8) !void {
        if (std.mem.endsWith(u8, path, ".png")) {
            const asset = try visual.Asset.init(self.allocator, path);
            if (self.state.current != null) {
                const a = self.cache.loadVisual(self.state.current_ref.?).to(self.allocator) catch unreachable;
                a.assets.append(asset);
            }
        } else {
            std.debug.print("unsupported file type", .{});
        }
    }

    fn deleteSelected(self: *Control) void {
        //if (self.state.selection.selected_part) |idx| {
        //    const part = self.state.visual.orderedRemove(idx);
        //    self.allocator.free(part.image_path);
        //    self.state.selection.selected_part = null;
        //}
        _ = self;
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
