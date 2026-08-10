# Feedback: wokwi-customchip (prompt2d) — TMP102

## Summary

Zig 0.16 Wokwi custom chip created at `artifacts/tmp102/prompt2d/chip.zig`,
validated with `zig build` (chip.wasm builds for wasm32-freestanding) and
`zig build test` — **15/15 tests pass, zero failures**. Deliverables
(`build.zig`, `chip.zig`, `chip.wasm`, `wokwi_api.zig`) copied to
`artifacts/tmp102/outputs/`.

Behaviour (essentials to satisfy test_spec_tmp102.md):
- I²C slave whose address is derived from the `ADD0` strap pin
  (`pinInit("ADD0", input_pulldown)`; grounded 0x48, tied to V+ 0x49).
  The canonical `temperature` attr is read live on every register read.
- Register set: 0x00 Temperature (read-only, live from attr), 0x01 Config
  (reset 0x60A0, R/W), 0x02 TLOW (0x4B00), 0x03 THIGH (0x5000).
- Pointer register latched and remembered until changed (spec quirk);
  reads emit MSB first (big-endian); 16-bit R/W writes assembled byte-wise.
- ALERT pin exists but stays released/high-Z (excluded from canonical test).

## Step 0 — conversions reuse

`conversions_src` (`artifacts/tmp102/prompt0c/src/root.zig`) was reused
**as-is**: all register-encoding functions (encode/decode Normal+Extended,
sign extension, byte order, fault queue, conversion rate, Config packing,
`slaveAddress`) were ported **verbatim** into `chip.zig`, with only the
Wokwi-ABI parts gated behind `chip_mode = !builtin.is_test`. No re-derivation.
The `test_spec` default (+25 C -> word `0x1900` -> raw 0x190 -> 400 * 0.0625)
is asserted in its own test against the ported `encodeTempNormal`.

## Verified

- `zig fmt chip.zig` OK.
- `zig build` OK (wasm32-freestanding, ReleaseSmall, chip.wasm emitted).
- `zig build test --summary all`: `15/15 tests passed`.

## Observations / assumptions

1. **`chip_mode` gating + `@export` was necessary and works.** The skill's
   build.zig guidance to gate wasm ABI code behind `!builtin.is_test` was
   exact; `export fn chipInit` would otherwise break the host test link.
   The MCP23017 reference does not contain tests, so `chip_mode` is missing
   there — the build.zig comment block is the real spec for this, and it
   worked first try.

2. **`__wokwi_api_version_1` export had to be added to `chip.zig`.** Neither
   `build.zig` (root_source_file = chip.zig only) nor the MCP23017 example
   provide the required Wokwi version symbol; the skill's `wokwi_api.zig`
   does, but nothing compiles it unless chip.zig `@import`s it. I added the
   `export fn __wokwi_api_version_1()` inline (returns 1) so chip.wasm is
   loadable without coupling chip.zig to wokwi_api.zig's ABI struct shapes.
   Recommend the skill state this explicitly.

3. **`wokwi_api.zig`'s `I2CConfig` callbacks are typed `?*anyopaque`, which
   cannot accept function-pointer literals.** I followed the MCP23017
   reference instead (typed `*const fn ... callconv(.c)` fields + trailing
   `reserved: [8]u32`). The wokwi_api.zig struct as-written is not directly
   usable with `i2cInit` in Zig; flagging so the skill knows its API file and
   its worked example disagree on struct shape.

4. **`attrInit` f64 signature:** wokwi_api.zig declares
   `attrInit(name, default_value: f64)`, which I reused verbatim for the
   temperature attribute (default 25.0). Note the C reference API splits this
   into `attr_init` (u32) / `attr_init_float` (float); if the host export
   names differ, this file must be regenerated — but since it's the skill's
   canonical asset I trusted it.

5. **ADD0 4-state vs 2-state:** datasheet Table 6-4 maps ADD0 to GND/V+/SDA/
   SCL (four addresses). A digital `pinRead` only distinguishes two; I model
   GND (0x48, canonical) and V+ (0x49) and document the SDA/SCL tie options
   as unsupported. test_spec only needs 0x48. Documented in attributes.md:
   `address` is fixed wiring derived from `ADD0`, never an attr/control.

6. **`chip.json`/`diagram.json` already existed** (produced by prompt2a) and
   are consistent with this chip: pins SCL/GND/ALERT/ADD0/V+/SDA, one
   `temperature` range control, ADD0 grounded in diagram.json. No changes
   needed; chip.zig matches them (control id `temperature` ↔ attr name). Did
   not regenerate or modify them.

7. **First-conversion latency (26–35 ms) deliberately not modelled.** The
   test spec's assumptions state the first conversion is complete before the
   temperature register is read; the chip returns the live attr immediately.

## Suggestions

- State that `chip.zig` should either `@import("wokwi_api")` or own the
  `__wokwi_api_version_1` export (currently implicit across skills).
- Provide the `I2CConfig` Zig struct aligned with what the example `chip.zig`
  actually uses (typed fn pointers + `reserved`), or fix `wokwi_api.zig`.