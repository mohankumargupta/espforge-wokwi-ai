# Skill feedback — wokwi-diagramjson (device: tmp102)

## Outcome
- `artifacts/tmp102/outputs/diagram.json` created and validated with `wokwi-cli lint` (exit 0).
  Only an informational "unsupported-part" note for `board-esp32-c3-devkitm-1` (expected, part type is well-known).

## Wiring decisions (traceability)
- TMP102 is an I2C device per test spec (`transport: I2C`, address `0x48` from `sensor.py`).
- Pins from canonical board profile `esp32c3.yaml`: primary `i2c1` → SDA=`4`, SCL=`5`.
  Used primary bus (not secondary/strapping) since only one I2C device is present.
- Power: `V+` → `esp:3V3.1` (red, VCC), `GND` → `esp:GND.1` (black).
- Data: `SDA`→`esp:4`, `SCL`→`esp:5` (green).
- `ADD0` tied to `esp:GND.1` (black) to lock the default address `0x48` deterministically.
- `ALERT` left unconnected — alert/interrupt is an explicitly excluded feature in the test spec.
- Kept the template's `$serialMonitor` RX/TX connections and the `chip-chip` custom chip.

## Tips / improvements for the skill author
1. **Pin naming target unclear**: The skill says "Wokwi custom chip pin names can come from
   <chip_json>", but it is not stated explicitly that diagram.json connections reference a chip's
   pins BY LABEL (e.g. `chip1:V+`, `chip1:SDA`), not by physical position letter (A1/B1…). I
   confirmed via wokwi docs that for custom chips the pins array defines connection pin names.
   Consider stating this rule in the skill so future runs don't hesitate.
2. **`V+` pin label**: chip.json uses `V+` (contains `+`). I verified `wokwi-cli lint` accepts
   `chip1:V+` as a pin reference. Worth noting that literal pin labels are used verbatim.
3. **ADD0 grounding**: The skill doesn't say whether to tie address/strapping pins. I tied
   `ADD0` to GND to match address `0x48`. The skill could document a convention for
   address-select pins (tie active-low select to GND / default address).
4. **attrs = {}**: The chip.json for TMP102 carries no `attrs`, only `controls` (a range slider).
   The skill's "add attrs from existing chip" only applies when the chip.json actually defines
   `attrs`; here none existed, so `attrs: {}` was kept. Good to note: `controls` are interactive
   UI and don't belong in diagram.json `attrs`.