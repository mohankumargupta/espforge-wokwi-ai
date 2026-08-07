# Feedback: canonical-test-spec for tmp102 (prompt0b)

## What went well
- All inputs were already present in `artifacts/tmp102/outputs/`
  (`esphome_component.txt`, `spec_tmp102.md`, `tmp102.mdx`, and the `tmp102/`
  component source), so the skill required no upstream work.
- The spec was straightforward to derive: a single observable (temperature),
  one capability, default 21.0 °C, precision 1 (from `accuracy_decimals=1` and
  the `%.1f` log format in the ESPHome component), label "Temperature" from the
  component source.

## Obstacles / observations
- The skill does not specify a `sources`/traceability section in the output
  schema, yet it demands "every value must have a traceable source". I added a
  Sources table to satisfy the traceability goal. Consider making this an
  explicit, mandatory section so downstream reviewers can audit provenance.
- The skill's "Avoid protocol details" guidance conflicts slightly with the
  "every value traceable" goal: e.g. the default 21.0 °C has no datasheet
  origin (it is a canonical choice, explicitly allowed by the skill). The
  Sources table helps document this distinction; a "canonical choice vs
  datasheet" tag per value would be clearer.
- `default: 21.0` is taken verbatim from the skill example for TMP102, which is
  convenient but not derived from any input artifact. It works here, but for
  devices without a skill example the guidance "choose sensible real-world
  defaults" is subjective and could cause different runs to pick different
  defaults. Consider pinning defaults in a shared reference.

## Suggestions for improvement
- Add an explicit `sources:` section (or `traceability:` key) to the output
  schema, listing for each value where it originates (datasheet / ESPHome source
  / canonical choice).
- Clarify the deterministic nature of the default: e.g. "the canonical default
  is a fixed constant for the device, not re-picked per run".
- Consider a short list of TMP102-specific excluded features (extended mode,
  high-speed mode, one-shot, conversion-rate control, fault queue) as a
  reference, since the generic skill list (EEPROM, power management, etc.) only
  partially covers this device.
