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

// ---------- external ----------
const rl = @import("raylib");
// ------------------------------

const GameObject = struct {
    position: rl.Vector2,
    rotation: f32,
};

const Ship = struct {
    base: GameObject,
    color: rl.Color,
    size: f32,
};

const Asteroid = struct {
    base: GameObject,
    radius: f32,
    rotation_speed: f32,
};

const Planet = struct {
    base: GameObject,
    radius: f32,
    atmosphere_color: rl.Color,
};

pub fn renderShip(ship: Ship) void {
    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(ship.base.position.x, ship.base.position.y, 0);
    rl.gl.rlRotatef(ship.base.rotation, 0, 0, 1);
    rl.gl.rlScalef(ship.base.scale, ship.base.scale, 1);

    // Primitives statt Texturen – klassisch/minimalistisch
    rl.gl.rlBegin(rl.TRIANGLES);
    rl.gl.rlColor3f(ship.color.r, ship.color.g, ship.color.b);

    const s = ship.size;
    rl.gl.rlVertex2f(0, -s); // Spitze
    rl.gl.rlVertex2f(-s * 0.5, s); // linkes Heck
    rl.gl.rlVertex2f(s * 0.5, s); // rechtes Heck
    rl.gl.rlEnd();

    rl.gl.rlPopMatrix();
}

pub fn renderAsteroid(ast: Asteroid, seed: u32) void {
    const segments = 12;
    const radius = ast.radius;
    const offset = radius * 0.3;

    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(ast.base.position.x, ast.base.position.y, 0);
    rl.gl.rlRotatef(ast.base.rotation, 0, 0, 1);
    rl.gl.rlColor3f(0.5, 0.5, 0.5);
    rl.gl.rlBegin(rl.TRIANGLE_FAN);
    rl.gl.rlVertex2f(0, 0); // Zentrum

    var i: usize = 0;
    while (i <= segments) : (i += 1) {
        const angle: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments)) * 2 * std.math.pi;
        const random: f32 = @sin(angle * 7 + @as(f32, @floatFromInt(seed))) * offset;
        const r: f32 = radius + random;
        rl.vertex2f(@cos(angle) * r, @sin(angle) * r);
    }
    rl.gl.rlEnd();
    rl.gl.rlPopMatrix();
}

pub fn renderPlanet(planet: Planet) void {
    rl.gl.rlPushMatrix();
    rl.gl.rlTranslatef(planet.base.position.x, planet.base.position.y, 0);

    // Atmosphäre
    rl.gl.rlColor4f(planet.atmosphere_color.r, planet.atmosphere_color.g, planet.atmosphere_color.b, 0.3);
    rl.gl.rlDrawCircleV(rl.Vector2{ .x = 0, .y = 0 }, planet.radius * 1.2, rl.fade(planet.atmosphere_color, 0.3));

    // Planet
    rl.gl.rlColor3f(0.1, 0.3, 0.8);
    rl.gl.rlDrawCircleV(rl.Vector2{ .x = 0, .y = 0 }, planet.radius, rl.BLUE);

    rl.gl.rlPopMatrix();
}
