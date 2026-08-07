# Feedback: wokwi-diagramjson skill (prompt2b)

Device: tmp102

## What went well
- Template asset was complete and correct (ESP32-C3 board + chip-chip + serial connections).
- chip.json provided exact custom-chip pin names (SCL, GND, ALERT, ADD0, V+, SDA).
- test_spec confirmed I2C transport and default temperature (21.0 C), which maps cleanly
  to the chip control attr `temperature`.
- esp32c3.yaml gave canonical primary I2C pins (SDA=4, SCL=5) for the I2C bus, avoiding
  any independent pin guessing.

## Obstacles / issues
- The skill references (esp32c3.md) show `IOx` GPIO naming, but `wokwi-cli lint` accepts
  bare GPIO numbers (`4`, `5`) and numbered power pins (`3V3.1`, `GND.1`, `GND.2`) for
  `board-esp32-c3-devkitm-1`. The skill should document the exact pin syntax that passes
  lint (bare GPIO numbers, `3V3.N`, `GND.N`).
- Rule "first two entries MUST ..." is truncated in the SKILL.md; the connections format
  (source, target, color, [wire]) is only fully explained in the references.
- The skill does not state explicitly that unused custom-chip pins (here ALERT, the
  excluded interrupt output) are simply left unconnected.

## Improvements
- Workflow could note mapping control defaults from chip.json (e.g. `temperature: 21.0`)
  into the chip part's `attrs`.
- Document that ADD0 should be tied to GND (default I2C address 0x48) per the spec.