pub const ConfigFlags = u32;
pub const Image = struct {};

pub fn initWindow(_: i32, _: i32, _: [:0]const u8) void {}

pub fn closeWindow() void {}

pub fn windowShouldClose() bool {
    return true;
}

pub fn isWindowReady() bool {
    return false;
}

pub fn isWindowFullscreen() bool {
    return false;
}

pub fn isWindowHidden() bool {
    return false;
}

pub fn isWindowMinimized() bool {
    return false;
}

pub fn isWindowMaximized() bool {
    return false;
}

pub fn isWindowFocused() bool {
    return false;
}

pub fn isWindowResized() bool {
    return false;
}

pub fn isWindowState(_: ConfigFlags) bool {
    return false;
}

pub fn setWindowState(_: ConfigFlags) void {}

pub fn clearWindowState(_: ConfigFlags) void {}

pub fn toggleFullscreen() void {}

pub fn toggleBorderlessWindowed() void {}

pub fn maximizeWindow() void {}

pub fn minimizeWindow() void {}

pub fn restoreWindow() void {}

pub fn setWindowIcon(_: Image) void {}

pub fn setWindowTitle(_: [:0]const u8) void {}

pub fn setWindowPosition(_: i32, _: i32) void {}

pub fn setWindowMonitor(_: i32) void {}

pub fn setWindowMinSize(_: i32, _: i32) void {}

pub fn setWindowMaxSize(_: i32, _: i32) void {}

pub fn setWindowSize(_: i32, _: i32) void {}

pub fn setWindowOpacity(_: f32) void {}

pub fn setWindowFocused() void {}

pub fn getWindowHandle() *anyopaque {
    return null;
}
