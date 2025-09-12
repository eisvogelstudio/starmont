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
const PackageError = @import("package.zig").PackageError;
const Identifier = @import("package.zig").Identifier;
const TimedIdentifier = @import("package.zig").TimedIdentifier;
const TimedPackage = @import("package.zig").TimedPackage;
const Header = @import("package.zig").Header;
const Channel = @import("message.zig").Channel;
const Ack = @import("package.zig").Ack;
// ---------------------------

const Buffer = std.AutoHashMap(Identifier, Package);

const CHANNEL_COUNT = @typeInfo(Channel).@"enum".fields.len;

const mtu = Package.max_byte;

pub const PriorityScheme = struct {
    pub const Order = enum { send, receive };

    pub fn classses(order: Order) [6][]const Channel {
        var REL_HIGH = [_]Channel{};
        var REL_MID = [_]Channel{};
        var REL_LOW = [_]Channel{};
        var UNR_HIGH = [_]Channel{};
        var UNR_MID = [_]Channel{};
        var UNR_LOW = [_]Channel{};

        for (0..CHANNEL_COUNT) |i| {
            const channel: Channel = @enumFromInt(i);
            switch (channel.class()) {
                .reliable => {
                    switch (channel.priority()) {
                        .high => REL_HIGH = REL_HIGH ++ [_]Channel{channel},
                        .mid => REL_MID = REL_MID ++ [_]Channel{channel},
                        .low => REL_LOW = REL_LOW ++ [_]Channel{channel},
                    }
                },
                .unreliable => {
                    switch (channel.priority()) {
                        .high => UNR_HIGH = UNR_HIGH ++ [_]Channel{channel},
                        .mid => UNR_MID = UNR_MID ++ [_]Channel{channel},
                        .low => UNR_LOW = UNR_LOW ++ [_]Channel{channel},
                    }
                },
            }
        }

        return switch (order) {
            .send => .{ &UNR_HIGH, &UNR_MID, &UNR_LOW, &REL_HIGH, &REL_MID, &REL_LOW },
            .receive => .{ &REL_HIGH, &REL_MID, &REL_LOW, &UNR_HIGH, &UNR_MID, &UNR_LOW },
        };
    }
};

pub const Inbox = struct {
    channel: Channel,
    available: std.AutoHashMap(u16, void),
    next_expected: u16 = 0,
    ack_head: u16 = 0,
    ack_bits: u32 = 0,

    pub fn init(gpa: std.mem.Allocator, channel: Channel) Inbox {
        return Inbox{
            .channel = channel,
            .available = std.AutoHashMap(Identifier, void).init(gpa),
        };
    }

    pub fn append(self: *Inbox, ident: Identifier) void {
        self.markReceived(ident.sequence);
        self.available.put(ident.sequence, {});
    }

    pub fn pop(self: *Inbox) ?Identifier {
        if (self.available.remove(self.next_expected)) {
            const ident = Identifier{ .channel = self.channel, .sequence = self.next_expected };
            self.next_expected += 1;

            return ident;
        }

        return null;
    }

    fn markReceived(self: *Inbox, seq: u16) void {
        if (util.seqGreater(u16, seq, self.ack_head)) {
            const shift = seq - self.ack_head;
            if (shift >= 32) {
                self.ack_bits = 1;
            } else {
                self.ack_bits = (self.ack_bits << shift) | 1;
            }
            self.ack_head = seq;
        } else {
            const diff = self.ack_head - seq;
            if (diff < 32) {
                self.ack_bits |= (1 << diff);
            }
        }
    }
};

pub const OutboxError = error{ MessageTooBig, NoChannelSlot };

