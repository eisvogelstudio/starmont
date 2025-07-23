const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //TODO[REMOVE]
    //const hasRenderer = b.option(bool, "hasRenderer", "Enable CI-specific build configuration") orelse true;
    //
    //const build_options = b.addOptions();
    //build_options.addOption(bool, "hasRenderer", hasRenderer);

    // ########## dependencies ##########

    const network = b.dependency("network", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    const zchip2d = b.dependency("zchip2d", .{
        .target = target,
        .optimize = optimize,
    });

    const zflecs = b.dependency("zflecs", .{
        .target = target,
        .optimize = optimize,
    });

    const ziggy = b.dependency("ziggy", .{
        .target = target,
        .optimize = optimize,
    });

    // ########## modules ##########

    // util lib module
    const util_mod = b.createModule(.{
        .root_source_file = b.path("src/util/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    util_mod.addImport("ziggy", ziggy.module("ziggy"));

    // shared lib module
    const shared_mod = b.createModule(.{
        .root_source_file = b.path("src/shared/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    shared_mod.addImport("util", util_mod);
    shared_mod.addImport("zchip2d", zchip2d.module("zchip2d"));
    shared_mod.addImport("zflecs", zflecs.module("root"));

    // extra lib module
    const extra_mod = b.createModule(.{
        .root_source_file = b.path("src/extra/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    extra_mod.addImport("util", util_mod);
    extra_mod.addImport("shared", shared_mod);
    extra_mod.addImport("network", network.module("network"));

    // model lib module
    const model_mod = b.createModule(.{
        .root_source_file = b.path("src/model/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    model_mod.addImport("util", util_mod);
    model_mod.addImport("shared", shared_mod);
    model_mod.addImport("extra", extra_mod);
    model_mod.addImport("zchip2d", zchip2d.module("zchip2d"));
    model_mod.addImport("zflecs", zflecs.module("root"));

    // frontend lib module
    const frontend_mod = b.createModule(.{
        .root_source_file = b.path("src/frontend/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    frontend_mod.addImport("util", util_mod);
    frontend_mod.addImport("shared", shared_mod);
    frontend_mod.addImport("extra", extra_mod);
    frontend_mod.addImport("raylib", raylib.module("raylib"));
    frontend_mod.addImport("raygui", raylib.module("raygui"));
    //frontend_mod.addOptions("build_options", build_options); //TODO[REMOVE]

    // editor module
    const editor_mod = b.createModule(.{
        .root_source_file = b.path("src/editor/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    editor_mod.addImport("util", util_mod);
    editor_mod.addImport("shared", shared_mod);
    //editor_mod.addImport("extra", extra_mod); //TODO[REMOVE] maybe? or is it needed?
    editor_mod.addImport("frontend", frontend_mod);

    // client module
    const client_mod = b.createModule(.{
        .root_source_file = b.path("src/client/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    client_mod.addImport("util", util_mod);
    client_mod.addImport("shared", shared_mod);
    client_mod.addImport("extra", extra_mod);
    client_mod.addImport("model", model_mod);
    client_mod.addImport("frontend", frontend_mod);

    // server module
    const server_mod = b.createModule(.{
        .root_source_file = b.path("src/server/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    server_mod.addImport("util", util_mod);
    server_mod.addImport("shared", shared_mod);
    server_mod.addImport("extra", extra_mod);
    server_mod.addImport("model", model_mod);

    // master module
    const master_mod = b.createModule(.{
        .root_source_file = b.path("src/master/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    master_mod.addImport("util", util_mod);
    master_mod.addImport("shared", shared_mod);
    master_mod.addImport("extra", extra_mod);

    // ########## objects ##########

    // util lib
    const util_lib = b.addStaticLibrary(.{
        .name = "starmont_util",
        .root_module = util_mod,
    });

    b.installArtifact(util_lib);

    // shared lib
    const shared_lib = b.addStaticLibrary(.{
        .name = "starmont_shared",
        .root_module = shared_mod,
    });
    shared_lib.linkLibrary(util_lib);
    shared_lib.linkLibrary(zflecs.artifact("flecs"));
    shared_lib.linkLibrary(zchip2d.artifact("zchip2d"));

    b.installArtifact(shared_lib);

    // extra lib
    const extra_lib = b.addStaticLibrary(.{
        .name = "starmont_extra",
        .root_module = extra_mod,
    });
    extra_lib.linkLibrary(util_lib);
    extra_lib.linkLibrary(shared_lib);

    b.installArtifact(extra_lib);

    // model lib
    const model_lib = b.addStaticLibrary(.{
        .name = "starmont_model",
        .root_module = model_mod,
    });
    model_lib.linkLibrary(util_lib);
    model_lib.linkLibrary(shared_lib);
    model_lib.linkLibrary(zflecs.artifact("flecs"));
    model_lib.linkLibrary(zchip2d.artifact("zchip2d"));

    b.installArtifact(model_lib);

    // view lib
    const frontend_lib = b.addStaticLibrary(.{
        .name = "starmont_frontend",
        .root_module = frontend_mod,
    });
    frontend_lib.linkLibrary(util_lib);
    frontend_lib.linkLibrary(shared_lib);
    frontend_lib.linkLibrary(extra_lib);
    frontend_lib.linkLibrary(raylib.artifact("raylib"));

    b.installArtifact(frontend_lib);

    // editor
    const editor_exe = b.addExecutable(.{
        .name = "starmont_editor",
        .root_module = editor_mod,
    });
    editor_exe.linkLibrary(util_lib);
    editor_exe.linkLibrary(shared_lib);
    editor_exe.linkLibrary(frontend_lib);

    b.installArtifact(editor_exe);

    // client
    const client_exe = b.addExecutable(.{
        .name = "starmont_client",
        .root_module = client_mod,
    });
    client_exe.linkLibrary(util_lib);
    client_exe.linkLibrary(shared_lib);
    client_exe.linkLibrary(extra_lib);
    client_exe.linkLibrary(model_lib);
    client_exe.linkLibrary(frontend_lib);

    b.installArtifact(client_exe);

    // server
    const server_exe = b.addExecutable(.{
        .name = "starmont_server",
        .root_module = server_mod,
    });
    server_exe.linkLibrary(util_lib);
    server_exe.linkLibrary(shared_lib);
    server_exe.linkLibrary(extra_lib);
    server_exe.linkLibrary(model_lib);

    b.installArtifact(server_exe);

    // master
    const master_exe = b.addExecutable(.{
        .name = "starmont_master",
        .root_module = master_mod,
    });
    master_exe.linkLibrary(util_lib);
    master_exe.linkLibrary(shared_lib);
    master_exe.linkLibrary(extra_lib);

    b.installArtifact(master_exe);

    // ########## run steps ##########

    const run_editor = b.addRunArtifact(editor_exe);
    const run_client = b.addRunArtifact(client_exe);
    const run_server = b.addRunArtifact(server_exe);
    const run_master = b.addRunArtifact(master_exe);

    run_editor.step.dependOn(b.getInstallStep());
    run_client.step.dependOn(b.getInstallStep());
    run_server.step.dependOn(b.getInstallStep());
    run_master.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_editor.addArgs(args);
        run_client.addArgs(args);
        run_server.addArgs(args);
        run_master.addArgs(args);
    }

    const run_editor_step = b.step("run-editor", "Run the editor");
    run_editor_step.dependOn(&run_editor.step);

    const run_client_step = b.step("run-client", "Run the client");
    run_client_step.dependOn(&run_client.step);

    const run_server_step = b.step("run-server", "Run the server");
    run_server_step.dependOn(&run_server.step);

    const run_master_step = b.step("run-master", "Run the master");
    run_master_step.dependOn(&run_master.step);

    // ########## testing ##########

    const util_tests = b.addTest(.{ .root_module = util_mod });
    const shared_tests = b.addTest(.{ .root_module = shared_mod });
    const extra_tests = b.addTest(.{ .root_module = extra_mod });
    const model_tests = b.addTest(.{ .root_module = model_mod });
    const editor_tests = b.addTest(.{ .root_module = editor_mod });
    const client_tests = b.addTest(.{ .root_module = client_mod });
    const server_tests = b.addTest(.{ .root_module = server_mod });
    const master_tests = b.addTest(.{ .root_module = master_mod });

    const run_util_tests = b.addRunArtifact(util_tests);
    const run_shared_tests = b.addRunArtifact(shared_tests);
    const run_extra_tests = b.addRunArtifact(extra_tests);
    const run_model_tests = b.addRunArtifact(model_tests);
    const run_editor_tests = b.addRunArtifact(editor_tests);
    const run_client_tests = b.addRunArtifact(client_tests);
    const run_server_tests = b.addRunArtifact(server_tests);
    const run_master_tests = b.addRunArtifact(master_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_util_tests.step);
    test_step.dependOn(&run_shared_tests.step);
    test_step.dependOn(&run_extra_tests.step);
    test_step.dependOn(&run_model_tests.step);
    test_step.dependOn(&run_editor_tests.step);
    test_step.dependOn(&run_client_tests.step);
    test_step.dependOn(&run_server_tests.step);
    test_step.dependOn(&run_master_tests.step);
}
