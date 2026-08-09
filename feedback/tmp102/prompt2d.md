# Feedback: prompt2d (wokwi-customchip) for tmp102

## Summary

Generated a Wokwi custom chip (`chip.zig`, Zig 0.16, wasm32-freestanding) for
the TMP102 I2C temperature sensor, implementing only the essentials needed to
support the canonical test spec (temperature read path). `zig build` produces
`chip.wasm`; `zig build test` passes 13/13 host-side unit tests.

## Inputs used

- `<spec>` = `artifacts/tmp102/outputs/spec_tmp102.md`
- `<test_spec>` = `artifacts/tmp102/outputs/test_spec_tmp102.md`
- `<conversions_src>` = `artifacts/tmp102/prompt0c/src/main.zig`
- `<conversions_manifest>` = `artifacts/tmp102/prompt0c/conversions_manifest.md`
- skill assets: `assets/build.zig`, `assets/wokwi_api.zig`,
  `assets/wokwi-mcp23017/chip.zig`, `references/chips-api/{i2c,attributes,
  chip-json,getting-started}.md`
- `artifacts/tmp102/prompt2a/chip.json`, `outputs/{diagram.json,tmp102.yaml,
  wokwi.toml}`, `outputs/tmp102/tmp102.cpp` (ESPHome driver I2C sequence)

## Step 0: conversions reuse (as-is)

`<conversions_src>` was reused **as-is** — every encode/decode helper
(`signExtend`, `count12FromWord`, `count12ToWord`, `temperatureCFromWord`,
`temperatureCToRegisterWord12`, `bytesToWord`, `wordToBytes`,
`temperatureCFromBytes`, `temperatureCFromMsbByteOnly`, extended-mode and
auto-detect variants) was ported verbatim, changing only syntax (no logic
changes). The unit tests were ported 1:1 from the same source and pass
unchanged, confirming the encoding was not re-derived (the datasheet register
map / bit-field disagreement documented in `feedback/tmp102/prompt0c.md` was
not re-encountered).

## Design decisions / assumptions

1. **Temperature source = `temperature` attribute (float), default 21.0 C.**
   The canonical observable default is 21.0; the harness `diagram.json` does
   not set it, so the chip defaults to 21.0 -> register word `0x1500` ->
   bus bytes `[0x15, 0x00]` -> `Temperature = 21.0 C`. The attribute is
   re-read on every temperature-register read so a Wokwi range control
   updates the value live.
2. **I2C address = `address` attribute, default 0x48.** The harness
   `diagram.json` sets `"address": "0x48"`; the chip filters in
   `onI2cConnect` and NACKs everything else (pattern from MCP23017 with
   `i2cInit` address=0). ADD0 is initialized as an input but NOT used to
   resolve the address — with the address attr authoritative, ADD0 wiring
   is moot for the canonical test. Flagging: if a future harness relies on
   hardware ADD0 wiring without an `address` attr, this chip would still use
   the 0x48 default.
3. **Pointer does not auto-increment** (datasheet quirk). A 2-byte read
   returns MSB then LSB of the selected register (via `read_index`), then
   wraps for extra bytes. `has_reg_ptr` is reset on write-connect/disconnect
   so the first byte of any write transaction is the pointer, while the
   current pointer value persists between transactions (EspHome: write
   pointer `0x00`, then read 2 bytes -> works).
4. **Excluded features not implemented** (per test spec): ALERT behaviour,
   TLOW/THIGH thresholds (registers exist with documented defaults `0x4B00`/
   `0x5000` and are R/W, but no alert logic), config `0x60A0` present with
   basic two-byte R/W, shutdown/one-shot/EM/conversion-rate ignored. The
   ESPHome driver only writes the pointer and reads 2 bytes, so these are
   not exercised.
5. **No first-conversion delay.** Spec/test-spec assume conversion complete
   at first read (10 ms power-up window is a real-device behaviour the
   harness deliberately abstracts away), so the temperature register returns
   the encoded value immediately.
6. **`chip_mode` gating** per `build.zig`'s documented pattern
   (`!builtin.is_test` gating the `@export` of `chipInit`) so the same file
   compiles for host `zig build test` without unresolved wasm imports. The
   extern ABI declarations (camelCase names, `attrInit(name, f64)`,
   `attrReadFloat`) follow the skill's `wokwi_api.zig` asset.

## Validation

- `zig fmt chip.zig` -> no changes.
- `zig build` -> wasm build succeeds; `chip.wasm` emitted (572 KB).
- `zig build test --summary all` -> 13/13 tests pass.
- Key test: "default observable: 21.0 C encodes to 0x1500" asserts
  `temperatureCToRegisterWord12(21.0) == 0x1500`, matching the canonical
  observable default.

## Obstacles / observations

- The skill's file list says `wokwi-api.zig` but the asset is
  `wokwi_api.zig`; I copied/kept the underscore name in both the artifacts
  dir and the outputs dir.
- `attrInit`'s signature differs between the C reference (`attr_init`/u32)
  and the Zig asset (`attrInit(name, f64)` + `attrReadFloat`); I followed
  the Zig asset since chip.zig declares its own externs and must match the
  import names the host actually provides.
- The `controls` range in `prompt2a/chip.json` (-40..125, step 0.0625) is a
  UI nicety; the chip itself only exposes attributes, so control changes
  flow through the `temperature` attribute (design choice above).
- No simulator run was performed; correctness is established by the ported
  unit tests, not by a live Wokwi execution.

## Suggestions

- State explicitly in the skill whether ADD0 (hardware address select) or the
  `address` attribute is authoritative; recommend the attribute when the
  harness `diagram.json` supplies it.
- Clarify the output filename (`wokwi-api.zig` vs `wokwi_api.zig`) in the
  "copy files" step.