pub const Outbox = struct {
    channel: Channel,
    buffer: *Buffer,
    old: std.AutoHashMap(Identifier, void),
    unfinished: Identifier,
    head: Identifier,

    pub fn init(gpa: std.mem.Allocator, channel: Channel, buffer: *Buffer) Outbox {
        var outbox = Outbox{
            .channel = channel,
            .buffer = buffer,
            .old = std.AutoHashMap(Identifier, void).init(gpa),
        };

        const ident = Identifier{ .channel = channel, .sequence = 0 };
        buffer.put(ident, Package{});
        outbox.unfinished = ident;
        outbox.head = ident;
    }

    pub fn deinit(self: *Outbox) void {
        self.old.deinit();
    }

    pub fn append(self: *Outbox, msg: Message) void {
        const package = self.buffer.*.get(self.unfinished).?;

        package.append(msg) catch |err| {
            switch (err) {
                PackageError.OutOfSpace => {
                    self.finishPackage();
                    self.append(msg) catch unreachable;
                },
                else => unreachable,
            }
        };
    }

    pub fn hasPackage(self: Outbox) bool {
        if (self.unfinished == self.head) {
            return false;
        } else {
            return true;
        }
    }

    pub fn peekPackageSize(self: Outbox) ?usize {
        if (!self.hasPackage()) {
            return null;
        }

        return self.buffer.get(self.head).?.wireSize();
    }

    pub fn pop(self: *Outbox) ?Identifier {
        if (self.unfinished == self.head) {
            return null;
        }

        const head = self.head;
        self.head = head.successor();

        self.old.put(head, {});

        return head;
    }

    fn finishPackage(self: *Outbox) void {
        const package = self.buffer.*.get(self.unfinished).?;

        if (package.msg_count == 0) {
            return;
        }

        const finished = self.unfinished;
        self.unfinished = finished.successor();
        self.buffer.put(self.unfinished, Package{});
    }
};

