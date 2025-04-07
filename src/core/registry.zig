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
const testing = std.testing;
// -------------------------

// ---------- starmont ----------
const core = @import("root.zig");
// ------------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

pub const Registry = struct {
    allocator: *std.mem.Allocator,

    next_id: u64 = 1,

    id_to_entity: std.AutoHashMap(core.Id, ecs.entity_t),
    entity_to_id: std.AutoHashMap(ecs.entity_t, core.Id),

    pub fn init(allocator: *std.mem.Allocator) Registry {
        return Registry{
            .allocator = allocator,
            .id_to_entity = std.AutoHashMap(core.Id, ecs.entity_t).init(allocator.*),
            .entity_to_id = std.AutoHashMap(ecs.entity_t, core.Id).init(allocator.*),
        };
    }

    pub fn deinit(self: *Registry) void {
        self.id_to_entity.deinit();
        self.entity_to_id.deinit();
    }

    pub fn create(self: *Registry) core.Id {
        const id = self.next_id;
        self.next_id += 1;
        return id;
    }

    pub fn register(self: *Registry, id: core.Id, entity: ecs.entity_t) !void {
        try self.id_to_entity.put(id, entity);
        try self.entity_to_id.put(entity, id);
    }

    pub fn getEntity(self: *Registry, id: core.Id) ?ecs.entity_t {
        return self.id_to_entity.get(id);
    }

    pub fn getId(self: *Registry, entity: ecs.entity_t) ?core.Id {
        return self.entity_to_id.get(entity);
    }

    pub fn remove(self: *Registry, id: core.Id) void {
        if (self.id_to_entity.get(id)) |entity| {
            _ = self.entity_to_id.remove(entity);
        }
        _ = self.id_to_entity.remove(id);
    }
};
