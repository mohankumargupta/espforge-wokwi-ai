# Feedback — prompt0c (data-conversions-complex-logic) for SCD40

Run: Wed Aug 12 2026, Zig 0.16.0 (linuxbrew), from
`/home/pi/Developer/wokwi-ai` into
`artifacts/scd40/prompt0c`.

## What went well

- Spec was rich: every command's data word is a plain 16-bit count (big-endian)
  with a worked-example table including CRCs, so decode/encode vectors were
  unambiguous to write.
- The Zig 0.16 note in the skill (expect* returns error union, must `try`; fuzz
  takes `*std.testing.Smith`) panned out exactly — the generated template still
  uses the old expectations-free spelling in comments but the compiler enforces
  `try`, and `std.testing.fuzz` did require a `*std.testing.Smith`.
- Skill discipline (run from artifacts dir, `zig init` then edit src/main.zig,
  verify with `zig build`) worked without friction.

## Obstacles / notes

1. **Third-party counting bug (caught by tests):** I initially wrote the 48-bit
   serial sentinel as `0x0000_ffff_ffff` intending 2^48−1, but that literal has
   only 8 f's = 0xFFFFFFFF (2^32−1). The `serialToRaw` out-of-range check then
   rejected a valid serial and the test caught it. Fixed to
   `0xffff_ffff_ffff`. Worth a guardrail: when writing hex literals in shorthands,
   count f's against the intended bit-width (12 f's = 48 bits).
2. **Datasheet worked examples are not always exactly representable.** 25.0 °C
   → datasheet `0x6667`, but the nearest exact count is 26214; 37.0 %RH →
   datasheet `0x5eb9`, nearest is 24248; 5.4 °C offset → `0x07e6` matches
   nearest but 6.2 °C → 2322 also matches. So no single rounding mode (round,
   ceil, floor) reproduces every table row. I chose round-to-nearest for encode
   and documented an allowed off-by-one for those rows; decode tests use the
   datasheet raw words as their oracle. Downstream emulator skills should
   tolerate ±1 count (or generate from the float then display-round).
3. **`zig build` passed with zero test feedback** when the only failed step was
   the `test` step in a prior run (it printed `(no output)` on a re-run because
   the build was cached) — used `zig build test --summary all` to get the
   16/16 count explicitly.
4. **CRC vectors:** datasheet provided CRC for every worked example word which
   validated the crc8 implementation thoroughly (23 vectors) — nice to have,
   keep this pattern in canon-specs.