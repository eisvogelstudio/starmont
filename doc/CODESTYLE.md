# Codestyle Guidelines

Keep files readable, segmented, and coherent across the project. Adapt these rules as necessary but preserve consistency.

## Formatting

Always use `zig fmt` to ensure consistent formatting across the codebase.
Never commit unformatted code.

## Naming

Follow the Zig official naming style:
<https://ziglang.org/documentation/0.14.1/#Style-Guide>

Use full, descriptive names at the top level (e.g. messages instead of msg). Abbreviations are acceptable in nested or inner scopes, as long as they follow naturally (e.g. message → msg → m).

## Comment Tagging Conventions

Use structured code comments to make the codebase more understandable and searchable.

### 1. NOTE

```zig
// NOTE: Short to detailed explanation
```

To document important design decisions, rationale, warnings, gotchas, trade-offs, performance considerations, or non-obvious relationships.
NOTE comments are allowed (and often should) be multi-line.

### 2. TODO

All `TODO` comments **must** use a structured format:

```zig
// TODO[TAG]: Optional explanation
```

Use the following standardized tags:

- BUG           - A known bug that causes incorrect behavior
- FIXME         - A critical issue that must be fixed urgently
- SECURITY      - Security risk or input validation concern
- MISSING       - A feature is unimplemented
- IMPROVE       - A feature is implemented but needs improvement

- OPTIMISATION  - Potential for performance or memory improvement
- REFACTOR      - Structural cleanup or code organization, no behavior change
- REMOVE        - Code marked for deletion in future cleanup
- ARCH          - Architectural concern or large-scale structural decision

- TEST          - Missing, incomplete, or weak tests
- DOC           - Missing or outdated documentation

- DEBUG         - Temporary debug code or logging to be removed

Additional context should be added after the tag when appropriate:

```zig
// TODO[BUG]: Collision detection fails for fast-moving objects
```

If no fitting tag applies, use a generic TODO without a tag as a fallback, but this should be rare.

These tags are intended for internal development use and should be periodically reviewed and cleaned up before releases.

## Visual Seperators

Use logical groupings with clear visual separators to maintain structure in source files:

```zig
// ╔══════════════════════════════ level 1 ══════════════════════════════╗

// ╚═════════════════════════════════════════════════════════════════════╝

// ┌──────────────────── level 2 ────────────────────┐
// └─────────────────────────────────────────────────┘

// ---------- level 3 ----------
// -----------------------------
```

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