pub const Link = struct {
    gpa: std.mem.Allocator,
    socket: net.Socket,

    out_buffer: Buffer,
    in_buffer: Buffer,
    outwait: util.RingBuffer(TimedIdentifier),
    inwait: util.RingBuffer(TimedIdentifier),

    outbox: [CHANNEL_COUNT]Outbox,
    inbox: [CHANNEL_COUNT]Inbox,

    out_pacer: OutPacer,
    out_scheduler: OutScheduler = OutScheduler.init(),
    in_pacer: InPacer,
    in_scheduler: OutScheduler,

    const io_delay_us = 0;
    const receive_max = 1024;
    const process_max = 1024;

    fn create_udp(port: u16) net.Socket {
        var socket: net.Socket = net.Socket.create(.ipv4, .udp) catch unreachable;
        socket.enablePortReuse(true) catch unreachable;
        socket.bindToPort(port) catch unreachable;
        socket.setReadTimeout(100) catch unreachable;
        socket.setWriteTimeout(100) catch unreachable;

        return socket;
    }

    pub fn init(gpa: std.mem.Allocator) Link {
        const link = Link{
            .gpa = gpa,
            .socket = create_udp(),
            .out_buffer = Buffer.init(gpa),
            .in_buffer = Buffer.init(gpa),
            .outwait = util.RingBuffer(TimedIdentifier).init(gpa, 2),
            .inwait = util.RingBuffer(TimedIdentifier).init(gpa, 2),
            .out_pacer = OutPacer.init(20 * mtu, 2 * mtu, 20, 2),
            .in_pacer = InPacer.init(4, 4 * mtu),
        };

        for (0..CHANNEL_COUNT) |i| {
            const channel: Channel = @enumFromInt(i);
            link.outbox[i].init(gpa, channel, &link.out_buffer);
            link.inbox[i].init(gpa, gpa, channel, &link.in_buffer, &link.inwait);
        }

        return link;
    }

    pub fn deinit(self: *Link) void {
        defer self.out_buffer.deinit();
        defer self.in_buffer.deinit();
        defer self.outwait.deinit();
        defer self.inwait.deinit();

        for (0..CHANNEL_COUNT) |i| {
            defer self.outbox[i].deinit();
            defer self.inbox[i].deinit();
        }
    }

    pub fn update(self: *Link) void {
        const now_us = std.time.microTimestamp();

        // in receive
        var rcount: i32 = 0;
        while (self.receive(now_us) catch unreachable) {
            rcount += 1;
            if (rcount == receive_max) break;

            const found2 = true;
            while (found2) {
                if (self.inwait.peekFront().?.until_us >= now_us) {
                    const ident = self.inwait.popFront().?.ident;
                    const idx = @intFromEnum(ident.channel);
                    self.inbox[idx].append(ident);
                } else {
                    found2 = false;
                }
            }
        }

        // in - process
        self.in_drain();

        // out - process
        self.out_burst(now_us);

        const found = true;
        while (found) {
            if (self.outwait.peekFront().?.until_us >= now_us) {
                const ident = self.outwait.popFront().?.ident;
                self.send(ident);
            } else {
                found = false;
            }
        }
    }

    fn queue(self: *Link, ident: Identifier, now_us: i64) bool {
        if (io_delay_us == 0) {
            self.send(ident);
        } else {
            const timed = TimedIdentifier{ .until_us = now_us + io_delay_us, .ident = ident };
            self.outwait.pushBack(timed);
        }
    }

    fn out_burst(self: *Link, now_us: u64) void {
        self.out_scheduler.start_burst(); // refill deficit credits for this burst

        var progress = true;
        while (progress) {
            progress = false;

            const classes = self.scheduler.priority_classes();
            for (classes) |class_indices| {
                for (class_indices) |ch_idx| {
                    var outbox = &self.outbox[ch_idx];

                    outbox.finishPackage();

                    if (!outbox.hasPackage()) continue; // nothing to send on this channel

                    const need = outbox.peekPackageSize();

                    if (!self.out_scheduler.can_send(ch_idx, need)) continue;
                    if (!self.out_pacer.is_allowed(now_us, need, 1)) continue;

                    if (outbox.pop()) |ident| {
                        self.queue(ident, now_us);

                        self.scheduler.on_sent(ch_idx, need); // account for scheduler
                        self.out_pacer.consume(need, 1); // account for pacer
                        progress = true;
                    }
                }
            }

            if (!progress) break; // stop if no packet was sent in this iteration
        }
    }

    fn in_drain(self: *Link) void {
        self.in_pacer.start_tick();
        self.in_scheduler.start_tick();

        while (true) {
            var progress = false;

            const classes = self.in_scheduler.priority_classes(.ascending);
            for (classes) |class_indices| {
                for (class_indices) |ch_idx| {
                    var rx = &self.rx_queues[ch_idx];

                    while (true) {
                        const need_opt = rx.peek_size(); // ?usize
                        const need = if (need_opt) |n| n else break;

                        if (!self.in_scheduler.can_take(ch_idx, need)) break;
                        if (!self.in_pacer.allow(need)) break;

                        const frame = rx.pop() orelse break;
                        self.inbox[ch_idx].append(frame); // reliable macht intern next_expected

                        self.in_scheduler.on_taken(ch_idx, need);
                        self.in_pacer.consume(need);
                        progress = true;
                    }
                }
            }
            if (!progress) break; // nichts mehr sinnvoll zu verarbeiten
        }
    }

    pub fn submit(self: *Link, channel: Channel, message: Message) void {
        const idx = @intFromEnum(channel);
        self.outbox[idx].append(message) catch unreachable;
    }

    //pub fn withdraw(self: *Link) ?Package {
    //    const classes = PriorityScheme.classes(.ascending); // reliable first
    //    for (classes) |class_indices| {
    //        for (class_indices) |ch_idx| {
    //            var inbox = &self.inbox[ch_idx];
    //            if (inbox.pop()) |package| {
    //                return package;
    //            }
    //        }
    //    }
    //    return null;
    //}

    pub fn withdraw(self: *Link) ?Message {
        // Priorität: reliable → unreliable
        const classes = self.in_scheduler.priority_classes(.ascending);

        // Ein Sweep über alle Klassen/Channels
        inline for (classes) |class_indices| {
            for (class_indices) |ch_idx| {
                var ib = &self.inbox[ch_idx];

                if (!ib.has_ready()) continue;

                const need = ib.peek_ready_size();
                if (!self.in_scheduler.can_take(ch_idx, need)) continue; // DRR/Quota
                if (!self.in_pacer.allow(need)) continue; // Tick-Budget

                if (ib.pop()) |msg| {
                    self.in_scheduler.on_taken(ch_idx, need);
                    self.in_pacer.consume(need);
                    return msg;
                }
            }
        }
        return null;
    }

    fn send(self: *Link, ident: Identifier) void {
        const package = self.out_buffer.get(ident).?;
        package.send(self.socket);

        // package is kept in case resend is necessary
    }

    fn receive(self: *Link, now_us: i64) !bool {
        const package = Package.receive(&self.socket) catch |err| {
            switch (err) {
                error.WouldBlock => return false,
                else => unreachable,
            }
        };

        const header = try package.deserializeHeader();

        const ident = Identifier{ .channel = header.channel, .sequence = header.sequence };

        try self.in_buffer.put(ident, package);

        if (io_delay_us == 0) {
            self.dispatch(ident, now_us);
        } else {
            const timed = TimedIdentifier{ .until_us = now_us + io_delay_us, .ident = ident };
            self.inwait.pushBack(timed);
        }

        return true;
    }
};
// ---- Out (egress) Pacer --------------------------------------------c
pub const OutPacer = struct {
    bytes_per_sec: usize,
    pkts_per_sec: u32,
    max_burst_bytes: usize,
    max_burst_pkts: u32,

    byte_tokens: usize = 0,
    pkt_tokens: u32 = 0,
    last_refill_ns: i128 = 0,

    pub fn init(bytes_per_sec: usize, max_burst_bytes: usize, pkts_per_sec: u32, max_burst_pkts: u32) OutPacer {
        const now = std.time.nanoTimestamp();
        return .{
            .bytes_per_sec = bytes_per_sec,
            .pkts_per_sec = pkts_per_sec,
            .max_burst_bytes = max_burst_bytes,
            .max_burst_pkts = max_burst_pkts,
            .byte_tokens = max_burst_bytes,
            .pkt_tokens = max_burst_pkts,
            .last_refill_ns = now,
        };
    }

    fn refill(self: *OutPacer, now_ns: i128) void {
        const dt = now_ns - self.last_refill_ns;
        if (dt <= 0) return;
        self.last_refill_ns = now_ns;

        const dt_ns: u128 = @intCast(dt);
        if (self.bytes_per_sec != 0) {
            const add_b: f32 = (self.bytes_per_sec * dt_ns) / std.time.ns_per_s;
            const add: usize = @intCast(@min(add_b, std.math.maxInt(usize)));
            self.byte_tokens = @min(self.byte_tokens + add, self.max_burst_bytes);
        }
        if (self.pkts_per_sec != 0) {
            const add_p: f32 = (self.pkts_per_sec * dt_ns) / std.time.ns_per_s;
            const add: usize = @intCast(@min(add_p, std.math.maxInt(u32)));
            const sum = self.pkt_tokens + add;
            self.pkt_tokens = if (sum > self.max_burst_pkts) self.max_burst_pkts else sum;
        }
    }

    pub fn is_allowed(self: *OutPacer, now_ns: i128, need_bytes: usize, need_pkts: u32) bool {
        self.refill(now_ns);
        return self.byte_tokens >= need_bytes and self.pkt_tokens >= need_pkts;
    }

    pub fn consume(self: *OutPacer, bytes: usize, pkts: u32) void {
        self.byte_tokens = if (bytes >= self.byte_tokens) 0 else self.byte_tokens - bytes;
        self.pkt_tokens = if (pkts >= self.pkt_tokens) 0 else self.pkt_tokens - pkts;
    }
};

