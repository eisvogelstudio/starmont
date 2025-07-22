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

pub const Angle = union(enum) {
    degrees: f32,
    radians: f32,

    pub fn zero() Angle {
        return Angle.fromDegrees(0.0);
    }

    pub fn fromDegrees(deg: f32) Angle {
        return Angle{ .degrees = deg };
    }

    pub fn fromRadians(rad: f32) Angle {
        return Angle{ .radians = rad };
    }

    pub fn toRadians(self: Angle) f32 {
        return switch (self) {
            .degrees => |d| degToRad(d),
            .radians => |r| r,
        };
    }

    pub fn toDegrees(self: Angle) f32 {
        return switch (self) {
            .degrees => |d| d,
            .radians => |r| radToDeg(r),
        };
    }

    pub fn add(self: Angle, other: Angle) Angle {
        return switch (self) {
            .degrees => |d| Angle.degrees(d + other.toDegrees()),
            .radians => |r| Angle.radians(r + other.toRadians()),
        };
    }

    pub fn sub(self: Angle, other: Angle) Angle {
        return switch (self) {
            .degrees => Angle.degrees(self.toDegrees() - other.toDegrees()),
            .radians => Angle.radians(self.toRadians() - other.toRadians()),
        };
    }

    pub fn negate(self: Angle) Angle {
        return switch (self) {
            .degrees => Angle.degrees(-self.degrees),
            .radians => Angle.radians(-self.radians),
        };
    }

    pub fn normalize(self: Angle) Angle {
        return switch (self) {
            .degrees => Angle.degrees(normalizeDegrees(self.degrees)),
            .radians => Angle.radians(normalizeRadians(self.radians)),
        };
    }

    pub fn equals(self: Angle, other: Angle, epsilon: f32) bool {
        return std.math.approxEqAbs(f32, self.toRadians(), other.toRadians(), epsilon);
    }

    pub fn lerp(self: Angle, to: Angle, t: f32) Angle {
        return Angle.radians(std.math.lerp(self.toRadians(), to.toRadians(), t));
    }

    pub fn shortestDelta(self: Angle, to: Angle) Angle {
        const diff = normalizeRadians(to.toRadians() - self.toRadians());
        const wrapped = if (diff > std.math.pi) diff - 2 * std.math.pi else diff;
        return Angle.radians(wrapped);
    }

    pub fn isZero(self: Angle, epsilon: f32) bool {
        return @abs(self.toRadians()) < epsilon;
    }
};

fn degToRad(deg: f32) f32 {
    return deg * std.math.pi / 180.0;
}

fn radToDeg(rad: f32) f32 {
    return rad * 180.0 / std.math.pi;
}

fn normalizeDegrees(deg: f32) f32 {
    return std.math.fmod(fmodPositive(deg, 360.0), 360.0);
}

fn normalizeRadians(rad: f32) f32 {
    return std.math.fmod(fmodPositive(rad, 2 * std.math.pi), 2 * std.math.pi);
}

fn fmodPositive(x: f32, y: f32) f32 {
    const result = std.math.fmod(x, y);
    return if (result < 0.0) result + y else result;
}
