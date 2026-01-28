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

//TODO[IMPROVEMENT] make buffer the first arg in all the serialize/deserialize functions

// ╔══════════════════════════════ pack ══════════════════════════════╗
pub usingnamespace @import("core.zig");

const err = @import("error.zig");
pub const DeserializeError = err.DeserializeError;
pub const Error = err.Error;
pub const SerialisationError = err.SerializeError;

const Float = @import("float.zig").Float;
pub const F16 = Float(f16);
pub const F32 = Float(f32);
pub const F64 = Float(f64);
pub const F128 = Float(f128);

const Integer = @import("integer.zig").Integer;
pub const I8 = Integer(i8);
pub const I16 = Integer(i16);
pub const I32 = Integer(i32);
pub const I64 = Integer(i64);
pub const I128 = Integer(i128);
pub const U8 = Integer(u8);
pub const U16 = Integer(u16);
pub const U32 = Integer(u32);
pub const U64 = Integer(u64);
pub const U128 = Integer(u128);

pub const primitive = @import("primitive.zig");
pub const Bool = primitive.Bool;
pub const Enum = primitive.Enum;
pub const Text = primitive.Text;

pub const util = @import("util.zig");
pub const Address = util.Address;
pub const Angle = util.Angle;
pub const UUID4 = util.UUID4;
pub const Vec2 = util.Vec2;
// ╚══════════════════════════════════════════════════════════════════╝