// ---- Out (egress) Scheduler (DRR + Limits) -------------------------

pub const OutScheduler = struct {
    deficit: [CHANNEL_COUNT]usize = .{0} ** CHANNEL_COUNT,
    quantum: [CHANNEL_COUNT]usize = .{0} ** CHANNEL_COUNT,
    max_pkts_per_burst_ch: [CHANNEL_COUNT]u32 = .{std.math.maxInt(u32)} ** CHANNEL_COUNT,
    sent_this_burst: [CHANNEL_COUNT]u32 = .{0} ** CHANNEL_COUNT,

    pub fn init() OutScheduler {
        var s = OutScheduler{};

        for (0..CHANNEL_COUNT) |i| {
            const ch: Channel = @enumFromInt(i);

            // Basis: immer mindestens 1×MTU als Quantum
            var q = mtu;
            var max_pkts: u32 = 1;

            // Unreliable bekommt generell mehr Budget
            if (ch.class() == .unreliable) {
                q = 2 * mtu;
                max_pkts = 2;
            }

            // Feintuning nach Priority
            switch (ch.priority()) {
                .high => {}, // bleibt
                .mid => {
                    // Mid etwas schwächer gewichten
                    q = q / 2;
                },
                .low => {
                    // Low ganz klein halten
                    q = q / 4;
                    max_pkts = 1;
                },
            }

            s.quantum[i] = q;
            s.max_pkts_per_burst_ch[i] = max_pkts;
        }

        return s;
    }

    pub fn start_burst(self: *OutScheduler) void {
        self.sent_this_burst = .{0} ** CHANNEL_COUNT;
        inline for (@typeInfo(Channel).Enum.fields) |f| {
            const i = f.value;
            self.deficit[i] += self.quantum[i];
        }
    }

    pub fn can_send(self: *OutScheduler, ch_idx: usize, size: usize) bool {
        if (self.sent_this_burst[ch_idx] >= self.max_pkts_per_burst_ch[ch_idx]) return false;
        return self.deficit[ch_idx] >= size;
    }

    pub fn on_sent(self: *OutScheduler, ch_idx: usize, size: usize) void {
        self.deficit[ch_idx] -= size;
        self.sent_this_burst[ch_idx] += 1;
    }

    pub fn priority_classes(_: *OutScheduler, order: PriorityScheme.Order) PriorityScheme.ClassesType {
        return PriorityScheme.classes(order);
    }
};

