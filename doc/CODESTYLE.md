# Codestyle Guidelines

## Use zig fmt

## Naming

See: <https://ziglang.org/documentation/0.14.1/#Style-Guide>

## TODO Tagging Convention

All TODO comments should be annotated using a structured tag in the following format:

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

If no fitting tag applies, use a generic TODO without a tag as a fallback.

These tags are intended for internal development use and should be periodically reviewed and cleaned up before releases.
