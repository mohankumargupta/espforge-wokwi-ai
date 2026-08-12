# Skill Feedback: canonical-test-spec (run: APDS9960)

## Obstacles

- **Gesture is the device's headline feature but is not expressible as a
  numeric observable.** The APDS9960's signature capability is directional
  gesture detection, which the ESPHome driver reports as event-driven binary
  sensor pulses (true then false) derived from a scripted FIFO dataset sequence
  and a 500 ms timing window. The skill's observable model (`id`, `type`,
  `units`, `default`) has no place for an event pulse, and a numeric default
  makes no sense for it. I excluded gesture from the canonical test (documented
  in Excluded Features) and anchored the test on proximity + RGBC instead. The
  skill would benefit from guidance on how (or whether) to canonicalize
  event/state-driven observables.

- **No authoritative single default for the RGBC channels.** The datasheet
  gives a no-object test vector for proximity only (a range, `PDATA = 10–25`);
  for the clear/red/green/blue channels there is no idle measurement vector —
  only a responsivity figure that depends on an unspecified irradiance, and the
  `0x00` power-on register reset values. This directly collides with the
  skill's two rules that a `default` MUST exist (wokwi-customchip /
  wokwi-test-harness treat a missing field as a defect) and that values MUST
  NOT be invented. I resolved it by supplying deterministic ground-truth
  percentages (20.0/15.0/12.0/9.0), explicitly documented in both the
  Observables section and the Traceability table as *selections within the
  datasheet's full-scale scaling*, not datasheet measurements. This keeps both
  downstream consumers on the same number, but the skill should spell out how
  to handle an observable whose value is not directly traceable — otherwise
  each implementer reinvents the policy.

- **Proximity default had to be carved out of a documented range.** The
  datasheet's no-object proximity vector is `PDATA = 10–25`; there is no single
  "typ" value (the grey-card scenario has `typ 120`, but implies a physical
  object at 100 mm). Choosing `PDATA = 18` (≈7.1%) is a judgment call the skill
  does not explicitly authorize ("avoid minimum/maximum" pushed me off both
  range ends). The spec records it as a deterministic representative, but the
  skill should say how to collapse a documented range into one default.

- **Gain/timing context matters for traceability.** The datasheet's proximity
  vector is conditional on LDRIVE/PGAIN/PPULSE/PPLEN/LED_BOOST and VLEDA. I
  carried that condition into the spec and noted the ESPHome defaults, because
  a downstream chip that silently uses different gain settings would emit a
  different count for the same physical scenario. Worth stating explicitly in
  the skill that test-vector context must be preserved.

## Improvements

- Recommend the skill formally support two classes of default provenance:
  (a) "datasheet test vector" and (b) "deterministic ground truth within the
  device's documented scale" — with the requirement that (b) be labelled as
  such in the output and Traceability table, so it is auditable rather than
  ambiguous.
- Recommend guidance for observables that are event/state driven (binary
  pulses, gestures): either exclude them with a stated rationale (as done
  here) or give them a separate canonical form.
- The `accuracy_decimals`/`dump_config` mapping worked cleanly here
  (precision=1, labels from dump_config), confirming the TMP102 feedback point
  that labels should be traced to the component, not re-derived.

## Notes

- No sub-skills in this run.
- Produced `artifacts/apds9960/outputs/test_spec_apds9960.md` with five
  observables (clear, red, green, blue, proximity), all `%`, precision 1,
  including a canonical decode table (percent → raw counts → Little-Endian
  register bytes) for downstream encoding/assertion agreement.
- Defaults: clear 20.0 (0x3333), red 15.0 (0x2666), green 12.0 (0x1EB8),
  blue 9.0 (0x170A), proximity 7.1 (0x12).
