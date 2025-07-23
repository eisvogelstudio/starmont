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
// ------------------------------

// ---------- local ----------
const comp = @import("component.zig");
const tag = @import("tag.zig");
const sys = @import("system.zig");
// ----------------------------

const log = std.log.scoped(.model);

pub const Id = struct {
    uuid: util.UUID4,
};

pub const Registry = struct {
    allocator: *std.mem.Allocator,
    random: std.Random,
    world: *ecs.world_t,
    tick: u64 = 0,

    id_to_entity: std.AutoHashMap(Id, ecs.entity_t),
    entity_to_id: std.AutoHashMap(ecs.entity_t, Id),

    pub fn init(allocator: *std.mem.Allocator, random: std.Random) Registry {
        var registry = Registry{
            .allocator = allocator,
            .random = random,
            .world = ecs.init(),
            .tick = 0,
            .id_to_entity = std.AutoHashMap(Id, ecs.entity_t).init(allocator.*),
            .entity_to_id = std.AutoHashMap(ecs.entity_t, Id).init(allocator.*),
        };

        registry.registerComponents();
        registry.registerTags();
        registry.registerSystems();

        return registry;
    }

    pub fn deinit(self: *Registry) void {
        self.id_to_entity.deinit();
        self.entity_to_id.deinit();

        _ = ecs.fini(self.world);
    }

    pub fn update(self: *Registry) void {
        self.tick += 1;
        _ = ecs.progress(self.world, 0);
    }

    pub fn getEntity(self: *Registry, id: Id) ?ecs.entity_t {
        return self.id_to_entity.get(id);
    }

    pub fn getId(self: *Registry, entity: ecs.entity_t) ?Id {
        return self.entity_to_id.get(entity);
    }

    pub fn createEntity(self: *Registry) Id {
        const id = util.UUID4.generate(self.random);
        const entity = ecs.new_id(self.world);

        self.register(id, entity);

        return id;
    }

    pub fn addEntity(self: *Registry, id: Id) void {
        const entity = ecs.new_id(self.world);

        if (self.getEntity(id) != null) {
            self.unregister(id);
            std.log.warn("entity {d} already existed", .{id.uuid.toString()});
        }

        self.register(id, entity);
    }

    pub fn removeEntity(self: *Registry, id: Id) void {
        if (self.getEntity(id) != null) {
            self.unregister(id);
        } else {
            std.log.warn("tried to remove core from unknown entity", .{});
        }
    }

    pub fn setComponent(self: *Registry, id: Id, T: type, value: T) void {
        const entity = self.getEntity(id);

        if (entity) |e| {
            _ = ecs.set(self.world, e, T, value);
        } else {
            std.log.warn("tried to set component to unknown entity", .{});
        }
    }

    pub fn removeComponent(self: *Registry, id: Id, T: type) void {
        const entity = self.getEntity(id);

        if (entity) |e| {
            _ = ecs.remove(self.world, e, T);
        } else {
            std.log.warn("tried to remove component from unknown entity", .{});
        }
    }

    fn register(self: *Registry, id: Id, entity: ecs.entity_t) void {
        if (self.id_to_entity.contains(id)) {
            self.removeEntity(id);
            log.err("entity {d} was already registered", .{id.uuid.toString()});
        }

        self.id_to_entity.put(id, entity) catch unreachable;
        self.entity_to_id.put(entity, id) catch unreachable;
    }

    fn unregister(self: *Registry, id: Id) void {
        const entity = self.getEntity(id);
        if (entity) |e| {
            ecs.delete(self.world, e);
            if (self.entity_to_id.get(e) != null) {
                _ = self.entity_to_id.remove(e);
            }
            _ = self.id_to_entity.remove(id);
        }
    }

    fn registerComponents(self: *Registry) void {
        ecs.COMPONENT(self.world, comp.Position);
        ecs.COMPONENT(self.world, comp.Velocity);
        ecs.COMPONENT(self.world, comp.Acceleration);
        ecs.COMPONENT(self.world, comp.Jerk);

        ecs.COMPONENT(self.world, comp.Rotation);
        ecs.COMPONENT(self.world, comp.RotationalVelocity);
        ecs.COMPONENT(self.world, comp.RotationalAcceleration);

        ecs.COMPONENT(self.world, comp.ShipSize);
    }

    fn registerTags(self: *Registry) void {
        ecs.TAG(self.world, tag.Player);

        ecs.TAG(self.world, tag.Ship);

        ecs.TAG(self.world, tag.Small);
        ecs.TAG(self.world, tag.Medium);
        ecs.TAG(self.world, tag.Large);
        ecs.TAG(self.world, tag.Capital);

        ecs.TAG(self.world, tag.Visible);
    }

    fn registerSystems(self: *Registry) void {
        const jerk_id = ecs.ADD_SYSTEM(self.world, "apply_jerk", ecs.OnUpdate, sys.applyJerk);

        const accel_accelerated_id = ecs.ADD_SYSTEM(self.world, "apply_acceleration_accelerated", ecs.OnUpdate, sys.applyAccelerationAccelerated);
        const accel_dynamic_id = ecs.ADD_SYSTEM(self.world, "apply_acceleration_dynamic", ecs.OnUpdate, sys.applyAccelerationDynamic);

        const velocity_linear_id = ecs.ADD_SYSTEM(self.world, "apply_velocity_linear", ecs.OnUpdate, sys.applyVelocityLinear);
        const velocity_accelerated_id = ecs.ADD_SYSTEM(self.world, "apply_velocity_accelerated", ecs.OnUpdate, sys.applyVelocityAccelerated);
        const velocity_dynamic_id = ecs.ADD_SYSTEM(self.world, "apply_velocity_dynamic", ecs.OnUpdate, sys.applyVelocityDynamic);

        _ = jerk_id;

        _ = accel_accelerated_id;
        _ = accel_dynamic_id;

        _ = velocity_linear_id;
        _ = velocity_accelerated_id;
        _ = velocity_dynamic_id;
    }
};
