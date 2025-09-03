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

// ---------- external ----------
const net = @import("network");
// ------------------------------

// ---------- zig ----------
const std = @import("std");
// -------------------------

// ---------- starmont ----------
const util = @import("util");
// ------------------------------

// ---------- local ----------
const Message = @import("message.zig").Message;
const Package = @import("package.zig").Package;
// ---------------------------

const ReliableReceiver = struct {
    gpa: *std.mem.Allocator,
    //messages: std.ArrayList(Message),

    next_expected: u16 = 0,
    ack_head: u16 = 0,
    ack_bits: u32 = 0,
    reorder: std.AutoArrayHashMap(u16, Package),

    pub fn init(gpa: *std.mem.Allocator) ReliableReceiver {
        return ReliableReceiver{
            .gpa = gpa,
            .reorder = std.AutoArrayHashMap(u16, Package).init(gpa),
        };
    }

    pub fn append(self: ReliableReceiver, package: Package, delay_ns: u64) void {}

    fn update(self: ReliableReceiver) void {
        _ = self;
    }

    pub fn pop(self: ReliableReceiver) !void {
        self.update();

        if (self.reorder.contains(self.next_expected)) {
            self.next_expected += 1;
        } else {
            return error.WouldBlock;
        }
    }
};
