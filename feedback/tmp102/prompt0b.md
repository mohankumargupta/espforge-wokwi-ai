# Skill Feedback: canonical-test-spec (prompt0b) — tmp102

## What worked

- The skill flow is straightforward: read the inputs listed under `<outputs_dir>`
  and render a single `test_spec_<device>.md`. The example-driven YAML sections
  (device, observables, assumptions, presentation) map directly onto the TMP102
  inputs with no guesswork.
- The reference files (`sensor-classes.md`, `small-classes.md`) were not
  strictly needed for TMP102 (single `temperature` observable, units `C`), but
  they confirm the vocabulary is stable for downstream skills.
- The template-string warning about language-specific format syntax is
  important and worth keeping: TMP102's own ESPHome component publishes with
  `accuracy_decimals=1` and logs `%.1f`, matching the canonical template.

## Obstacles / issues

1. **Traceability of the default (21.0).** The skill says "Choose sensible
   real-world defaults" but also "every value must have a traceable source" and
   "do not invent values." A default like 21.0 is explicitly a convention, not a
   datasheet value. I recorded it in a "Traceable Source" table as a
   "deterministic ambient-room convention" rather than attributing it to the
   datasheet. It would help if the skill explicitly carved out the default from
   the "must exist in a source" rule (it already nudges this by saying "Choose
   sensible real-world defaults.").
2. **No guidance on the `default` value vs a "test input".** The spec picks a
   default the sensor will report, but downstream test harnesses need to know
   it is *both* what the simulator should emit *and* what the harness asserts.
   A one-line statement that the default is the deterministic asserted value
   would remove ambiguity.
3. **`observables` id naming is free-form.** No canonical registry of
   observable ids is mandated; I used `temperature` which matches the ESPHome
   sensor id and the reference vocabulary. Fine, but worth pinning the rule:
   "use the low-case sensor-term found in the component/docx."
4. `spec_tmp102.md` is rich enough that I had to actively resist pulling
   protocol/register details (Extended Mode, fault queue, ALERT, TLOW/THIGH)
   into the spec — the Excluded Features list is the right valve for that, and
   it worked cleanly.

## Improvements suggested

- Add a short "Deterministic Test Input" line to the observables section
  clarifying that `default` is both the emulated sensor output and the expected
  value (what reaches the assertion), making the deterministic intent explicit.
- Optionally provide a canonical observable-id registry (small list) so skills
  agree on identifiers like `temperature`, `pressure`, `humidity` without
  each skill re-deriving them.
- Consider stating explicitly that "C" (rather than "°C") is the canonical unit
  string for temperature in the presentation template, since the datasheet and
  ESPHome use °C but the example template uses `C`. I followed the example verbatim.
- The "Status: unknown" recommendation exists but there is no worked example of
  a partial/unknown spec; a small worked case would clarify when to emit status.