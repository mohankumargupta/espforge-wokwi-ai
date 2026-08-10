# Skill Feedback: canonical-test-spec (run: TMP102)

## Obstacles

- The skill's `presentation.template` uses `{:.1f}` notation, which is
  Python/Rust-style and not valid printf syntax. Downstream generators must
  translate it. The skill documents this clearly, but it would reduce risk to
  also specify the canonical label/wording choice discipline up front — small
  divergences from the ESPHome driver's own log format (`Temperature=%.1f°C`)
  are inevitable and must be traced to this spec, not re-derived.

- Choosing a `default` that is both a sensible ground-truth temperature and
  traceable required cross-referencing the datasheet test-vector table
  (spec_tmp102.md Table 5, `+25°C` → `0x1900`). The skill does not explicitly
  require documenting the traceability of `default`; adding a
  `Traceability` table in the output was my own addition. Consider making a
  traceability section a normative part of the spec so "every value has a
  traceable source" is auditable rather than aspirational.

- The relationship between the raw 12-bit count and the 16-bit register word
  (left-aligned, bits 15:4) is a real trap for downstream skills. This spec
  exists to prevent the wokwi chip and the Rust harness from disagreeing on the
  emitted vs. asserted temperature. The skill's guidance about `default` is
  strong, but the alignment semantics of the bus word would be worth stating
  explicitly (or referencing to the device spec) so it doesn't get re-derived
  independently.

## Improvements

- Recommend adding a short "Traceability" example to the skill's template so
  outputs consistently record where every field's value came from.
- Recommending that the skill explicitly require the output to state one
  canonical default per observable AND a worked decode (register word → count →
  °C) for that default, since two independent decodings of the same float can
  silently disagree at simulation time.

## Notes

- No sub-skills in this run.
- Produced `artifacts/tmp102/outputs/test_spec_tmp102.md` with one observable
  (temperature), default 25.0 °C, precision 1, template
  `"Temperature = {:.1f} C"`.