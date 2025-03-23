const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ########## dependencies ##########

    const network = b.dependency("network", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const zflecs = b.dependency("zflecs", .{
        .target = target,
        .optimize = optimize,
    });

    // ########## modules ##########

    // core lib module
    const core_mod = b.createModule(.{
        .root_source_file = b.path("src/core/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    core_mod.addImport("zflecs", zflecs.module("root"));
    //core_mod.addImport("zphysics", zphysics.module("root"));

    // util lib module
    const util_mod = b.createModule(.{
        .root_source_file = b.path("src/util/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    util_mod.addImport("core", core_mod);
    util_mod.addImport("network", network.module("network"));

    // client module
    const client_mod = b.createModule(.{
        .root_source_file = b.path("src/client/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    client_mod.addImport("core", core_mod);
    client_mod.addImport("util", util_mod);
    client_mod.addImport("raylib", raylib.module("raylib"));
    client_mod.addImport("raygui", raylib.module("raygui"));
    client_mod.addImport("zflecs", zflecs.module("root"));

    // server module
    const server_mod = b.createModule(.{
        .root_source_file = b.path("src/server/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    server_mod.addImport("core", core_mod);
    server_mod.addImport("util", util_mod);
    server_mod.addImport("zflecs", zflecs.module("root"));

    // ########## objects ##########

    // core lib
    const core_lib = b.addStaticLibrary(.{
        .name = "starmont_core",
        .root_module = core_mod,
    });
    core_lib.linkLibrary(zflecs.artifact("flecs"));
    //core_lib.linkLibrary(zphysics.artifact("joltc"));

    b.installArtifact(core_lib);

    // util lib
    const util_lib = b.addStaticLibrary(.{
        .name = "starmont_util",
        .root_module = util_mod,
    });

    b.installArtifact(util_lib);

    // client
    const client_exe = b.addExecutable(.{
        .name = "starmont_client",
        .root_module = client_mod,
    });
    client_exe.linkLibrary(core_lib);
    client_exe.linkLibrary(util_lib);
    client_exe.linkLibrary(raylib.artifact("raylib"));
    client_exe.linkLibrary(zflecs.artifact("flecs"));

    b.installArtifact(client_exe);

    // server
    const server_exe = b.addExecutable(.{
        .name = "starmont_server",
        .root_module = server_mod,
    });
    server_exe.linkLibrary(core_lib);
    server_exe.linkLibrary(util_lib);

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

    const core_tests = b.addTest(.{ .root_module = core_mod });
    const util_tests = b.addTest(.{ .root_module = util_mod });
    const client_tests = b.addTest(.{ .root_module = client_mod });
    const server_tests = b.addTest(.{ .root_module = server_mod });

    const run_core_tests = b.addRunArtifact(core_tests);
    const run_util_tests = b.addRunArtifact(util_tests);
    const run_client_tests = b.addRunArtifact(client_tests);
    const run_server_tests = b.addRunArtifact(server_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_core_tests.step);
    test_step.dependOn(&run_util_tests.step);
    test_step.dependOn(&run_client_tests.step);
    test_step.dependOn(&run_server_tests.step);
}
