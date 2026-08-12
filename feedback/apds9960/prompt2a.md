# prompt2a — wokwi-chip-diagram for APDS9960

## Summary

Generated Wokwi custom-chip scaffolding for the Avago/Broadcom APDS-9960
(gesture / proximity / RGBC ambient-light sensor, I2C address `0x39`) from
`test_spec_apds9960.md`.

Outputs:
- `artifacts/apds9960/prompt2a/chip.json` (+ copied to `outputs/chip.json`)
- `artifacts/apds9960/outputs/diagram.json`

## chip.json

- **pins**: `SDA`, `INT`, `LDR`, `LEDK`, `LEDA`, `GND`, `SCL`, `VDD` — all 8
  pins from the datasheet pin table in `spec_apds9960.md`, in datasheet order,
  pin 1 first.
- **controls**: one range control per canonical observable (all environmental):
  - `clear` — min 0, max 100 %, step 0.1
  - `red` — min 0, max 100 %, step 0.1
  - `green` — min 0, max 100 %, step 0.1
  - `blue` — min 0, max 100 %, step 0.1
  - `proximity` — min 0, max 100 %, step 0.1
- Validated against `chip.schema.json` with `check-jsonschema` (ok).

## diagram.json

Built from the skill template (kept serial monitor + board + chip parts).

- **attrs** on `chip1` (plain decimal, the test-spec canonical `default` %
  values): `clear: "20.0"`, `red: "15.0"`, `green: "12.0"`, `blue: "9.0"`,
  `proximity: "7.1"`.
  No `attributes.md` existed yet (`prompt2d` not run for apds9960), so the five
  test-spec observables were treated as environmental.
- **wiring** (esp32c3.yaml primary bus):
  - `esp:5` <-> `chip1:SCL` (green)
  - `esp:4` <-> `chip1:SDA` (green)
  - `esp:3V3.1` <-> `chip1:VDD` (red)
  - `esp:GND.1` <-> `chip1:GND` (black)
- `INT`, `LDR`, `LEDK`, `LEDA` left unwired: interrupts and LED-drive /
  proximity-LED circuit are excluded by the test spec (Excluded Features).
- `wokwi-cli lint` passes (1 info: undocumented board type, expected from the
  template).

## Notes / decisions

- The I2C address `0x39` is factory-fixed per spec (no ADD0-style strap pin),
  so no address attribute or strap wiring exists — it lives entirely on the
  chip.
- When the `wokwi-customchip` skill (`prompt2d`) produces `attributes.md`, this
  diagram's `attrs` should be re-checked against it per the skill rule (only
  environmental rows).
