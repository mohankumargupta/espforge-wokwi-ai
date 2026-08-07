# Feedback — prompt2d (wokwi-customchip) for TMP102

## Summary

Implemented `artifacts/tmp102/prompt2d/chip.zig` — a Wokwi custom chip for the
TMP102 in Zig 0.16 that satisfies the essentials needed by
`test_spec_tmp102.md` (`qa_test/tests/test.rs` asserts "Temperature = 21.0 C"
on the ESPHome serial line). `zig build` emits `chip.wasm`; `zig build test`
passes (7 tests). Deliverables copied to `artifacts/tmp102/outputs`
(`build.zig`, `chip.zig`, `chip.wasm`, `wokwi_api.zig`).

## Conversions reuse (Step 0)

`<conversions_src>` = `artifacts/tmp102/prompt0c/src/root.zig` existed and was
the registered single source of truth (`conversions_manifest.md`). The
register-encoding/decoding helpers in `chip.zig`
(`bytesToWord`, `wordToBytes`, `decodeTempNormal`, `encodeTempNormal`,
`decodeTempExtended`, `encodeTempExtended`, config-field accessors) were ported
to `chip.zig` **verbatim as functions** (no re-derivation). The only deviation
is trivial: `std.math.clamp` was replaced by a local `clamp(i32,i32,i32)` so the
chip's data path stays no_std/freestanding; the arithmetic is identical and the
same worked-example test vectors are asserted in `chip.zig`'s test blocks. No
ambiguity was flagged, so I do not believe re-deriving from text would have been
a problem here, but the port was still used as instructed to avoid the
documented register-table disagreement.

## Assumptions made

1. **I2C address 0x48.** ADD0 is strapped to GND in `diagram.json`; ADD0 variants
   are an excluded feature in the test spec, so the chip listens only at `0x48`.
2. **Temperature source = diagram control.** The ambient value comes from the
   `temperature` control declared in `chip.json` (`attrInit("temperature",
   21.0)` + `attrReadFloat`). Defaults to 21.0 °C per test spec.
3. **16-bit registers, MSB-first, no pointer auto-increment**, matching the
   spec: a write selects a pointer; reads return the byte at the current byte
   index (hi, lo, hi, lo …) of the selected register. A second register
   write stores a 16-bit word (config/low/high).
4. **Small register map**: temp (live, computed), config + TLOW + THIGH reset
   defaults. Extended/alert/oneshot/sd/fault/general-call are intentionally
   minimal or absent, matching the test spec's Excluded Features.
5. No `ALERT` pin logic (excluded); pin is not driven.

## Problems / ambiguities in the skill, suggestions

- **`zig build test` cannot run for a wasm32-freestanding module.** The stock
  `assets/build.zig` defines no `test` step at all, yet the skill mandates
  `zig build test` to pass *and* requires the tests live inside `chip.zig`
  (which is compiled as `wasm32-freestanding`). These requirements are in
  tension: the wasm build can't be executed on host.
  **Resolution:** extended `build.zig` to register a host-native
  `b.addTest(.{...})` target compiling the same `chip.zig`, and gated all
  Wokwi-ABI code (extern fn imports, `chipInit`, callbacks) behind a comptime
  flag `chip_mode = !builtin.is_test`. When the module is compiled for tests the
  ABI code is unreferenced and not emitted, so the conversion functions + their
  `test {}` blocks compile and run on the host; when compiled for the chip the
  flag is true and `chipInit` is exported via `@export`. The wasm `chip.wasm` is
  emitted by the unchanged exe step.
  - Suggestion: make the assets/build.zig provide a [`test`] host step for
    `chip.zig` out of the box, and/or document the `comptime { if (!is_test)
    @export }` pattern so skill users don't re-derive it each time.
- **`@export(&chipInit, …)` requires `callconv(.c)`** on chipInit (Zig 0.16
  error "unable to export type 'fn () void'"); adding `callconv(.c)` fixed it.
  Worth a note in the references.
- The test spec's `zig build test` wording implicitly assumes host-runnable
  tests; if the intended path is "build + a WASM smoke-run only", restate it.

None of these blocked the deliverable; `zig build` and `zig build test` both
complete cleanly.