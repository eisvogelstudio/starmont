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

// ---------- local ----------
const util = @import("../util/util.zig");
// ---------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

const log = std.log.scoped(.model);

pub const Id = util.UUID4;

pub const Registry = struct {
    allocator: *std.mem.Allocator,
    random: std.Random,

    id_to_entity: std.AutoHashMap(util.UUID4, ecs.entity_t),
    entity_to_id: std.AutoHashMap(ecs.entity_t, util.UUID4),

    pub fn init(allocator: *std.mem.Allocator, random: std.Random) Registry {
        return Registry{
            .allocator = allocator,
            .random = random,
            .id_to_entity = std.AutoHashMap(util.UUID4, ecs.entity_t).init(allocator.*),
            .entity_to_id = std.AutoHashMap(ecs.entity_t, util.UUID4).init(allocator.*),
        };
    }

    pub fn deinit(self: *Registry) void {
        self.id_to_entity.deinit();
        self.entity_to_id.deinit();
    }

    pub fn create(self: *Registry) util.UUID4 {
        const id = self.next_id;
        self.next_id.id += 1;
        return id;
    }

    pub fn register(self: *Registry, id: Id, entity: ecs.entity_t) void {
        if (self.id_to_entity.contains(id)) {
            self.remove(id);
            log.err("entity #{d} was already registered", .{id.toString()});
        }

        self.id_to_entity.put(id, entity) catch unreachable;
        self.entity_to_id.put(entity, id) catch unreachable;
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

test "Registry create and register" {
    var allocator = std.testing.allocator;
    var registry = Registry.init(&allocator);
    defer registry.deinit();

    const id1 = registry.create();
    try testing.expectEqual(id1, Id{ .id = 1 });

    const entity1: ecs.entity_t = 42;
    registry.register(id1, entity1);

    const retrieved_entity = registry.getEntity(id1);
    try testing.expect(retrieved_entity != null);
    try testing.expectEqual(retrieved_entity.?, entity1);

    const retrieved_id = registry.getId(entity1);
    try testing.expect(retrieved_id != null);
    try testing.expectEqual(retrieved_id.?.id, id1.id);
}

test "Registry register twice" {
    var allocator = std.testing.allocator;
    var registry = Registry.init(&allocator);
    defer registry.deinit();

    const id = registry.create();
    registry.register(id, 1);
    registry.register(id, 2);

    try testing.expectEqual(registry.getEntity(id).?, 2);
    try testing.expectEqual(registry.getId(2).?.id, id.id);
    try testing.expect(registry.getId(1) == null);
}

test "Registry remove" {
    var allocator = std.testing.allocator;
    var registry = Registry.init(&allocator);
    defer registry.deinit();

    const id = registry.create();
    registry.register(id, 123);

    registry.remove(id);

    try testing.expect(registry.getEntity(id) == null);
    try testing.expect(registry.getId(123) == null);
}

test "Registry get unknown" {
    var allocator = std.testing.allocator;
    var registry = Registry.init(&allocator);
    defer registry.deinit();

    const id = Id{ .id = 9999 };
    try testing.expect(registry.getEntity(id) == null);
    try testing.expect(registry.getId(8888) == null);
}
