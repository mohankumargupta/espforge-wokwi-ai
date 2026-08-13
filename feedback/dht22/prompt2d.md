# prompt2d — wokwi-customchip for DHT22

## Summary

Created a Wokwi custom chip for the Aosong DHT22 / AM2302
(digital temperature / relative-humidity sensor, proprietary single-bus
`DATA` line) in Zig 0.16 (wasm32-freestanding, no_std) at
`artifacts/dht22/prompt2d/chip.zig`.

This is the first single-wire (non-I²C/SPI/UART) chip in the pipeline, so it
implements the actual wire protocol, not a register file: a `pinWatch`
(BOTH edges) + one-shot timer state machine that answers ESPHome's start
pulse with the 80 µs low + 80 µs high response preamble and a 40-bit frame
(MSB first, LOW 50 µs + HIGH 70 µs for "1" / 28 µs for "0" per bit).

Validation: `zig fmt` → `zig build` → `zig build test` all pass
(12/12 tests). `chip.wasm` exports `chipInit`; imports from `env` only
`attrInit`, `attrReadFloat`, `pinInit`, `pinWatch`, `pinMode`, `pinWrite`,
`timerInit`, `timerStart`, `getSimNanos`. Deliverables copied to
`artifacts/dht22/outputs/`: `build.zig`, `chip.zig`, `chip.wasm`,
`wokwi_api.zig`. `attributes.md` written to `prompt2d/`.

## conversions_src reuse (Step 0) — REUSED AS-IS

`artifacts/dht22/prompt0c/src/main.zig` existed and was used as the single
source of truth. All frame-encoding functions were ported **verbatim**:
`Frame`/`Reading`, `humidityWord`/`humidityDecode`/`humidityEncode`,
`temperatureWord`/`temperatureDecodeRaw`/`temperatureDecode`/
`temperatureEncode`, `checksum`/`checksumValid`, `decode`/`encode`. No
re-derivation from the datasheet text. The spec-table discrepancy already
recorded in prompt0c (raw `0x8000` labelled −10.0 °C but decoding to +0.0 per
its own formula) was carried through unchanged. All 11 prompt0c tests were
ported, plus a new canonical-frame test that asserts `encode(50.4, 25.0)`
produces exactly `0x01 0xF8 0x00 0xFA 0xF3` (test_spec_dht22.md) and an
MSB-first bit-serialization test over `currentBit()`.

## What the chip implements (essentials for test_spec)

- `DATA` pin initialized `input_pullup` (idle bus held high; no external
  pull-up resistor in the diagram).
- Start-signal detection: falling edge records `getSimNanos()`, rising edge
  starts the response only if the low phase was ≥ ~1 ms (`START_MIN_LOW_US
  = 900`), so a short glitch is ignored and ESPHome's exact 1000 µs pulse is
  accepted.
- Response sequence driven by a re-armed one-shot timer: LOW 80 µs → HIGH
  80 µs (release) → per-bit LOW 50 µs + HIGH 70/28 µs → release to idle.
- The 40-bit frame is rebuilt from `attrReadFloat` on every start signal, so
  a live `chip.json` slider change is seen on the next read.
- On a repeated read (`update_interval: 60s` in `dht22.yaml`) the state
  machine returns to `.idle` and answers again — no "first read only" latch.

## Step 3a input classification

- **Environmental (attrInit/attrReadFloat, chip.json range controls):**
  `temperature` (25.0), `humidity` (50.4). Re-read on every start signal.
  `chip.json` already exposes both as range controls (ids `temperature`,
  `humidity`), matching the attribute names.
- **Fixed/wiring:** none configurable — the DHT22 has no address-strap or
  mode pins (one sensor per DATA line, no addressing). The DATA pull-up and
  the start/bit timings are wire-protocol constants in chip.zig, documented
  under "Fixed / wiring parameters — NOT attributes" in `attributes.md` so
  diagram generation won't invent `attrs` entries for them.

## Notes / assumptions

- **Open-drain modeling:** LOW phases are `OUTPUT` + `pinWrite(LOW)`; HIGH
  phases release to `INPUT_PULLUP` (internal pull-up holds the line high), the
  same open-drain behaviour as the real DHT22. This relies on Wokwi's custom-
  chip `INPUT_PULLUP` actually sourcing the line — not verifiable outside the
  simulator. Fallback if it doesn't: drive HIGH as `OUTPUT` + `pinWrite(HIGH)`
  (safe, because the ESP32 GPIO3 is high-Z during the whole read).
- **Ignoring self-driven edges:** Wokwi delivers the chip's own pin writes back
  through `pinWatch`; `onDataChange` ignores all edges unless the state machine
  is `.idle`/`.start_wait`, so the response sequence can't be corrupted by its
  own edges.
- **Timing margin vs ESPHome (`dht.cpp`):** response LOW 80 µs ends before the
  driver's `delayMicroseconds(70)` + first "wait for rising edge" (max 90 µs);
  per-bit 50 µs low / ≤ 70 µs high fit the 90 µs rising/falling timeouts;
  bit-high 28 µs (< 40 µs) is read as "0", 70 µs (≥ 40 µs) as "1". Pages 96–9
  of this skill's own timing references were not available; reused the
  datasheet timings from `spec_dht22.md`.
- **attrInit signature:** used `default_value: f64` + `attrReadFloat`
  (per `wokwi_api.zig` and the apds9960 chip), since both observables are
  floats.
- **build.zig gating:** followed the documented
  `comptime { if (chip_mode) @export(&chipInit, ...) }` pattern (chip_mode =
  `!builtin.is_test`), which is what lets the same file build the wasm chip and
  the host test executable. `wokwi_api.zig` was copied to artifacts/outputs as
  instructed but not `@import`ed (chip.zig mirrors its types inline, like
  MCP23017/apds9960) to avoid duplicate-import signature conflicts.
- **VDD / NULL / GND:** power pins only, not initialized in code (no logic
  needed); `chip.json` already declares them; no change to chip.json was needed
  and none was made.

## Ambiguities / suggestions

1. This skill is the first to exercise the **timer + pinWatch** path — the
   MCP23017/apds9960 examples are register/I²C-only. The single-wire response
   timing cannot be verified to the µs without a simulator run; a worked
   timing table calibrated against `dht.cpp`'s `40µs`/`90µs` thresholds (or a
   note to run the Logic Analyzer) would make the timing constants auditable.
2. Same cross-skill note as apds9960: whether chip.zig is expected to
   `@import("wokwi_api.zig")` or treat it as reference-only remains ambiguous;
   I treated it as reference-only (established by prior devices).
3. `attrInit`'s default type differs between `wokwi_api.zig` (`f64`) and the
   MCP23017 example (`u32`); I used `f64` + `attrReadFloat` for the two float
   observables (matches apds9960).
4. Whether Wokwi's custom-chip `INPUT_PULLUP` sources the DATA line needs
   runtime confirmation (see Notes). Suggest documenting the pull-up mechanism
   in the skill or adding a pull-up resistor to the reference diagram instead.