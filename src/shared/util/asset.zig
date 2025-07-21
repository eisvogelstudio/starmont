// ---------- std ----------
const std = @import("std");
// -------------------------

// ---------- external ----------
const ziggy = @import("ziggy");
// ------------------------------

const Asset = struct {
    foo: []const u8,
    bar: bool,
};

pub fn loadAsset(arena: *std.heap.ArenaAllocator) !void {
    var allocator = arena.allocator();

    const fs = std.fs.cwd();
    const file = fs.openFile("test.ziggy", .{}) catch unreachable;
    defer file.close();

    const stat = file.stat() catch unreachable;
    file.seekTo(0) catch unreachable;

    const raw = try allocator.alloc(u8, stat.size);
    defer allocator.free(raw);

    //_ = try file.readAll(raw);

    //const file_data = try allocator.dupeZ(u8, file.readToEndAlloc(allocator, stat.size) catch unreachable);
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    const file_data = try allocator.dupeZ(u8, buffer);
    defer allocator.free(file_data);

    std.debug.print("size:{any}\ndata:\n{s}\nXXX", .{ stat.size, raw });
    std.debug.print("size:{any}\ndata:\n{s}\nXXX", .{ stat.size, file_data });

    std.debug.print("file size: {}\n", .{stat.size});
    std.debug.print("buffer len: {}\n", .{buffer.len});
    std.debug.print("buffer: \"{s}\"\n", .{buffer});

    //var output_buffer = std.ArrayList(u8).init(allocator);
    //defer output_buffer.deinit();

    //const a = Asset{ .foo = "hello", .bar = false };
    //try ziggy.stringify(a, .{}, output_buffer.writer());
    //std.debug.print("out:{s}\n", .{ output_buffer.items});

    //var d: ziggy.Diagnostic = ziggy.Diagnostic{ .path = "ziggy" };

    const a = try ziggy.parseLeaky(Asset, allocator, file_data, .{});

    std.debug.print("data: {s}\n", .{a.foo});
}
