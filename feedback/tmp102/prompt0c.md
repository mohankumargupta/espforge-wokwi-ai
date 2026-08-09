# Skill Feedback — data-conversions-complex-logic (prompt0c)

Device: tmp102 · Date: 2026-08-10

## What worked

- The skill's flow (read spec -> `zig init` -> add functions + unit tests ->
  `zig build`) was clear and sufficient. No ambiguity about artifacts.

## Obstacles / notes

1. **Zig 0.16 API churn surfaced late.** The std testing assertions
   (`std.testing.expect*`, `expectApproxEqRel`) return error unions in 0.16
   and must be `try`'d; the generated template's "fuzz example" test also
   relies on the new `std.testing.fuzz`/`Smith` API. None of the `zig init`
   template or build files indicate this. A skill note that "0.16 test
   asserts need `try`" would have saved several compile-fix cycles.

2. **Datasheet HEX column is unsigned two's complement.** Table 6-2 lists the
   negative counts (e.g. `0xE70`, `0xC90`) as raw unsigned hex, not signed
   decimal. Deriving the expected signed count from the raw hex via the
   `signExtend` primitive (rather than hard-coding signed integers) keeps the
   test faithful to the datasheet and cross-checks the primitive. Worth a
   hint in the skill.

3. **Clamping on encode is a judgment call.** 128 C = 2048 counts overflows
   12-bit signed, so `temperatureCToRegisterWord12(128)` clamps to `0x7FF0`
   (127.9375 C). The spec lists both 128 and 127.9375 as `0x7FF`; the skill
   doesn't say whether to clamp or error on overflow. We chose clamp + a
   documented test. A policy sentence would help downstream skills that need
   identical behavior.

4. **Workdir-creation wrinkle.** The Bash tool fails if `workdir` doesn't
   exist yet, so the target dir had to be `mkdir`'d from the original cwd
   before `cd`-ing in for `zig init`. (Project-level tooling note, not a
   skill defect.)

## Suggestions

- Add a short "Zig 0.16 notes" section (try on asserts; Smith/fuzz API).
- State the overflow/clamp policy for encode functions explicitly.