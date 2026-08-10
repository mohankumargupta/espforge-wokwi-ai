# Feedback: data-conversions-complex-logic (prompt0c) — TMP102

## Summary

Zig 0.16 std project created at `artifacts/tmp102/prompt0c` with:
- `src/root.zig` — 15 conversion/reference-algorithm functions weighed against
  spec tables 5/6, config register packing, fault queue, conversion rate,
  big-endian byte order, slave addressing. 13 unit tests.
- `src/main.zig` — CLI demo printing worked examples + a fuzz test
  (encode∘decode fixed-point invariant via `std.testing.fuzz` + `*std.testing.Smith`).
- `conversions_manifest.md` — worked examples, bit-layout assumptions, and
  per-encode overflow policies.

## Verified

- `zig build` OK; `zig build test` 17/17 pass (root module + exe module).

## Observations / obstacles

1. The skill's Zig 0.16 notes proved accurate and necessary:
   - `std.testing.expect*` returns error unions and every assertion needs `try`.
   - `std.testing.fuzz(context, fn, .{})` passes a `*std.testing.Smith`.
   These are NOT discoverable from the generated template — the guidance saved
   a round of compile errors. Good as written.

2. Pitfall that cost a build + test round: Zig 0.16's generated `main.zig`
   signatures `main(init: std.process.Init)` — an unused `init` is a hard
   compile error (`error: unused function parameter`), not a warning. The skill
   doesn't mention this; a `_ = init;` discard was needed.

3. Code-layout decision: `zig init` generated BOTH `src/main.zig` (exe root)
   and `src/root.zig` (module root, exposed to consumers as `@import("prompt0c")`).
   I put all conversion logic + their unit tests in `root.zig` (the reusable
   module root), and a thin demo CLI + fuzz test in `main.zig`. The skill only
   says "edit main zig file", which is ambiguous with this two-file template;
   future runs should know the module root is `root.zig` and gets tested under
   `zig build test` (both exe and module test steps run).

4. Rounding trap in worked-example encode tests: Table 5 values like +127.9375,
   -0.25 are exactly representable in f32 (multiples of 2^-4 times an integer),
   so `expectEqual(word, ...)` is safe. Beware adding test temps that are NOT
   exact multiples of 0.0625 (e.g. +25.1 C) — those need the half-LSB tolerance
   path, which I only used in the roundtrip test, not the table tests.

5. Spec ambiguity that required a judgment call and is now pinned in the
   manifest: the Configuration reset `0x60A0` decodes with TM=0 (Comparator
   mode) and AL=1 (pre-trip alert status). The spec text never states the reset
   thermostat mode explicitly; I decoded it from the reset word and tested both
   values. Also confirmed `toWord()` correctly drops read-only AL/R fields
   (0x60A0 -> 0x6080 on write).

6. The datasheet's Table 5/6 "raw register value" columns list the raw N-bit
   two's-complement count, NOT the full 16-bit word. Following the skill's
   rule, decode tests derive the expected signed count via the same
   sign-extension primitive under test applied to the raw value rather than
   hand-computing a signed decimal; a second assertion against the datasheet's
   real-world temperature keeps the test a genuine check.

7. No CRC/checksum algorithms exist on this device — "complex logic" here is
   the two's-complement sign extension + left-alignment for two data widths,
   the config bit-packing, and the fault-queue/rate tables. Skill handled this
   fine (manifest states no CRC identified).