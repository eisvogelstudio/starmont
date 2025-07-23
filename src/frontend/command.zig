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

// unsure if this will be needed...
//could all be done via model/ecs
const FrontCommand = union(enum) {
    // Transient (einmalige Aktionen)
    //PlaySound: struct { id: SoundId },
    //ShowFloatingText: struct { entity: u32, text: []const u8, color: Color },
    //FlashScreen,
    //ShakeCamera,
    //AnimateEntity: struct { entity: u32, animation: AnimationId },
    //SpawnParticles: struct { position: Vec2, kind: ParticleKind },

    // Persistent (zustandsverändernd)
    //OpenUi: struct { panel: UiPanel },
    //CloseUi: struct { panel: UiPanel },
    //FocusCameraOn: struct { entity: u32 },
    //HighlightEntity: struct { entity: u32 },
    //SetVisibility: struct { entity: u32, visible: bool },

    // ...
};
