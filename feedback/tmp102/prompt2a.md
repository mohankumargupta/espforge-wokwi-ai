# prompt2a — wokwi chip.json + diagram.json for TMP102

## Status
PASS

## Inputs
- `<test_spec>`: `artifacts/tmp102/outputs/test_spec_tmp102.md`
- `<spec>`: `artifacts/tmp102/outputs/spec_tmp102.md`
- Template: `wokwi-chip-diagram/assets/diagram.json`, `assets/esp32c3.yaml`

## Outputs
- `artifacts/tmp102/prompt2a/chip.json` (schema-validated with `check-jsonschema`)
- `artifacts/tmp102/outputs/chip.json`
- `artifacts/tmp102/outputs/diagram.json` (passes `wokwi-cli lint`)

## Decisions
- **Pins** (from spec physical pin table, in pin-number order SCL GND ALERT ADD0 V+ SDA):
  V+, GND, SDA, SCL wired to MCU; ADD0/ALERT kept as spec pins but unconnected
  (address fixed at 0x48; ALERT behavior excluded by test spec).
- **Controls**: single `range` control `temperature` (-40..125 °C, step 0.0625 = LSB).
  Matches test spec observable `temperature` (float, C, default 21.0).
- **Diagram**: kept template MCU + custom chip + serial monitor connections;
  added `attrs: { "address": "0x48" }` to `chip1`; wired per `esp32c3.yaml`
  primary I2C bus SDA=4, SCL=5, power 3V3.1 / GND.1.
- **Wire colors**: red=V+ (3V3.1), black=GND (GND.1), green=SDA (4), blue=SCL (5).

## Validation
- `check-jsonschema --schemafile prompt2a/chip.schema.json prompt2a/chip.json` → ok
- `wokwi-cli lint` (in outputs/) → 1 info (undocumented `board-esp32-c3-devkitm-1`
  part type, template-inherited); no errors/warnings.