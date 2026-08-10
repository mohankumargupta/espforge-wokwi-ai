# Feedback: wokwi-chip-diagram (prompt2a) — TMP102

## Summary

Created `chip.json` and `diagram.json` for a Wokwi custom chip emulating the
TMP102 I2C temperature sensor, sourced from the Canonical Test Specification.

- `artifacts/tmp102/prompt2a/chip.json` — validated against the skill's
  `chip.schema.json`, copied to `artifacts/tmp102/outputs/chip.json`.
- `artifacts/tmp102/outputs/diagram.json` — built on the skill template
  (ESP32-C3 DevKitM-1 + `chip-chip` + serial monitor), validated with
  `wokwi-cli lint` (passes, 1 informational note about the template's board part).

## Design decisions

- **Pins** (`chip.json`): all 6 physical SOT563 pins from spec_tmp102.md in
  datasheet order, pin 1 first — `SCL, GND, ALERT, ADD0, V+, SDA`.
- **Control**: one environmental control, `temperature` (range −40…+125 °C,
  step 0.25, the datasheet's operating range and resolution), mirroring the
  test spec's single observable.
- **Wiring** (from `esp32c3.yaml` canonical profile):
  - I2C1: `esp:4` → `chip1:SDA`, `esp:5` → `chip1:SCL` (green)
  - Power: `esp:3V3.1` → `chip1:V+` (red), `esp:GND.1` → `chip1:GND` (black)
  - `esp:GND.1` → `chip1:ADD0` (black) — straps the device to its default
    slave address 0x48. This is a **wiring** parameter, so it lives in the
    `connections` array and is deliberately **not** in `attrs` (per skill rule;
    an attrs override previously parsed to 0 and bricked bus responsing).
  - `ALERT` left unconnected — alert/interrupt is excluded by the test spec.
- **attrs**: only the environmental attribute `temperature: "25.0"` (plain
  decimal, the test spec's canonical `default` from the +25 °C / `0x1900`
  vector), on the existing `chip1` part.

## Notes / obstacles

1. `prompt2d/attributes.md` (wokwi-customchip output) does not exist yet for
   tmp102, so the authoritative environmental-vs-wiring classification was
   unavailable. Classification was instead derived from the test spec's
   excluded-features list: only `temperature` is environmental; everything else
   (address via ADD0, ALERT, config) is excluded or wiring-derived. When
   prompt2d runs later, its classification is expected to agree; if it
   disagrees, `diagram.json`'s `attrs`/`connections` should be re-derived from
   it.
2. `check-jsonschema` and `wokwi-cli` were both available system-wide; no
   installs needed.
3. `wokwi-cli lint` emits one `info` ("unsupported-part" undocumented board
   part type) — this comes from the skill's own template and is expected.