// ---- In (ingress) Pacer (per Tick Budget) --------------------------
pub const InPacer = struct {
    max_pkts_per_tick: u32,
    max_bytes_per_tick: usize,

    pkts_left: u32 = 0,
    bytes_left: usize = 0,

    pub fn init(max_pkts_per_tick: u32, max_bytes_per_tick: usize) InPacer {
        return .{
            .max_pkts_per_tick = max_pkts_per_tick,
            .max_bytes_per_tick = max_bytes_per_tick,
        };
    }

    pub fn start_tick(self: *InPacer) void {
        self.pkts_left = self.max_pkts_per_tick;
        self.bytes_left = self.max_bytes_per_tick;
    }

    pub fn allow(self: *InPacer, need_bytes: usize) bool {
        return self.pkts_left > 0 and self.bytes_left >= need_bytes;
    }

    pub fn consume(self: *InPacer, used_bytes: usize) void {
        self.bytes_left -= used_bytes;
        self.pkts_left -= 1;
    }
};

// ---- In (ingress) Scheduler (DRR + Limits) -------------------------
// ---- In (ingress) Scheduler (DRR + Limits) -------------------------
pub const InScheduler = struct {
    deficit: [CHANNEL_COUNT]usize = .{0} ** CHANNEL_COUNT,
    quantum: [CHANNEL_COUNT]usize = .{0} ** CHANNEL_COUNT,
    max_pkts_per_tick_ch: [CHANNEL_COUNT]u32 = .{std.math.maxInt(u32)} ** CHANNEL_COUNT,
    taken_this_tick: [CHANNEL_COUNT]u32 = .{0} ** CHANNEL_COUNT,

    pub fn init() InScheduler {
        var s = InScheduler{};

        inline for (@typeInfo(Channel).Enum.fields) |f| {
            const ch: Channel = @enumFromInt(f.value);
            const idx = f.value;

            // Basiswerte
            var q = mtu;
            var max_pkts: u32 = 1;

            // Unreliable bekommt tendenziell mehr Budget
            if (ch.class() == .unreliable) {
                q = 2 * mtu;
                max_pkts = 2;
            }

            // Feintuning nach Priority
            switch (ch.priority()) {
                .high => {}, // bleibt unverändert
                .mid => {
                    q = q / 2;
                },
                .low => {
                    q = q / 4;
                    max_pkts = 1;
                },
            }

            s.quantum[idx] = q;
            s.max_pkts_per_tick_ch[idx] = max_pkts;
        }

        return s;
    }

    pub fn start_tick(self: *InScheduler) void {
        self.taken_this_tick = .{0} ** CHANNEL_COUNT;
        inline for (@typeInfo(Channel).Enum.fields) |f| {
            const i = f.value;
            self.deficit[i] += self.quantum[i];
        }
    }

    pub fn can_take(self: *InScheduler, ch_idx: usize, size: usize) bool {
        if (self.taken_this_tick[ch_idx] >= self.max_pkts_per_tick_ch[ch_idx]) return false;
        return self.deficit[ch_idx] >= size;
    }

    pub fn on_taken(self: *InScheduler, ch_idx: usize, size: usize) void {
        self.deficit[ch_idx] -= size;
        self.taken_this_tick[ch_idx] += 1;
    }

    pub fn priority_classes(_: *InScheduler, order: PriorityScheme.Order) PriorityScheme.ClassesType {
        return PriorityScheme.classes(order);
    }
};
