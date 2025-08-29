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
const zchip = @import("zchip2d");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ------
const comp = @import("../component.zig");
// ------------------------

const Collider = @import("collider.zig").Collider;

const ForceCommand = struct {
    entity: ecs.entity_t,
    force: util.Vec2,
    offset: ?util.Vec2 = null,
};

pub const PhysicsSpace = struct {
    space: *zchip.cpSpace,
    body_map: std.AutoHashMap(ecs.entity_t, *zchip.cpBody),

    force_queue: std.ArrayList(ForceCommand),

    pub fn init(allocator: std.mem.Allocator) PhysicsSpace {
        return PhysicsSpace{
            .space = zchip.cpSpaceNew() orelse @panic("failed to init zchip2d space"),
            .body_map = std.AutoHashMap(ecs.entity_t, *zchip.cpBody).init(allocator),
            .force_queue = std.ArrayList(ForceCommand).init(allocator),
        };
    }

    pub fn deinit(self: *PhysicsSpace) void {
        self.body_map.deinit();

        zchip.cpSpaceFree(self.space);
    }

    pub fn update(self: *PhysicsSpace) void {
        for (self.force_queue.items) |cmd| {
            const body = self.getBody(cmd.entity) orelse unreachable;

            if (cmd.offset) |p| {
                const world_point = zchip.cpv(@floatCast(p.x), @floatCast(p.y));
                const world_force = zchip.cpv(@floatCast(cmd.force.x), @floatCast(cmd.force.y));
                zchip.cpBodyApplyForceAtWorldPoint(body, world_force, world_point);
            } else {
                const world_force = zchip.cpv(@floatCast(cmd.force.x), @floatCast(cmd.force.y));
                zchip.cpBodyApplyForceAtWorldPoint(body, world_force, zchip.cpv(0, 0));
            }
        }

        const dt: f64 = 1.0 / 60.0; // 60 Hz
        zchip.cpSpaceStep(self.space, dt);
    }

    pub fn applyForce(self: *PhysicsSpace, entity: ecs.entity_t, force: util.Vec2, offset: ?util.Vec2) void {
        const cmd = ForceCommand{
            .entity = entity,
            .force = force,
            .offset = offset,
        };

        self.force_queue.append(cmd) catch unreachable;
    }

    pub fn getBody(self: *const PhysicsSpace, e: ecs.entity_t) ?*zchip.cpBody {
        return self.body_map.get(e);
    }

    pub fn syncFromPhysics(self: *const PhysicsSpace, it: *ecs.iter_t) void {
        const entities = it.entities();
        const pos = ecs.field(it, comp.Position, 0).?;
        //const vel = ecs.field(it, comp.Velocity, 1).?;
        //const angle = ecs.field(it, comp.Rotation, 2) orelse null;
        //const ang_vel = ecs.field(it, comp.AngularVelocity, 3) orelse null;

        for (entities, 0..) |e, i| {
            const body = self.getBody(e) orelse continue;

            const cp_pos = zchip.cpBodyGetPosition(body);
            //const cp_vel = zchip.cpBodyGetVelocity(body);

            pos[i].x = @floatCast(cp_pos.x);
            pos[i].y = @floatCast(cp_pos.y);
            //vel[i].x = @floatCast(cp_vel.x);
            //vel[i].y = @floatCast(cp_vel.y);

            //if (angle) |a| {
            //    a[i].value = util.Angle.fromRadians(@floatCast(zchip.cpBodyGetAngle(body)));
            //}
            //
            //if (ang_vel) |w| {
            //    w[i].value = util.Angle.fromRadians(@floatCast(zchip.cpBodyGetAngularVelocity(body)));
            //}
        }
    }

    pub fn addEntity(self: *PhysicsSpace, world: *ecs.world_t, e: ecs.entity_t, with_rotation: bool) void {
        if (!ecs.has_id(world, e, ecs.id(comp.Position))) {
            _ = ecs.set(world, e, comp.Position, comp.Position{ .x = 0, .y = 0 });
        }
        if (!ecs.has_id(world, e, ecs.id(comp.Velocity))) {
            _ = ecs.set(world, e, comp.Velocity, comp.Velocity{ .x = 0, .y = 0 });
        }

        const pos = ecs.get(world, e, comp.Position).?;
        const vel = ecs.get(world, e, comp.Velocity).?;

        var angle: f32 = 0.0;
        var ang_vel: f32 = 0.0;
        var moment: f32 = std.math.floatMax(f32);

        if (with_rotation) {
            if (!ecs.has_id(world, e, ecs.id(comp.Rotation))) {
                _ = ecs.set(world, e, comp.Rotation, comp.Rotation{ .value = util.Angle.zero() });
            }
            if (!ecs.has_id(world, e, ecs.id(comp.AngularVelocity))) {
                _ = ecs.set(world, e, comp.AngularVelocity, comp.AngularVelocity{ .value = util.Angle.zero() });
            }

            angle = ecs.get(world, e, comp.Rotation).?.value.toRadians();
            ang_vel = ecs.get(world, e, comp.AngularVelocity).?.value.toRadians();
        }

        const has_collider = ecs.has_id(world, e, ecs.id(Collider));
        const collider = if (has_collider) ecs.get(world, e, Collider).? else null;

        // Compute moment based on shape
        if (has_collider and with_rotation) {
            const offset = collider.?.offset;
            const vec = zchip.cpv(
                @floatCast(offset.x),
                @floatCast(offset.y),
            );
            moment = switch (collider.?.shape) {
                .Circle => |circle| @floatCast(zchip.cpMomentForCircle(
                    @floatCast(1.0),
                    @floatCast(0.0),
                    @floatCast(circle.radius),
                    vec,
                )),
                .Box => |box| @floatCast(zchip.cpMomentForBox(
                    @floatCast(1.0),
                    @floatCast(box.extend.x),
                    @floatCast(box.extend.y),
                )),
                else => std.math.floatMax(f32),
            };
        }

        const body = zchip.cpBodyNew(1.0, moment) orelse @panic("Failed to allocate cpBody");
        zchip.cpBodySetPosition(body, .{ .x = pos.x, .y = pos.y });
        zchip.cpBodySetVelocity(body, .{ .x = vel.x, .y = vel.y });
        if (with_rotation) {
            zchip.cpBodySetAngle(body, angle);
            zchip.cpBodySetAngularVelocity(body, ang_vel);
        } else {
            zchip.cpBodySetMoment(body, std.math.floatMax(f32)); // already done
            zchip.cpBodySetAngle(body, 0.0);
        }

        _ = zchip.cpSpaceAddBody(self.space, body);

        // Add shape if collider exists
        if (has_collider) {
            const offset = collider.?.offset;
            const vec = zchip.cpv(
                @floatCast(offset.x),
                @floatCast(offset.y),
            );
            const shape = switch (collider.?.shape) {
                .Circle => |circle| zchip.cpCircleShapeNew(body, circle.radius, vec),
                .Box => |box| zchip.cpBoxShapeNew2(body, .{
                    .l = -box.extend.x / 2,
                    .r = box.extend.x / 2,
                    .b = -box.extend.y / 2,
                    .t = box.extend.y / 2,
                }, 0.0),
                else => null,
            } orelse @panic("Failed to create shape");

            zchip.cpShapeSetSensor(shape, if (collider.?.is_sensor) 1 else 0);
            _ = zchip.cpSpaceAddShape(self.space, shape);
        }

        self.body_map.put(e, body) catch @panic("Failed to insert body into map");
    }

    pub fn addEntityWithRotation(self: *PhysicsSpace, world: *ecs.world_t, e: ecs.entity_t) void {
        self.addEntity(world, e, true);
    }

    pub fn addEntityNoRotation(self: *PhysicsSpace, world: *ecs.world_t, e: ecs.entity_t) void {
        self.addEntity(world, e, false);
    }
};
