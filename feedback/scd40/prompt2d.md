# prompt2d feedback — SCD40 Wokwi custom chip

## Summary

Built `artifacts/scd40/prompt2d/chip.zig` (Zig 0.16, wasm32-freestanding) for
the SCD40 I2C CO2 sensor, imported the canonical conversions verbatim, and
validated: `zig fmt` clean, `zig build` clean, `zig build test` 15/15 pass.
Produced outputs copied to `artifacts/scd40/outputs/`:
`build.zig`, `chip.zig`, `chip.wasm`, `wokwi_api.zig`.

## Step 0 — conversions reuse

`<conversions_src>` = `artifacts/scd40/prompt0c/src/main.zig` **existed and was
ported as-is** (no adaptation of arithmetic). The ctoRaw/tempFromRaw/tempToRaw/
rhFromRaw/rhToRaw/offset/altitude/pressure/FRC/ASC/serial/dataReady/variant
functions and the `quantize` helper are copied verbatim; only `main()` (host
`std.Io`) was dropped, and the doc comments trimmed. The 16 prompt0c tests were
15-dependent on the chip build (crc vectors, observable decode/encode,
saturation policy, data-ready, variant, serial, temp fuzz) and all pass.
No re-derivation of encoding was performed.

## Step 1 — hardware model (spec / test_spec)

Command-based I2C, fixed address 0x62, big-endian 16-bit words each followed by
CRC-8 (poly 0x31 / init 0xff / verified `crc8Word(0xbeef)==0x92`). Test spec
defaults CO2=500 ppm, T=25.0 C, RH=37.0 %, chip assumed data-ready.

## Step 2 — inputs classified

- **Environmental (attrInit/attrInitFloat, live controls):** `co2`, `temperature`, `humidity`.
- **Fixed/wiring:** I2C address — hard-coded `const 0x62` (SCD40 has no
  address/strap pins). Not an attribute. Recorded in `attributes.md`.

## Decisions & assumptions

1. **Essential command set.** The test spec excludes ASC offload, FRC, factory
   reset, persist_settings, sensor variant/serial identification, and data-ready
   polling. But the ESPHome driver (`scd4x.cpp`) unconditionally sends at boot:
   `stop_periodic_measurement`, `get_serial_number`, `set_temperature_offset`,
   `set_sensor_altitude`, `set_asc_enabled`, `start_periodic_measurement`; and
   per update: `get_data_ready_status`, `read_measurement`. All of these must be
   ACKed or ESPHome `mark_failed()`s. Therefore the chip implements the full
   boot/measure loop (all of the above, plus harmless getters) — not just the
   three read_measurement words. Assumed: ESPHome setup is a hard dependency for
   the canonical test to even reach a measurement.
2. **Data-ready = always ready.** Spec/test-spec say the chip is assumed ready
   and data-ready polling is excluded, so `get_data_ready_status` returns a
   fixed `0x0001`. No timer/5 s periodicity simulation; this keeps the test
   deterministic and matches the canonical presentation (a slider move is
   observed on the next read_measurement).
3. **Write-side CRC not validated.** The write direction carries mandatory CRC;
   ESPHome always sends a valid one, so the chip consumes and discards the CRC
   byte and commits the data word regardless. No NACK-on-bad-CRC path.
4. **Serial number = datasheet example** (`0xf896/0x9f07/0x3bbe`,
   273,325,796,834,238) so `get_serial_number` returns the spec's worked words.
5. **get_sensor_variant returns 0x0440** (bits 15:12 = 0 → SCD40). Unused by
   this ESPHome version but trivially correct.
6. **Config writes are volatile RAM-only** (persist_settings excluded): all
   settings reset on chipInit. Matches datasheet (EEPROM only on persist).
7. **Temp/RH words may differ from datasheet raw by one count.** `tempToRaw(25.0)`
   = 26214 vs datasheet 0x6667 (26215); `rhToRaw(37.0)` = 24248 vs 0x5eb9
   (24249) — the conversions manifest explicitly blesses this (round-to-nearest,
   datasheet words chosen for display). ESPHome's decode uses /65536, still
   rounding both to 25.00 / 37.00 at 2 decimals. `apms` ack: tests assert
   decode-side against datasheet words and encode within one count.
8. **Single global state** (MCP23017 pattern) — one chip instance per wasm.
9. **No timers, no pin watches, no debugPrint** — excluded features need none.
10. **`export` gated via `const chip_mode = !builtin.is_test` + `@export(&chipInit)`,**
    per assets/build.zig comment, so host `zig build test` links cleanly.

## Problems / ambiguities

- **Wokwi WASM import naming.** The assets `wokwi_api.zig` is a C-header-derived
  binding; this skill's own MCP23017 example uses camelCase extern names. I
  verified against `https://wokwi.com/api/chips/wokwi-api.h` that the *WASM*
  import names really are camelCase (`attrInit`, `attrInitFloat`, `attrRead`,
  `attrReadFloat`, `i2cInit`, `pinInit`), so camelCase externs are correct. The
  skill could note this explicitly to prevent future churn.
- **CRC mandatory in write direction** — chips that implement strict CRC
  validation would NACK bad writes; this skill does not specify write-side
  policy. Documented assumption #3.
- **Input pin mode for SCL/SDA** — i2c.md shows INPUT_PULLUP, MCP23017 example
  uses plain INPUT. Followed the example (INPUT).

## Suggestions for the skill

- Add a worked I2C command-based (non-register) example alongside MCP23017 —
  the "command then separate read transaction + CRC per word" pattern is very
  different from register-file chips and wasn't covered by any existing asset.
- Explicitly state the Wokwi WASM import-name convention (camelCase) and that
  `attr_init_float`'s default is C `float` (use `f32` in the Zig extern).
- Consider documenting an attribute-ABI invariant: float env observables should
  use `attrInitFloat`/`attrReadFloat` (f32), not packed u32, so fractional
  sliders round-trip exactly.