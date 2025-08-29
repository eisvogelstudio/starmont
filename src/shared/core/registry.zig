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
const kinematic = @import("kinematic.zig");
const movement = @import("movement.zig");
const PhysicsSpace = @import("physics/space.zig").PhysicsSpace;
const Collider = @import("physics/collider.zig").Collider;
// ----------------------------

const log = std.log.scoped(.registry);

pub const Id = struct {
    uuid: util.UUID4,
};

pub const Registry = struct {
    gpa: *std.mem.Allocator,
    random: std.Random,
    world: *ecs.world_t,
    space: PhysicsSpace,
    tick: u64 = 0,

    id_to_entity: std.AutoHashMap(Id, ecs.entity_t),
    entity_to_id: std.AutoHashMap(ecs.entity_t, Id),

    pub fn init(gpa: *std.mem.Allocator, random: std.Random) Registry {
        var registry = Registry{
            .gpa = gpa,
            .random = random,
            .world = ecs.init(),
            .space = PhysicsSpace.init(gpa.*),
            .tick = 0,
            .id_to_entity = std.AutoHashMap(Id, ecs.entity_t).init(gpa.*),
            .entity_to_id = std.AutoHashMap(ecs.entity_t, Id).init(gpa.*),
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

        const desc = ecs.query_desc_t{
            .terms = [_]ecs.term_t{
                term(comp.Position),
                //term(comp.Velocity),
                //term_optional(comp.Rotation),
                //term_optional(comp.AngularVelocity),
                //term_optional(comp.AngularAcceleration),
                //term_tag(tag.MovementPhysics),
                //term_tag(tag.SimulationLocal),
            } ++ [_]ecs.term_t{.{}} ** (ecs.FLECS_TERM_COUNT_MAX - 1),
        };

        const query = ecs.query_init(self.world, &desc) catch unreachable;

        self.space.update();

        var it = ecs.query_iter(self.world, query);
        while (ecs.iter_next(&it)) {
            self.space.syncFromPhysics(&it);
        }
    }

    pub fn getEntity(self: *Registry, id: Id) ?ecs.entity_t {
        return self.id_to_entity.get(id);
    }

    pub fn getId(self: *Registry, entity: ecs.entity_t) ?Id {
        return self.entity_to_id.get(entity);
    }

    pub fn createEntity(self: *Registry) Id {
        const id = Id{ .uuid = util.UUID4.generate(self.random) };
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
        ecs.COMPONENT(self.world, comp.AngularVelocity);
        ecs.COMPONENT(self.world, comp.AngularAcceleration);

        ecs.COMPONENT(self.world, comp.ShipSize);
        ecs.COMPONENT(self.world, comp.ShipName);

        ecs.COMPONENT(self.world, Collider);
        ecs.COMPONENT(self.world, comp.PhysicsBody);
    }

    fn registerTags(self: *Registry) void {
        ecs.TAG(self.world, tag.Player);

        ecs.TAG(self.world, tag.Ship);

        ecs.TAG(self.world, tag.SizeSmall);
        ecs.TAG(self.world, tag.SizeMedium);
        ecs.TAG(self.world, tag.SizeLarge);
        ecs.TAG(self.world, tag.SizeCapital);

        ecs.TAG(self.world, tag.Visible);

        ecs.TAG(self.world, tag.MovementStatic);
        ecs.TAG(self.world, tag.MovementKinematic);
        ecs.TAG(self.world, tag.MovementPhysics);
        ecs.TAG(self.world, tag.MovementScripted);
    }

    fn registerSystems(self: *Registry) void {
        const filters_linear = [_]ecs.term_t{
            term_in(comp.Velocity),
        };

        const filters_accelerated = [_]ecs.term_t{
            term_in(comp.Acceleration),
        };

        const filters_dynamic = [_]ecs.term_t{
            term_in(comp.Jerk),
        };

        _ = ecs.ADD_SYSTEM_WITH_FILTERS(
            self.world,
            "ensure_linear",
            ecs.OnUpdate,
            movement.ensureMotionChainLinear,
            &filters_linear,
        );

        _ = ecs.ADD_SYSTEM_WITH_FILTERS(
            self.world,
            "ensure_accelerated",
            ecs.OnUpdate,
            movement.ensureMotionChainAccelerated,
            &filters_accelerated,
        );

        _ = ecs.ADD_SYSTEM_WITH_FILTERS(
            self.world,
            "ensure_dynamic",
            ecs.OnUpdate,
            movement.ensureMotionChainDynamic,
            &filters_dynamic,
        );

        _ = ecs.ADD_SYSTEM(self.world, "advance_linear", ecs.OnUpdate, kinematic.advanceMovementLinear);
        _ = ecs.ADD_SYSTEM(self.world, "advance_accelerated", ecs.OnUpdate, kinematic.advanceMovementAccelerated);
        _ = ecs.ADD_SYSTEM(self.world, "advance_dynamic", ecs.OnUpdate, kinematic.advanceMovementDynamic);
    }

    fn termFull(
        comptime T: type,
        inout: ecs.inout_kind_t,
        oper: ecs.oper_kind_t,
    ) ecs.term_t {
        return .{
            .id = ecs.id(T),
            .inout = inout,
            .oper = oper,
        };
    }

    fn term(comptime T: type) ecs.term_t {
        return termFull(
            T,
            ecs.inout_kind_t.InOutDefault,
            ecs.oper_kind_t.And,
        );
    }

    fn term_optional(comptime T: type) ecs.term_t {
        return termFull(
            T,
            ecs.inout_kind_t.InOutDefault,
            ecs.oper_kind_t.Optional,
        );
    }

    fn term_tag(comptime T: type) ecs.term_t {
        return termFull(
            T,
            ecs.inout_kind_t.InOutNone,
            ecs.oper_kind_t.And,
        );
    }

    fn term_in(comptime T: type) ecs.term_t {
        return termFull(T, ecs.inout_kind_t.In, ecs.oper_kind_t.And);
    }

    fn term_out(comptime T: type) ecs.term_t {
        return termFull(T, ecs.inout_kind_t.Out, ecs.oper_kind_t.And);
    }

    fn term_filter(comptime T: type) ecs.term_t {
        return termFull(T, ecs.inout_kind_t.EcsInOutFilter, ecs.oper_kind_t.And);
    }

    pub fn createShipDefault(self: *Registry) Id {
        const circle = util.CircleShape.init(5.0);
        return self.createShip(self.world, Collider.fromShape(circle));
    }

    fn createShip(self: *Registry, world: *ecs.world_t, collider: Collider) Id {
        const ship = self.createEntity();
        const entity = self.getEntity(ship).?;

        _ = ecs.set(world, entity, comp.ShipName, comp.ShipName{ .official = "USS Ziggy" });

        const body = comp.PhysicsBody{ .collider = self.createPhysicsBody(world, collider) };
        _ = ecs.set(world, entity, comp.PhysicsBody, body);

        self.space.addEntity(world, entity, true);

        return ship;
    }

    fn createPhysicsBody(self: *Registry, world: *ecs.world_t, collider: Collider) Id {
        const body = self.createEntity();
        const entity = self.getEntity(body).?;

        _ = ecs.set(world, entity, comp.Position, comp.Position{ .x = 0, .y = 0 });
        _ = ecs.set(world, entity, comp.Velocity, comp.Velocity{ .x = 0, .y = 0 });
        _ = ecs.set(world, entity, comp.Acceleration, comp.Acceleration{ .x = 0, .y = 0 });
        _ = ecs.set(world, entity, comp.Jerk, comp.Jerk{ .x = 0, .y = 0 });
        _ = ecs.set(world, entity, comp.Rotation, comp.Rotation{ .value = util.Angle.zero() });
        _ = ecs.set(world, entity, comp.AngularVelocity, comp.AngularVelocity{ .value = util.Angle.zero() });
        _ = ecs.set(world, entity, comp.AngularAcceleration, comp.AngularAcceleration{ .value = util.Angle.zero() });

        _ = ecs.set(world, entity, Collider, collider);

        self.space.addEntity(world, entity, false);
        return body;
    }
};
