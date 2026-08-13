# Feedback: wokwi-chip-diagram (prompt2a) — DHT22

## Summary

Created `chip.json` and `diagram.json` for a Wokwi custom chip emulating the
Aosong DHT22 (AM2302) temperature/humidity sensor over its proprietary single-wire
bus, sourced from the Canonical Test Specification.

- `artifacts/dht22/prompt2a/chip.json` — validated against the skill's
  `chip.schema.json`, copied to `artifacts/dht22/outputs/chip.json`.
- `artifacts/dht22/outputs/diagram.json` — built on the skill template
  (ESP32-C3 DevKitM-1 + `chip-chip` + serial monitor), validated with
  `wokwi-cli lint` (passes, 1 informational note about the template's board part).

## Design decisions

- **Pins** (`chip.json`): all 4 physical single-row pins from spec_dht22.md in
  datasheet order, pin 1 first — `VDD, DATA, "", GND`. Pin 3 is `NULL` (no
  connection) per the spec, so it is skipped with an empty string in the pins
  array (per the schema's "Use empty strings to skip pins" rule).
- **Controls**: one range control per canonical observable (both environmental):
  - `temperature` — range −40…+80 °C (spec operating range), step 0.01
    (0.1 °C resolution per spec)
  - `humidity` — range 0…100 %RH, step 0.01 (0.1 %RH resolution per spec)
- **Wiring** (single-wire bus — no dedicated bus in `esp32c3.yaml`, so a free
  primary GPIO was chosen):
  - `esp:3` → `chip1:DATA` (green) — data line, pin 3 is a free GPIO (not
    reserved, not on the i2c1/spi1/uart1 bus pairs)
  - `esp:3V3.1` → `chip1:VDD` (red)
  - `esp:GND.1` → `chip1:GND` (black)
- **attrs**: only environmental attributes on the existing `chip1` part, as
  plain decimal: `temperature: "25.0"`, `humidity: "50.4"` — the test spec's
  canonical `default` values (from the `0x00FA` / `0x01F8` vectors).

## Notes / obstacles

1. `prompt2d/attributes.md` (wokwi-customchip output) does not exist yet for
   dht22, so the authoritative environmental-vs-wiring classification was
   unavailable. Both observables are inherently environmental (ambient
   temperature/humidity measurement), so both were classified environmental from
   the test spec. When prompt2d runs later, its classification is expected to
   agree; if it disagrees, `diagram.json`'s `attrs` should be re-derived.
2. The DHT22 needs an external ~4.7 kΩ pull-up on DATA per spec. The custom
   chip's firmware (prompt2d) is expected to model this internally; no resistor
   part was added to the diagram to keep it consistent with the other devices.
3. `wokwi-cli lint` emits one `info` ("unsupported-part" undocumented board part
   type) — this comes from the skill's own template and is expected.