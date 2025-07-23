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

// ---------- zig ----------
const std = @import("std");
// -------------------------

pub const UUID4 = struct {
    bytes: [16]u8,

    pub fn generate(random: std.Random) UUID4 {
        var buf: [16]u8 = undefined;
        std.Random.bytes(random, &buf);

        buf[6] = (buf[6] & 0x0F) | 0x40;
        buf[8] = (buf[8] & 0x3F) | 0x80;

        return UUID4{ .bytes = buf };
    }

    pub fn toString(self: UUID4) [36]u8 {
        const hex = std.fmt.bytesToHex(self.bytes, .lower);
        return [_]u8{
            hex[0],  hex[1],  hex[2],  hex[3],  hex[4],  hex[5],  hex[6],  hex[7],  '-',
            hex[8],  hex[9],  hex[10], hex[11], '-',     hex[12], hex[13], hex[14], hex[15],
            '-',     hex[16], hex[17], hex[18], hex[19], '-',     hex[20], hex[21], hex[22],
            hex[23], hex[24], hex[25], hex[26], hex[27], hex[28], hex[29], hex[30], hex[31],
        };
    }

    pub fn equals(a: UUID4, b: UUID4) bool {
        return std.mem.eql(u8, &a.bytes, &b.bytes);
    }
};
