# Feedback: data-conversions-complex-logic (tmp102) — prompt0c

## Skill observations / obstacles

1. **`zig init` template changed the executable wiring.** The 0.16 template
   now wires the exe to `src/main.zig` while the module (`root.zig`) is a
   separate test target, and `main` takes `std.process.Init`. The skill only
   says "edit main zig file", which is still correct, but the skill's
   "verify with `zig build`" note should probably be extended to `zig build
   test` — `zig build` alone compiles but does not run the unit tests. I ran
   both.

2. **`std.testing.expect*` requires `try` in 0.16** — confirmed. All
   `expectEqual`/`expectApproxEqAbs` had to be prefixed with `try`, exactly as
   the skill's note warned. No rediscovery needed.

3. **`decodeCount` `comptime bool` pitfall.** I first made the mode parameter
   `comptime` and `wordToCelsius` called it with a runtime value, causing a
   compile error ("argument to comptime parameter must be comptime-known").
   Fixed by making the parameter runtime. A subtle trap worth flagging for
   other devices with a mode-selected format.

4. **Doc comment placement.** A `//!` container-level doc comment directly
   after the `const std = @import("std");` line produced
   "expected type expression, found 'a document comment'". Container doc
   comments must come first or be regular `//` comments.

5. **Unary `+` not allowed in Zig** — `celsiusToWord12(+200.0)` is a compile
   error; plain `200.0` is fine. (Minor, known.)

6. **Worked-example test-vector rule worked well.** Deriving expected signed
   counts via `signExtend(raw, bits)` on the spec's raw register values made
   the tests genuine checks of the decode primitives rather than restatements
   of hand arithmetic.

7. **No CRC/checksum** for TMP102; complex logic is limited to sign-extension,
   alignment encode/decode (12-bit and 13-bit), and two config field decoders.
   The skill's CRC mention is generic and does not apply here.

## Environment

- zig 0.16.0 (homebrew), linux.
- Working dir: `artifacts/tmp102/prompt0c`.
