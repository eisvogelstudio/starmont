const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //const network = b.dependency("network", .{});
    //const zflecs = b.dependency("zflecs", .{});
    //const zphysics = b.dependency("zphysics", .{});

    // model lib module
    const model_mod = b.createModule(.{
        .root_source_file = b.path("src/model/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    //model_mod.addImport("network", network.module("network"));
    //model_mod.addImport("zflecs", zflecs.module("root"));
    //model_mod.addImport("zphysics", zphysics.module("root"));

    // util lib module
    const util_mod = b.createModule(.{
        .root_source_file = b.path("src/util/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // client module
    const client_mod = b.createModule(.{
        .root_source_file = b.path("src/client/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    client_mod.addImport("model", model_mod);
    client_mod.addImport("util", util_mod);

    // server module
    const server_mod = b.createModule(.{
        .root_source_file = b.path("src/server/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    server_mod.addImport("model", model_mod);
    server_mod.addImport("util", util_mod);

    // model lib
    const model_lib = b.addStaticLibrary(.{
        .name = "starmont_model",
        .root_module = model_mod,
    });
    //starmont_lib.linkLibrary(zflecs.artifact("flecs"));
    //starmont_lib.linkLibrary(zphysics.artifact("joltc"));

    b.installArtifact(model_lib);

    // util lib
    const util_lib = b.addStaticLibrary(.{
        .name = "starmont_util",
        .root_module = util_mod,
    });
    //starmont_lib.linkLibrary(zflecs.artifact("flecs"));
    //starmont_lib.linkLibrary(zphysics.artifact("joltc"));

    b.installArtifact(util_lib);

    // client
    const client_exe = b.addExecutable(.{
        .name = "starmont_client",
        .root_module = client_mod,
    });
    client_exe.linkLibrary(model_lib);
    client_exe.linkLibrary(util_lib);
    //client_exe.linkLibrary(zglfw.artifact("glfw"));

    b.installArtifact(client_exe);

    // server
    const server_exe = b.addExecutable(.{
        .name = "starmont_server",
        .root_module = server_mod,
    });
    server_exe.linkLibrary(model_lib);
    server_exe.linkLibrary(util_lib);

    b.installArtifact(server_exe);

    // ##### run steps #####

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

    // ##### testing #####

    const model_tests = b.addTest(.{ .root_module = model_mod });
    const util_tests = b.addTest(.{ .root_module = util_mod });
    const client_tests = b.addTest(.{ .root_module = client_mod });
    const server_tests = b.addTest(.{ .root_module = server_mod });

    const run_model_tests = b.addRunArtifact(model_tests);
    const run_util_tests = b.addRunArtifact(util_tests);
    const run_client_tests = b.addRunArtifact(client_tests);
    const run_server_tests = b.addRunArtifact(server_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_model_tests.step);
    test_step.dependOn(&run_util_tests.step);
    test_step.dependOn(&run_client_tests.step);
    test_step.dependOn(&run_server_tests.step);
}
