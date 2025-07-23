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

// ---------- external -----------
const rl = @import("raylib");
// -------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

pub const TextureEntry = struct {
    path: []const u8,
    texture: rl.Texture2D,
};

pub const TextureCache = struct {
    textures: std.ArrayList(TextureEntry),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) TextureCache {
        return TextureCache{
            .textures = std.ArrayList(TextureEntry).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn get(self: *TextureCache, path: []const u8) !rl.Texture2D {
        for (self.textures.items) |entry| {
            if (std.mem.eql(u8, entry.path, path)) return entry.texture;
        }

        const pathTerminated = try self.allocator.dupeZ(u8, path);
        defer self.allocator.free(pathTerminated);

        const tex = rl.loadTexture(pathTerminated) catch return error.TextureLoadFailed;

        const pathCopy = try self.allocator.dupe(u8, path);
        try self.textures.append(.{ .path = pathCopy, .texture = tex });

        return tex;
    }

    pub fn deinit(self: *TextureCache) void {
        for (self.textures.items) |entry| {
            rl.unloadTexture(entry.texture);
            self.allocator.free(entry.path);
        }
        self.textures.deinit();
    }
};
