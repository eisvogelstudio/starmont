const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ########## dependencies ##########

    const network = b.dependency("network", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });
    const zflecs = b.dependency("zflecs", .{
        .target = target,
        .optimize = optimize,
    });

    // ########## modules ##########

    // shared lib module
    const shared_mod = b.createModule(.{
        .root_source_file = b.path("src/shared/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    shared_mod.addImport("zflecs", zflecs.module("root"));
    shared_mod.addImport("network", network.module("network"));
    //core_mod.addImport("zphysics", zphysics.module("root"));

    // client module
    const client_mod = b.createModule(.{
        .root_source_file = b.path("src/client/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    client_mod.addImport("shared", shared_mod);
    client_mod.addImport("raylib", raylib.module("raylib"));
    client_mod.addImport("raygui", raylib.module("raygui"));
    client_mod.addImport("zflecs", zflecs.module("root"));

    // server module
    const server_mod = b.createModule(.{
        .root_source_file = b.path("src/server/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    server_mod.addImport("shared", shared_mod);
    server_mod.addImport("util", shared_mod);
    server_mod.addImport("zflecs", zflecs.module("root"));

    // ########## objects ##########

    // shared lib
    const shared_lib = b.addStaticLibrary(.{
        .name = "starmont_shared",
        .root_module = shared_mod,
    });
    shared_lib.linkLibrary(zflecs.artifact("flecs"));
    //core_lib.linkLibrary(zphysics.artifact("joltc"));

    b.installArtifact(shared_lib);

    // client
    const client_exe = b.addExecutable(.{
        .name = "starmont_client",
        .root_module = client_mod,
    });
    client_exe.linkLibrary(shared_lib);
    client_exe.linkLibrary(raylib.artifact("raylib"));
    client_exe.linkLibrary(zflecs.artifact("flecs"));

    b.installArtifact(client_exe);

    // server
    const server_exe = b.addExecutable(.{
        .name = "starmont_server",
        .root_module = server_mod,
    });
    server_exe.linkLibrary(shared_lib);

    b.installArtifact(server_exe);

    // ########## run steps ##########

    const run_client = b.addRunArtifact(client_exe);
    const run_server = b.addRunArtifact(server_exe);

    run_client.step.dependOn(b.getInstallStep());
    run_server.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_client.addArgs(args);
        run_server.addArgs(args);
    }

    const run_client_step = b.step("run-client", "Run the client");
    run_client_step.dependOn(&run_client.step);

    const run_server_step = b.step("run-server", "Run the server");
    run_server_step.dependOn(&run_server.step);

    // ########## testing ##########

    const shared_tests = b.addTest(.{ .root_module = shared_mod });
    const client_tests = b.addTest(.{ .root_module = client_mod });
    const server_tests = b.addTest(.{ .root_module = server_mod });

    const run_shared_tests = b.addRunArtifact(shared_tests);
    const run_client_tests = b.addRunArtifact(client_tests);
    const run_server_tests = b.addRunArtifact(server_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_shared_tests.step);
    test_step.dependOn(&run_client_tests.step);
    test_step.dependOn(&run_server_tests.step);
}
