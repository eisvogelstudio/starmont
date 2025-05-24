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

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

const log = std.log.scoped(.model);

pub const Id = struct {
    id: u64,
};

pub const Registry = struct {
    allocator: *std.mem.Allocator,

    next_id: u64 = 1,

    id_to_entity: std.AutoHashMap(Id, ecs.entity_t),
    entity_to_id: std.AutoHashMap(ecs.entity_t, Id),

    pub fn init(allocator: *std.mem.Allocator) Registry {
        return Registry{
            .allocator = allocator,
            .id_to_entity = std.AutoHashMap(Id, ecs.entity_t).init(allocator.*),
            .entity_to_id = std.AutoHashMap(ecs.entity_t, Id).init(allocator.*),
        };
    }

    pub fn deinit(self: *Registry) void {
        self.id_to_entity.deinit();
        self.entity_to_id.deinit();
    }

    pub fn create(self: *Registry) Id {
        const id = self.next_id;
        self.next_id += 1;
        return id;
    }

    pub fn register(self: *Registry, id: Id, entity: ecs.entity_t) !void {
        if (self.id_to_entity.contains(id)) {
            self.remove(id);
            log.err("entity #{d} was already registered", .{id.id});
        }

        try self.id_to_entity.put(id, entity);
        try self.entity_to_id.put(entity, id);
    }

    pub fn getEntity(self: *Registry, id: Id) ?ecs.entity_t {
        return self.id_to_entity.get(id);
    }

    pub fn getId(self: *Registry, entity: ecs.entity_t) ?Id {
        return self.entity_to_id.get(entity);
    }

    pub fn remove(self: *Registry, id: Id) void {
        if (self.id_to_entity.get(id)) |entity| {
            _ = self.entity_to_id.remove(entity);
        }
        _ = self.id_to_entity.remove(id);
    }
};
