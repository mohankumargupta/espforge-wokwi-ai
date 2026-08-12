# Skill Feedback: data-conversions-complex-logic (run: APDS9960)

## Obstacles

- **The spec's inline CountMAX formula contradicts its own worked examples.**
  `spec_apds9960.md` Data Conversion states `CountMAX = min(1025 × CYCLES,
  65535)`, but the spec's worked-example table gives `0xF6 -> 10241` and
  `0xDB -> 37889`, which only match `1024 × CYCLES + 1` (0xFF and 0x00 match
  both forms). The skill has no rule for resolving an internal spec
  contradiction. I treated the worked examples as authoritative (they are the
  test vectors), implemented `min(1024*cycles + 1, 65535)`, and recorded the
  discrepancy in the function doc comment, the manifest, and this feedback.
  The skill should say what wins when an inline formula and the worked-example
  table disagree.

- **tPROX is not fully deterministic from the spec.** The formula
  `tPROX = tINIT + tCNVT + PPULSE × tACC` names tINIT and tACC as "per PPLEN"
  but never tabulates them, so they cannot be implemented as constants without
  inventing values — which the skill (and the project's ground rules) forbid.
  I implemented the formula with `t_init_us`/`t_acc_us` as caller parameters
  and fixed `tCNVT = 796.6 µs`. The skill would benefit from explicit guidance
  on how to represent a formula whose constants are referenced but not given
  in the source spec.

- **Second internal inconsistency in timing constants.** The tPROX formula
  line says `tCNVT = 796.6 µs`, while the Timing reference section says the
  proximity ADC conversion is "~696.6 µs fixed". I used the formula's stated
  value (796.6 µs) and documented the discrepancy in the manifest. Same root
  cause as the CountMAX issue: the source spec has internal inconsistencies
  and no stated precedence rule.

- **`0x80` (negative zero) breaks a naive offset round-trip.** The
  sign/magnitude encoding has two representations of zero (`0x00` and `0x80`).
  `offsetFromByte(0x80) == 0` but `offsetToByte(0) == 0x00`, so a brute-force
  "all 256 bytes round-trip" test fails on 0x80. The skill's worked-example
  table lists only `0x7F/+127`, `0x81/-1`, `0xFF/-127` — no 0x80 entry. I
  canonicalized 0x80 -> 0 and excluded it from the exhaustive round-trip test,
  documenting the canonicalization in the manifest. Worth calling out in the
  skill that sign/magnitude duplicates zero and needs a canonical-encoding
  decision.

## Improvements

- Recommend a rule for spec internal contradictions: worked-example tables
  are authoritative over inline formulas; if they disagree, implement the
  worked examples and record the discrepancy in the manifest (as done here for
  CountMAX).
- Recommend guidance for formulas whose constants are referenced but not
  tabulated (tINIT/tACC): parameterize the unknowns, fix only the constants
  actually given, and state explicitly that the absent values were not
  invented.
- Recommend a canonical-encoding rule for sign/magnitude fields that
  duplicate zero.

## Notes

- No sub-skills in this run.
- Produced `artifacts/apds9960/prompt0c/` (zig 0.16 `zig init` project):
  `src/main.zig` with 16 conversion/reference functions and their unit tests;
  `conversions_manifest.md` recording layout, worked examples, and out-of-range
  policies.
- Canonical decode-table byte pairs verified: 20.0% -> 0x3333 (0x33/0x33),
  15.0% -> 0x2666 (0x66/0x26), 12.0% -> 0x1EB8 (0xB8/0x1E), 9.0% -> 0x170A
  (0x0A/0x17), 7.1% -> 0x12.
- `zig build` and `zig build test` pass, including three `std.testing.fuzz`
  round-trip fuzz tests (RGBC %, proximity %, offset).
- Zig 0.16 notes confirmed: `expect*` must be `try`'d, and
  `std.testing.fuzz(ctx, fn, .{})` takes a `*std.testing.Smith` callback.
