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
const util = @import("util");
// ------------------------------

// ---------- local ----------
const no = @import("node.zig");
const co = @import("core/core.zig");
const vi = @import("visual/visual.zig");
// ---------------------------

pub const PrefabCache = struct {
    gpa: *std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    meta: std.AutoHashMap(usize, no.NodeMetaDTO),
    core: std.AutoHashMap(usize, co.PrefabDTO),
    visual: std.AutoHashMap(usize, vi.PrefabDTO),
    last_used: std.AutoHashMap(usize, i64),

    const max_unused = 120;

    pub fn init(gpa: *std.mem.Allocator) PrefabCache {
        const cache = PrefabCache{
            .gpa = gpa,
            .arena = std.heap.ArenaAllocator.init(gpa.*),
            .meta = std.AutoHashMap(usize, no.NodeMetaDTO).init(gpa.*),
            .core = std.AutoHashMap(usize, co.PrefabDTO).init(gpa.*),
            .visual = std.AutoHashMap(usize, vi.PrefabDTO).init(gpa.*),
            .last_used = std.AutoHashMap(usize, i64).init(gpa.*),
        };

        return cache;
    }

    pub fn deinit(self: *PrefabCache) void {
        var meta_it = self.meta.iterator();
        while (meta_it.next()) |entry| {
            entry.value_ptr.*.free(self.gpa);
        }

        var core_it = self.core.iterator();
        while (core_it.next()) |entry| {
            entry.value_ptr.*.free(self.gpa);
        }

        var visual_it = self.visual.iterator();
        while (visual_it.next()) |entry| {
            entry.value_ptr.*.free(self.gpa);
        }

        self.meta.deinit();
        self.core.deinit();
        self.visual.deinit();
        self.last_used.deinit();
        self.arena.deinit();
    }

    pub fn loadMeta(self: *PrefabCache, ref: no.NodeRef) *const no.NodeMetaDTO {
        const id = ref.getId();

        self.last_used.put(id, std.time.timestamp()) catch unreachable;

        if (self.meta.get(id)) |m| {
            return &m;
        } else {
            const meta = self.readMeta(ref.getPath()) catch @panic("failed reading meta");
            self.meta.put(id, meta) catch unreachable;
            _ = self.arena.reset(.retain_capacity);
            return &self.meta.get(id).?;
        }
    }

    pub fn storeMeta(self: *PrefabCache, ref: no.NodeRef, meta: no.NodeMeta) void {
        const id = ref.getId();

        if (self.last_used.get(id)) |time| {
            if (time > max_unused) {
                self.unload(ref);
            }
        }

        self.writeMeta(ref.getPath(), no.NodeMetaDTO.fromMeta(&meta, self.gpa.*) catch unreachable) catch unreachable;
    }

    pub fn loadCore(self: *PrefabCache, ref: no.NodeRef) *const co.PrefabDTO {
        const id = ref.getId();

        self.last_used.put(id, std.time.timestamp()) catch unreachable;

        if (self.core.get(id)) |c| {
            return &c;
        } else {
            const core = self.readCore(ref.getPath()) catch @panic("failed reading core");
            self.core.put(id, core) catch unreachable;
            _ = self.arena.reset(.retain_capacity);
            return &self.core.get(id).?;
        }
    }

    //pub fn storeCore(self: *PrefabCache, ref: no.NodeRef, meta: co.PrefabDTO) void {}

    pub fn loadVisual(self: *PrefabCache, ref: no.NodeRef) *const vi.PrefabDTO {
        const id = ref.getId();

        self.last_used.put(id, std.time.timestamp()) catch unreachable;

        if (self.visual.get(id)) |v| {
            return &v;
        } else {
            const visual = self.readVisual(ref.getPath()) catch @panic("failed reading visual");
            self.visual.put(id, visual) catch unreachable;
            _ = self.arena.reset(.retain_capacity);
            return &self.visual.get(id).?;
        }
    }

    //pub fn storeVisual(self: *PrefabCache, ref: no.NodeRef, meta: vi.PrefabDTO) void {}

    fn readMeta(self: *PrefabCache, base: []const u8) !no.NodeMetaDTO {
        var allocator = self.arena.allocator();

        const meta_path = try std.fmt.allocPrint(allocator, "{s}.ziggy", .{base});
        defer allocator.free(meta_path);
        const load = try util.ziggy.load(allocator, meta_path, no.NodeMetaDTO);

        if (load) |m| {
            return m.copy(self.gpa);
        } else {
            unreachable;
        }
    }

    fn writeMeta(self: *PrefabCache, base: []const u8, meta: no.NodeMetaDTO) !void {
        var allocator = self.arena.allocator();

        const meta_path = try std.fmt.allocPrint(allocator, "{s}.ziggy", .{base});
        defer allocator.free(meta_path);
        try util.ziggy.save(allocator, meta_path, meta);
    }

    fn readCore(self: *PrefabCache, base: []const u8) !co.PrefabDTO {
        var allocator = self.arena.allocator();

        const core_path = try std.fmt.allocPrint(allocator, "{s}.core.ziggy", .{base});
        defer allocator.free(core_path);
        const load = try util.ziggy.load(allocator, core_path, co.PrefabDTO);

        if (load) |dto| {
            return dto.copy(self.gpa);
        } else {
            unreachable;
        }
    }

    fn readVisual(self: *PrefabCache, base: []const u8) !vi.PrefabDTO {
        var allocator = self.arena.allocator();

        const core_path = try std.fmt.allocPrint(allocator, "{s}.visual.ziggy", .{base});
        defer allocator.free(core_path);
        const load = try util.ziggy.load(allocator, core_path, vi.PrefabDTO);

        if (load) |dto| {
            return dto.copy(self.gpa);
        } else {
            unreachable;
        }
    }

    fn unload(self: *PrefabCache, ref: no.NodeRef) void {
        const id = ref.getId();

        _ = self.meta.remove(id);
        _ = self.core.remove(id);
        _ = self.visual.remove(id);
        _ = self.last_used.remove(id);
    }

    fn evictLeastUsed(self: *PrefabCache) !void {
        var it = self.last_used.iterator();
        var oldest: ?[]const u8 = null;
        var oldest_time: u64 = std.math.maxInt(u64);

        while (it.next()) |entry| {
            if (entry.value < oldest_time) {
                oldest_time = entry.value;
                oldest = entry.key;
            }
        }

        if (oldest) |key| {
            self.unload(key);
        }
    }
};
