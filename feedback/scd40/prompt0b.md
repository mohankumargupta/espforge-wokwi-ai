# Skill Feedback: canonical-test-spec, device scd40

## What went well

- The skill's structure (device / capability / observables / assumptions /
  excluded / presentation) mapped cleanly onto the SCD40 inputs.
- The requirement that `default` be the single source of truth for both the
  emitting and the asserting skill was clear and actionable; the datasheet's
  canonical `read_measurement` example (CO2=500 ppm, T=25 C, RH=37%) provided
  an authoritative, jointly consistent set of defaults.
- The explicit warning about never embedding `{:.1f}`-style templates into
  C-family format strings was useful and I propagated it into the spec.

## Obstacles / ambiguities

1. **Two authoritative sources for defaults.** The chip spec and the datasheet
   agree, but the skill does not say which source takes precedence if they
   diverge. It would help to state "datasheet primary, ESPHome source secondary"
   or similar precedence ordering.
2. **Units notation inconsistency.** The skill's examples use `C` while the
   datasheet/spec use `°C`. I chose `C` for observables/presentation to match
   the skill illustration, but this tension should be resolved explicitly in
   the skill (e.g. a mandated unit notation).
3. **`type: int` vs `type: float` for integer-valued observables.** The skill
   only shows float examples. For CO2 (integer ppm), the choice was not pinned
   down; downstream skills may disagree on whether the sensor/register is
   asserted as int or float. A short note on when to use `int` would remove
   ambiguity.
4. **Presentation precision traceability.** Precision had to be lifted from
   `sensor.py` `accuracy_decimals`, but the skill does not list ESPHome source
   as an explicit precision provenance candidate. Minor, but worth stating.
5. **Initialization wait vocabulary.** The spec assumes the chip is already in
   periodic measurement and data-ready. The skill's `assumptions` block has no
   field for "device already running / configured" — I folded it into
   prose. An explicit assumption key (e.g. `device_running: true`) would be
   cleaner.

## Suggested improvements

- Add a "source precedence" note (datasheet > chip spec > ESPHome source).
- Add an example with an integer observable to the skill.
- Pin down unit notation norms.
- Consider a temperature/`co2`-style per-observable assurance that `default`
  values together must be consistent with one single measurement scenario when
  the device emits multiple observables in one transaction.