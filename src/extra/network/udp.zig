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

const log = std.log.scoped(.network);

const Buffer = std.AutoHashMap(Identifier, Package);

const CHANNEL_COUNT = @typeInfo(Channel).@"enum".fields.len;

const mtu = Package.max_byte;

pub const PriorityScheme = struct {
    pub const ClassesType = [6][]const Channel;
    pub const Order = enum { send, receive };

    fn build(comptime class: Channel.Class, comptime priority: Channel.Priority) [CHANNEL_COUNT]Channel {
        comptime {
            var buf: [CHANNEL_COUNT]Channel = undefined;
            var len: usize = 0;

            for (std.meta.fields(Channel)) |field| {
                const c = @field(Channel, field.name);
                if (c.class() == class and c.priority() == priority) {
                    buf[len] = c;
                    len += 1;
                }
            }

            return buf;
        }
    }

    pub fn classes(order: Order) ClassesType {
        const REL_HIGH = comptime build(.reliable, .high);
        const REL_MID = comptime build(.reliable, .mid);
        const REL_LOW = comptime build(.reliable, .low);
        const UNR_HIGH = comptime build(.unreliable, .high);
        const UNR_MID = comptime build(.unreliable, .mid);
        const UNR_LOW = comptime build(.unreliable, .low);

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
            .available = std.AutoHashMap(u16, void).init(gpa),
        };
    }

    pub fn append(self: *Inbox, ident: Identifier) void {
        self.markReceived(ident.sequence);
        self.available.put(ident.sequence, {}) catch unreachable;
    }

    pub fn pop(self: *Inbox) ?Identifier {
        if (self.available.remove(self.next_expected)) {
            const ident = Identifier{ .channel = self.channel, .sequence = self.next_expected };
            self.next_expected += 1;

            return ident;
        }

        return null;
    }

    pub fn peek(self: *Inbox) ?Identifier {
        if (self.available.contains(self.next_expected)) {
            const ident = Identifier{ .channel = self.channel, .sequence = self.next_expected };
            return ident;
        }

        return null;
    }

    fn markReceived(self: *Inbox, seq: u16) void {
        // wenn seq neuer ist als ack_head → Fenster verschieben
        if (util.seqGreater(u16, seq, self.ack_head)) {
            const shift: u16 = seq - self.ack_head; // Abstand nach vorne
            if (shift >= 32) {
                // alles Alte fliegt raus, nur aktuelles gesetzt
                self.ack_bits = 1;
            } else {
                // shift Bits nach links, setze Bit0 für seq
                self.ack_bits = (self.ack_bits << @intCast(shift)) | 1;
            }
            self.ack_head = seq;
        } else {
            // Nachzügler, prüfe Abstand nach hinten
            const diff: u16 = self.ack_head - seq;
            if (diff < 32) {
                self.ack_bits |= (@as(u32, 1) << @intCast(diff));
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
        const ident = Identifier{ .channel = channel, .sequence = 0 };

        const outbox = Outbox{
            .channel = channel,
            .buffer = buffer,
            .old = std.AutoHashMap(Identifier, void).init(gpa),
            .unfinished = ident,
            .head = ident,
        };

        buffer.put(ident, Package{}) catch unreachable;

        return outbox;
    }

    pub fn deinit(self: *Outbox) void {
        self.old.deinit();
    }

    pub fn append(self: *Outbox, msg: Message) void {
        var package: *Package = self.buffer.getPtr(self.unfinished).?;
        package.append(msg) catch |err| {
            switch (err) {
                PackageError.OutOfSpace => {
                    self.finishPackage();
                    self.append(msg);
                },
                else => unreachable,
            }
        };
    }

    pub fn hasPackage(self: Outbox) bool {
        if (self.unfinished.equals(self.head)) {
            return false;
        } else {
            return true;
        }
    }

    pub fn peekPackageSize(self: Outbox) ?usize {
        if (!self.hasPackage()) {
            return null;
        }

        return self.buffer.getPtr(self.head).?.wireSize();
    }

    pub fn pop(self: *Outbox) ?Identifier {
        if (self.unfinished.equals(self.head)) {
            return null;
        }

        const current = self.head;
        self.head = current.successor();

        self.old.put(current, {}) catch unreachable;

        return current;
    }

    fn finishPackage(self: *Outbox) void {
        const package = self.buffer.getPtr(self.unfinished).?;

        if (package.msg_count == 0) {
            return;
        }

        const finished = self.unfinished;
        self.unfinished = finished.successor();
        self.buffer.put(self.unfinished, Package{}) catch unreachable;
    }
};

const Debug = struct {
    last_us: i64 = 0,
    tx_pkts: usize = 0,
    rx_pkts: usize = 0,
    tx_bytes: usize = 0,
    rx_bytes: usize = 0,
    lost_pkts: usize = 0,
    dup_pkts: usize = 0,
    recv_invalid: usize = 0,
};

pub fn create_socket(port: u16) net.Socket {
    var socket: net.Socket = net.Socket.create(.ipv4, .udp) catch unreachable;
    socket.enablePortReuse(true) catch unreachable;
    socket.bindToPort(port) catch unreachable;
    socket.setReadTimeout(100) catch unreachable;
    socket.setWriteTimeout(100) catch unreachable;

    return socket;
}

pub const Link = struct {
    gpa: *std.mem.Allocator,

    out_buffer: Buffer,
    in_buffer: Buffer,
    outwait: util.RingBuffer(TimedIdentifier),
    inwait: util.RingBuffer(TimedIdentifier),

    outbox: [CHANNEL_COUNT]Outbox = undefined,
    inbox: [CHANNEL_COUNT]Inbox = undefined,

    out_pacer: OutPacer,
    out_scheduler: OutScheduler = OutScheduler.init(),
    in_pacer: InPacer,
    in_scheduler: InScheduler = InScheduler.init(),

    unfinished: ?Identifier = null,

    debug: Debug = Debug{},

    const io_delay_us = 0;
    const receive_max = 1024;
    const process_max = 1024;

    pub fn init(gpa: *std.mem.Allocator) *Link {
        var link = gpa.create(Link) catch unreachable;
        link.* = Link{
            .gpa = gpa,
            .out_buffer = Buffer.init(gpa.*),
            .in_buffer = Buffer.init(gpa.*),
            .outwait = util.RingBuffer(TimedIdentifier).init(gpa.*, 4) catch unreachable,
            .inwait = util.RingBuffer(TimedIdentifier).init(gpa.*, 4) catch unreachable,
            .out_pacer = OutPacer.init(20 * mtu, 2 * mtu, 20, 2),
            .in_pacer = InPacer.init(4, 4 * mtu),
        };

        for (0..CHANNEL_COUNT) |i| {
            const channel: Channel = @enumFromInt(i);
            link.outbox[i] = Outbox.init(gpa.*, channel, &link.out_buffer);
            link.inbox[i] = Inbox.init(gpa.*, channel);
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

        self.gpa.free(self);
    }

    pub fn update(self: *Link) void {
        const now_us = std.time.microTimestamp();

        if (now_us - self.debug.last_us >= 200000) {
            self.debug.last_us = now_us;

            log.debug(
                "udp_stats: tx={d}pkts({d}B) rx={d}pkts({d}B) lost={d} dup={d}",
                .{ self.debug.tx_pkts, self.debug.tx_bytes, self.debug.rx_pkts, self.debug.rx_bytes, self.debug.lost_pkts, self.debug.dup_pkts },
            );

            for (0..CHANNEL_COUNT) |i| {
                const ch: Channel = @enumFromInt(i);
                log.debug("\tch={any}\tack_head={d}\tbits=0b{b:0>32}", .{ ch, self.inbox[i].ack_head, self.inbox[i].ack_bits });
            }
        }

        // in receive
        //var rcount: i32 = 0;
        //while (self.receive() catch unreachable) {
        //    rcount += 1;
        //    if (rcount == receive_max) break;
        //}

        // in - process (inbox -> schedule -> inwait)
        self.in_drain(now_us);

        // out - process (outbox -> schedule -> outwait)
        self.out_burst(now_us);
    }

    fn out_burst(self: *Link, now_us: i64) void {
        self.out_scheduler.start_burst(); // refill deficit credits for this burst

        while (true) {
            var progress = false;

            const classes = PriorityScheme.classes(.send);
            for (classes) |class_indices| {
                for (class_indices) |channel| {
                    const ch_idx = @intFromEnum(channel);

                    var outbox = &self.outbox[ch_idx];
                    outbox.finishPackage();
                    if (!outbox.hasPackage()) continue; // nothing to send on this channel;

                    const need = outbox.peekPackageSize().?;
                    _ = need;

                    //if (!self.out_scheduler.can_send(ch_idx, need)) continue;
                    //if (!self.out_pacer.is_allowed(now_us, need, 1)) continue;

                    if (outbox.pop()) |ident| {
                        const timed = TimedIdentifier{ .until_us = now_us + io_delay_us, .ident = ident };
                        self.outwait.pushBack(timed) catch unreachable;
                        std.debug.print("ready: {} - - - {}\n", .{ outbox.unfinished.sequence, self.outwait.len });

                        //self.out_scheduler.on_sent(ch_idx, need); // account for scheduler
                        //self.out_pacer.consume(need, 1); // account for pacer
                        progress = true;
                    }
                }
            }

            if (!progress) break;
        }
    }

    fn in_drain(self: *Link, now_us: i64) void {
        self.in_pacer.start_tick();
        self.in_scheduler.start_tick();

        while (true) {
            var progress = false;

            const classes = PriorityScheme.classes(.receive);
            for (classes) |class_indices| {
                for (class_indices) |channel| {
                    const ch_idx = @intFromEnum(channel);

                    var inbox = &self.inbox[ch_idx];

                    while (true) {
                        const ident = inbox.peek() orelse break;

                        const package = self.in_buffer.getPtr(ident).?;
                        const need = package.wireSize();
                        _ = need;

                        //if (!self.in_scheduler.can_take(ch_idx, need)) break;
                        //if (!self.in_pacer.allow(need)) break;

                        _ = inbox.pop() orelse unreachable;
                        const timed = TimedIdentifier{ .until_us = now_us + io_delay_us, .ident = ident };
                        self.inwait.pushBack(timed) catch unreachable;

                        //self.in_scheduler.on_taken(ch_idx, need);
                        //self.in_pacer.consume(need);
                        progress = true;
                    }
                }
            }

            if (!progress) break;
        }
    }

    pub fn submit(self: *Link, channel: Channel, message: Message) void {
        const idx = @intFromEnum(channel);
        self.outbox[idx].append(message);
    }

    pub fn withdraw(self: *Link) ?Message {
        const now_us = std.time.microTimestamp();

        while (true) {
            // Prüfen, ob etwas in der inwait-Queue fällig ist
            if (self.inwait.peekFront()) |front| {
                if (front.until_us <= now_us) {
                    self.unfinished = self.inwait.popFront().?.ident;
                } else {
                    self.unfinished = null;
                }
            } else {
                self.unfinished = null;
            }

            // Wenn kein ident verfügbar ist → nix zu tun
            const ident = self.unfinished orelse return null;

            var package = self.in_buffer.getPtr(ident) orelse {
                // sollte eigentlich nicht vorkommen: ident ohne package
                self.unfinished = null;
                continue;
            };

            // Versuchen, Message aus Package zu ziehen
            const message = package.pop(self.gpa) catch |err| {
                switch (err) {
                    error.Empty => {
                        // Package ist leer, also rauswerfen und beim nächsten weitersehen
                        _ = self.in_buffer.remove(ident);
                        self.unfinished = null;
                        continue; // direkt nächste Runde probieren
                    },
                    else => unreachable,
                }
            };

            return message;
        }
    }

    pub fn send(self: *Link, socket: *net.Socket, endpoint: net.EndPoint) !bool {
        const now_us = std.time.microTimestamp();

        if (self.outwait.peekFront()) |peek| {
            if (peek.until_us <= now_us) {
                const ident = self.outwait.popFront().?.ident;
                var package = self.out_buffer.getPtr(ident).?;

                const idx = @intFromEnum(ident.channel);
                const ack = Ack{ .bits = self.inbox[idx].ack_bits, .head = self.inbox[idx].ack_head };
                package.sendTo(ident, ack, socket, endpoint) catch unreachable;

                self.debug.tx_pkts += 1;
                self.debug.tx_bytes += package.wireSize();

                // package is kept in case resend is necessary

                return true;
            }
        }

        return false;
    }

    pub fn receive(self: *Link, package: Package) void {
        const header = package.deserializeHeader() catch {
            self.debug.recv_invalid += 1;
            return;
        };

        self.debug.rx_pkts += 1;
        self.debug.rx_bytes += package.wireSize();

        const ident = Identifier{ .channel = header.channel, .sequence = header.sequence };

        self.in_buffer.put(ident, package) catch unreachable;

        const idx = @intFromEnum(ident.channel);
        self.inbox[idx].append(ident);

        //if (io_delay_us == 0) {
        //    self.dispatch(ident, now_us);
        //} else {
        //    const timed = TimedIdentifier{ .until_us = now_us + io_delay_us, .ident = ident };
        //    self.inwait.pushBack(timed);
        //}
    }

    pub fn isConnected(self: *Link) bool {
        _ = self;
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
            const add: u128 = (self.bytes_per_sec * dt_ns) / std.time.ns_per_s;
            self.byte_tokens = @min(self.byte_tokens + add, self.max_burst_bytes);
        }
        if (self.pkts_per_sec != 0) {
            const add: u128 = (self.pkts_per_sec * dt_ns) / std.time.ns_per_s;
            const sum = self.pkt_tokens + add;
            self.pkt_tokens = if (sum > self.max_burst_pkts) self.max_burst_pkts else @intCast(sum);
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
        for (0..CHANNEL_COUNT) |i| {
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
pub const InScheduler = struct {
    deficit: [CHANNEL_COUNT]usize = .{0} ** CHANNEL_COUNT,
    quantum: [CHANNEL_COUNT]usize = .{0} ** CHANNEL_COUNT,
    max_pkts_per_tick_ch: [CHANNEL_COUNT]u32 = .{std.math.maxInt(u32)} ** CHANNEL_COUNT,
    taken_this_tick: [CHANNEL_COUNT]u32 = .{0} ** CHANNEL_COUNT,

    pub fn init() InScheduler {
        var s = InScheduler{};

        for (0..CHANNEL_COUNT) |i| {
            const ch: Channel = @enumFromInt(i);
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

            s.quantum[i] = q;
            s.max_pkts_per_tick_ch[i] = max_pkts;
        }

        return s;
    }

    pub fn start_tick(self: *InScheduler) void {
        self.taken_this_tick = .{0} ** CHANNEL_COUNT;
        for (0..CHANNEL_COUNT) |i| {
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
};
