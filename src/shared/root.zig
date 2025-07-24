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

// ╔══════════════════════════════ pack ══════════════════════════════╗
pub const core = @import("core/core.zig");
pub const editor = @import("editor/editor.zig");
pub const visual = @import("visual/visual.zig");
pub const PrefabData = @import("prefab.zig").PrefabData;
pub const Prefab = @import("prefab.zig").Prefab;
pub const PrefabManifest = @import("prefab.zig").PrefabManifest;
// ╚══════════════════════════════════════════════════════════════════╝

// ╔══════════════════════════════ test ══════════════════════════════╗
test {
    //TODO[TEST]
}
// ╚══════════════════════════════════════════════════════════════════╝
