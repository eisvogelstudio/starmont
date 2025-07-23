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

// ---------- shared ----------
const core = @import("shared").core;
const util = @import("shared").util;
// ----------------------------

// ---------- shared ----------
const frontend = @import("frontend");
const Input = frontend.Input;
const Window = frontend.Window;
const TextureCache = frontend.TextureCache;
// ----------------------------

// ---------- external ----------
const ecs = @import("zflecs");
// ------------------------------

// ╔══════════════════════════════ init ══════════════════════════════╗
const log = std.log.scoped(.view);
// ╚══════════════════════════════════════════════════════════════════╝

pub const View = struct {
    allocator: *std.mem.Allocator,
    cache: TextureCache,

    //TODO[MISSING] make dynamic
    const screen_width = 1920 / 2;
    const screen_height = 1080 / 2;

    pub fn init(allocator: *std.mem.Allocator, name: []const u8) View {
        const view = View{
            .allocator = allocator,
            .cache = TextureCache.init(allocator.*),
        };

        Window.open(name, screen_width, screen_height);

        return view;
    }

    pub fn deinit(self: *View) void {
        self.cache.deinit(); //has to be called before `Window.close()`

        Window.close();
    }

    pub fn update(self: *View, model: *core.Model) void {
        Window.update();
        Window.beginFrame();

        Window.endFrame();

        _ = self;
        _ = model;
    }
};
