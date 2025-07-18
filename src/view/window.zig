const builtin = @import("builtin");

const build_options = @import("build_options");
const hasRenderer = build_options.hasRenderer;

const rl = if (hasRenderer) @import("raylib") else @import("raylib.zig");

pub const Window = struct {
    pub fn open(title: []const u8, width: i32, height: i32) void {
        _ = title;
        rl.initWindow(width, height, "todo");
        rl.setTargetFPS(60);
        applyScale();
    }

    pub fn update() void {
        //applyScale();
    }

    pub fn close() void {
        rl.closeWindow();
    }

    pub fn shouldClose() bool {
        return rl.windowShouldClose();
    }

    pub fn beginFrame() void {
        rl.beginDrawing();
    }

    pub fn endFrame() void {
        rl.endDrawing();
    }

    pub fn clear() void {
        rl.clearBackground(rl.Color.gold);
    }

    pub fn getWidth() i32 {
        return rl.getScreenWidth();
    }

    pub fn getHeight() i32 {
        return rl.getScreenHeight();
    }

    fn applyScale() void {
        const dpiScale = rl.getWindowScaleDPI();
        const newWidth = @divFloor(@as(f32, @floatFromInt(rl.getScreenWidth())), dpiScale.x);
        const newHeight = @divFloor(@as(f32, @floatFromInt(rl.getScreenHeight())), dpiScale.y);

        rl.setWindowSize(@intFromFloat(newWidth), @intFromFloat(newHeight));
        rl.setMouseScale(dpiScale.x, dpiScale.y);
    }
};

//see: https://gist.github.com/JeffM2501/00cf5653f41337d8c9e8db40deb25656

//https://github.com/raysan5/raylib/issues/2566
