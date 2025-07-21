const std = @import("std");
const rl = @import("raylib");

pub const TextureEntry = struct {
    path: []const u8,
    texture: rl.Texture2D,
};

fn nullTerminate(allocator: std.mem.Allocator, input: []const u8) ![:0]const u8 {
    const buffer = try allocator.allocSentinel(u8, input.len, 0); // null-terminiert
    std.mem.copyForwards(u8, buffer, input);
    return buffer;
}

pub const TextureCache = struct {
    textures: std.ArrayList(TextureEntry),

    pub fn init(allocator: std.mem.Allocator) TextureCache {
        return TextureCache{
            .textures = std.ArrayList(TextureEntry).init(allocator),
        };
    }

    pub fn get(self: *TextureCache, allocator: std.mem.Allocator, path: []const u8) !rl.Texture2D {
        for (self.textures.items) |entry| {
            if (std.mem.eql(u8, entry.path, path)) return entry.texture;
        }

        // Load if not already in cache
        const c_path = nullTerminate(allocator, path) catch unreachable;
        const tex = rl.loadTexture(c_path) catch unreachable;
        try self.textures.append(.{ .path = path, .texture = tex });
        return tex;
    }

    pub fn deinit(self: *TextureCache) void {
        for (self.textures.items) |entry| {
            rl.unloadTexture(entry.texture);
        }
        self.textures.deinit();
    }
};
