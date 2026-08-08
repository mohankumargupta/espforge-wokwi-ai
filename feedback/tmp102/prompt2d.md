# Feedback — prompt2d (wokwi-customchip): TMP102

Device: tmp102
Skill: wokwi-customchip
Artifacts: `artifacts/tmp102/prompt2d/{chip.zig,build.zig,wokwi_api.zig,chip.wasm}`,
copied to `artifacts/tmp102/outputs/`.

## Step 0 — conversions reuse

- The `<conversions_src>` pointer (`prompt0c/src/main.zig`) is only the thinnest
  CLI wrapper; the actual conversion functions live in
  `prompt0c/src/root.zig` (the `prompt0c` module root). I treated root.zig +
  `conversions_manifest.md` as the source of truth and ported **verbatim`**
  (`RESOLUTION`, `bytesToWord`/`wordToBytes`, `decodeTempNormal`,
  `encodeTempNormal`, `CONFIG_RESET`, TLOW/THIGH reset words) into `chip.zig`.
  Constants, shift/round/clamp arithmetic and byte order are identical to the
  original.
- **Deviation:** I ported only the normal-12-bit path used by the chip +
  tested essentials. I did **not** port the extended (13-bit) decode/encode or
  the config field-accessor helpers (`configPolarity`, `faultQueueCount`, …)
  because the canonical test spec excludes extended mode and all config
  semantics; leaving them out kept the wasm payload and surface small.
  If downstream the chip must expose EM mode, port the rest verbatim.

## Implementation notes / assumptions

- Scope kept to allow the `test_spec` to pass: I2C slave 0x48, temperature
  observable (default 21.0 C), register map 0x00–0x03, big-endian MSB-first
  16-bit words, pointer register remembering last write, 12-bit left-aligned
  words (bits 15:4), 1 LSB = 0.0625 C. All excluded features are not
  emulated.
- Temperature is read live from the `temperature` diagram attribute (attr*
  control), default 21.0, and re-encoded through `encodeTempNormal` at every
  read (diagram.json already wires `"temperature": "21.0"`).
- Config register: reset `0x60A0`, writes masked through
  `CONFIG_WRITABLE_MASK = 0x9FD0`, preserving read-only R1/R0 (bits 14,13)
  and AL (bit 5) via `CONFIG_READ_ONLY_MASK = 0x6020`. Reserved bits 3:0 always
  0. TLOW/THIGH default `0x4B00`/`0x5000`.
- Multi-byte reads: first two read bytes = MSB/LSB of the selected word;
  extra bytes return 0. Pointer stays until the next write (matches datasheet
  behavioral notes and the ESPHome i2c read sequence: write `0x00`, read 2).
- 16-bit register writes are buffered MSB-then-LSB; TLOW/THIGH are
  R/W, temperature is read-only (writes silently dropped).
- `chip.zig` gates the whole Wokwi ABI (extern imports, `chipInit`, callbacks)
  behind `chip_mode = !builtin.is_test` so `zig build test` (host) links
  clean, while `zig build` (wasm32-freestanding) exports `chipInit` +
  `__wokwi_api_version_1`.

## Validation

- `zig fmt chip.zig` — clean.
- `zig build` — 0 errors (emits `chip.wasm`, WebAssembly MVP).
- `zig build test` — **6/6 pass** (ran the test binary directly too):
  1) 21.0 C → 0x1500 (default observable, with byte-order check);
  2) all spec table vectors decode+encode round-trip;
  3) 12-bit clamp (128 → 0x7FF0, −128.1 → 0x8000);
  4) byte-order helpers; 5) power-up register resets; 6) config write
  preserve read-only bits.

## Obstacles / ambiguities

1. `main.zig` vs `root.zig` indirection for `<conversions_src>` as above.
2. Config read of AL/read-only: with nothing asserted AL=1 preserved via the
   mask; the chip never asserts AL (no alert option), so that bit just follows
   reset.
3. The MCP23017 asset's `I2cConfig` carries `reserved: [8]u32`; I omitted it
   to match the canonical `wokwi_api.zig` `I2CConfig` (no tail). Both byte/
   layout-compatible for the runtime, but noted in case the runtime struct
   grows.
4. Data-conversions ambiguity warning (from `prompt0c.md`) about the raw-N-bit
   count vs left-aligned register word is resolved via the manifest and the
   encode/decode round-trips above; the chip only ever emits encodeTempNormal
   register words, and the test asserts exact word bytes.

## Suggestions

- Consider defining `<conversions_src>` as the module-root file (`root.zig`)
  directly, or documenting that `main.zig` is a wrapper.
- It may be worth pinning which read-only config bits the emulator must
  preserve (R1/R0/AL) so downstream chr (test harness fixtures) and this chip
  agree on a READBACK value after a config write.
- A canonical statement of "register-read behaviour on bytes 3+" (chip returns
  0) would make speculative masters deterministic across skills.