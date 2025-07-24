# Codestyle Guidelines

Keep files readable, segmented, and coherent across the project. Adapt these rules as necessary but preserve consistency.

## Formatting

Always use `zig fmt` to ensure consistent formatting across the codebase.
Never commit unformatted code.

## Naming

Follow the Zig official naming style:
<https://ziglang.org/documentation/0.14.1/#Style-Guide>

## TODO Tagging Convention

All `TODO` comments **must** use a structured format:

```zig
// TODO[TAG]: Optional explanation
```

Use the following standardized tags:

- TODO[BUG]            - A known bug that causes incorrect behavior
- TODO[FIXME]          - A critical issue that must be fixed urgently
- TODO[SECURITY]       - Security risk or input validation concern
- TODO[MISSING]        - A feature is unimplemented

- TODO[OPTIMISATION]   - Potential for performance or memory improvement
- TODO[REFACTOR]       - Structural cleanup or code organization, no behavior change
- TODO[REMOVE]         - Code marked for deletion in future cleanup
- TODO[ARCH]           - Architectural concern or large-scale structural decision

- TODO[TEST]           - Missing, incomplete, or weak tests
- TODO[DOC]            - Missing or outdated documentation

- TODO[DEBUG]          - Temporary debug code or logging to be removed

Additional context should be added after the tag when appropriate:

```zig
// TODO[BUG]: Collision detection fails for fast-moving objects
```

If no fitting tag applies, use a generic TODO without a tag as a fallback, but this should be rare.

These tags are intended for internal development use and should be periodically reviewed and cleaned up before releases.


Use logical groupings with clear visual separators to maintain structure in source files:

## Import Ordering

```zig
// ---------- external ----------
const ziggy = @import("ziggy");
// ------------------------------

// ---------- zig ----------
const builtin = @import("builtin");
const std = @import("std");
const testing = std.testing;
// -------------------------

// ---------- starmont ----------
// from another module
const core = @import("shared").core;
const util = @import("util");
// ------------------------------

// ---------- local ----------
// relative path in same module
// ----------------------------
```

## Visual Seperators

// ╔══════════════════════════════ level 1 ══════════════════════════════╗

// ╚═════════════════════════════════════════════════════════════════════╝

// ┌──────────────────── level 2 ────────────────────┐
// └─────────────────────────────────────────────────┘

// ---------- level 3 ----------
// -----------------------------
