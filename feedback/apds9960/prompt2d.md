# prompt2d — wokwi-customchip for APDS9960

## Summary

Created a Wokwi custom chip for the Avago/Broadcom APDS-9960
(gesture / proximity / RGBC ambient-light sensor, I2C `0x39`) in Zig 0.16
(wasm32-freestanding, no_std) at `artifacts/apds9960/prompt2d/chip.zig`.

Validation: `zig fmt` → `zig build` → `zig build test` all pass
(10/10 tests). `chip.wasm` exports `chipInit` and imports only
`attrInit` / `attrReadFloat` / `pinInit` / `i2cInit` from `env`.
Deliverables copied to `artifacts/apds9960/outputs/`:
`build.zig`, `chip.zig`, `chip.wasm`, `wokwi_api.zig`.

## conversions_src reuse (Step 0) — REUSED AS-IS

`artifacts/apds9960/prompt0c/src/main.zig` existed and was used as the single
source of truth. All register-encoding functions were ported **verbatim**:
`rgbcFromBytes`/`rgbcToBytes`, `rgbcPercentFromCount`/`rgbcCountFromPercent`,
`proxPercentFromCount`/`proxCountFromPercent`, `atimeTo*`, `wtimeTo*`,
`offsetFromByte`/`offsetToByte`, `pulseCount`, `pulseLengthUs`,
`proximityResultTimeMs`. No re-derivation from the datasheet text.

- The ATIME `CountMAX` discrepancy (`1024*CYCLES+1` vs the inline
  `1025*CYCLES`) and the tCNVT discrepancy (796.6 vs 696.6 us) were already
  resolved in prompt0c and carried through unchanged.
- Only adaptation was the no_std/wasm context: the functions already used only
  `std.math` (isNan/clamp/round), which compiles fine for wasm32-freestanding.
- Tests were ported too, including the canonical-default → exact-register-bytes
  assertions (clear 20.0→0x3333, red 15.0→0x2666, green 12.0→0x1EB8,
  blue 9.0→0x170A, proximity 7.1→0x12).

## What the chip implements (essentials for test_spec)

- Full 256-byte register file with power-on reset values; read-only data
  registers and `ID=0xAB`; writeable config registers.
- I2C at the fixed factory address `0x39` (NACKs any other address).
- STATUS (0x93) computed on read: AVALID while AEN set, PVALID while PEN set.
- RGBC pairs (0x94–0x9B, Little-Endian) and PDATA (0x9C) derived from the five
  live percent attributes.
- Sequential I2C pointer auto-increment after every byte so ESPHome's
  `read_bytes(0x94, raw, 8)` block read streams the eight RGBC bytes.

## Step 3a input classification

- **Environmental (attrInit/attrReadFloat, chip.json range controls):**
  `clear` (20.0), `red` (15.0), `green` (12.0), `blue` (9.0), `proximity`
  (7.1). Re-read on every data-register access so a live slider change is
  observed on the next read.
- **Fixed/wiring:** I2C address — hard-coded `const I2C_ADDR = 0x39`; the
  APDS9960 has no address-strap pin (factory-fixed, single address). Not an
  attribute; documented in `attributes.md` so diagram generation won't invent
  an `attrs` entry for it.

`attributes.md` written to `artifacts/apds9960/prompt2d/attributes.md` and
documents the decimal-only Wokwi literal-format caveat for the five float
attributes.

## Notes / assumptions

- **Wokwi ABI shape:** followed the MCP23017 example's inline typed-function-
  pointer `I2cConfig` (not `wokwi_api.zig`'s `?*anyopaque` callback fields),
  to avoid `@ptrCast` gymnastics on function pointers. The skill's
  `wokwi_api.zig` was still copied to artifacts/outputs as instructed.
- **attrInit signature:** used `default_value: f64` + `attrReadFloat` (per
  `wokwi_api.zig`) rather than the MCP23017 example's `u32` + `attrRead`,
  since the observables are floats.
- **build.zig gating:** followed build.zig's documented
  `comptime { if (chip_mode) @export(&chipInit, ...) }` pattern (not the
  MCP23017 `export fn` style), which is what lets the same file build both
  wasm chip and host test executable.
- **STATUS modeling:** AVALID/PVALID recomputed fresh on each read (always
  "ready" under the test spec's ideal_conditions) rather than modeling the
  datasheet's auto-clear-on-read latch. A strict latch that never re-asserts
  would break the periodic `update()` re-reads, and a conversion-complete
  timer is beyond "essentials". Documented as a fidelity simplification.
- **Sequential access:** auto-increment every byte on both read and write.
  The real APDS9960 gates increment on the command byte's AINC bit and, for
  gesture reads, wraps within 0xFC–0xFF; neither matters for the canonical
  test path (block read of 0x94 and single-byte writes), and the per-byte
  increment is the pattern that makes ESPHome's block reads work.
- **First write byte** after slave address is treated as the full 8-bit
  register address (matches ESPHome's `write_byte(reg, val)` protocol).
- **INT / LDR / LEDK / LEDA / GND / VDD:** INT is init'ed as a released
  (input, open-drain) pin; interrupt outputs/clears are excluded by the test
  spec. LDR/LEDK/LEDA/GND/VDD are not init'ed (no logic needed).

## Ambiguities / suggestions

1. The skill's Step 2 references `wokwi_api.zig` but the MCP23017 example
   doesn't import it (defines types inline), and build.zig doesn't reference
   it either. Clarify whether chip.zig is expected to `@import("wokwi_api.zig")`
   or whether it's a reference-only artifact — I treated it as reference-only.
2. `attrInit`'s default type differs between `wokwi_api.zig` (`f64`) and the
   MCP23017 example (`u32`). A note that float-attribute chips should use the
   `f64`/`attrReadFloat` form would remove the guess.
3. The chip.json control `id` ↔ attribute `name` coupling is assumed
   (control `clear` → attr `"clear"`). The chip-diagram skill should be told
   to keep control ids exactly equal to the environmental attribute names in
   `attributes.md`; I used the prompt2a ids, which match.
4. STATUS auto-clear vs always-ready: the skill might note that under
   ideal_conditions (AVALID/PVALID expected on every read) a recompute-on-read
   model is acceptable for the numeric smoke test.
