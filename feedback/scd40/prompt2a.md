# prompt2a — wokwi-chip-diagram for SCD40

## Summary

Generated Wokwi custom-chip scaffolding for the Sensirion SCD40 (I2C CO2 /
temperature / humidity sensor, address `0x62`) from `test_spec_scd40.md`.

Outputs:
- `artifacts/scd40/prompt2a/chip.json` (+ copied to `outputs/chip.json`)
- `outputs/diagram.json`

## chip.json

- **pins**: `VDDH`, `VDD`, `GND`, `SDA`, `SCL`, `DNC` — sourced from the
  datasheet pin table in `spec_scd40.md` (6-pin LGA package, VDDH = pin 1).
- **controls**: one range control per canonical observable (all environmental):
  - `co2` — min 0, max 40000 ppm, step 1
  - `temperature` — min -10, max 60 C, step 0.01
  - `humidity` — min 0, max 100 %, step 0.01
- Validated against `chip.schema.json` with `check-jsonschema` (ok).

## diagram.json

Built from the skill template (kept serial monitor + board + chip parts).

- **attrs** on `chip1` (plain decimal, canonical defaults):
  `co2: "500"`, `temperature: "25.0"`, `humidity: "37.0"`.
  No `attributes.md` existed yet (`prompt2d` not run for scd40), so the three
  test-spec observables were treated as environmental.
- **wiring** (esp32c3.yaml primary bus):
  - `esp:5` <-> `chip1:SCL` (green)
  - `esp:4` <-> `chip1:SDA` (green)
  - `esp:3V3.1` <-> `chip1:VDD` (red)
  - `esp:GND.1` <-> `chip1:GND` (black)
  - `esp:3V3.1` <-> `chip1:VDDH` (red) — VDDH must be tied to VDD on PCB
  - `DNC` left unwired (do-not-connect pad)
- `wokwi-cli lint` passes (1 info: undocumented board type, expected).

## Notes / decisions

- The I2C address `0x62` is fixed per spec, so no address attribute is
  exposed — it lives entirely on the bus wiring, not in `attrs`.
- When the `wokwi-customchip` skill (`prompt2d`) produces `attributes.md`,
  this diagram's `attrs` should be re-checked against it per the skill rule
  (only environmental rows).