# Skill Feedback: wokwi-customchip (prompt2d)

Device: tmp102

## What went well
- Step-by-step flow with explicit artifacts_dir (`artifacts/tmp102/prompt2d`) and
  a clear copy-to-outputs step worked cleanly.
- `zig fmt chip.zig` and `zig build` validated the chip; the build emitted
  `chip.wasm` with no diagnostics on Zig 0.16.0.
- MCP23017 example and `wokwi_api.zig` were sufficient to implement the I2C
  register model without external resources.

## Problems / ambiguities
1. Reused-register indexing under-documented. The Pointer Register uses only
   P1:P0, but the 16-bit registers are byte-addressed during I2C transfers
   (MSB then LSB). I had to infer the byte-level pointer/increment behaviour.
2. Floating-point attribute API is ambiguous. `wokwi_api.zig` exposes
   `attrInit(name, default_value: f64)` (takes f64) but the C reference
   documents `attr_init(name, uint32)` for ints and a separate float variant.
   I assumed `attrInit("temperature", 21.0)` with `attrReadFloat` is the
   canonical float-attribute path. `attrRead` was declared for the int path.
3. `TEMP_MASK` constant is declared but unused (12-bit conversion via
   `@mod(scaled, 4096)` makes it redundant). Left in for documentation.
4. Default observable temperature: test_spec says default 21.0 °C, so I used
   21.0 as the `temperature` attribute default AND the initial register value.
   This assumption is not explicitly stated in the skill.

## Assumptions
- ADD0 read selects address 0x48 (GND, pulled down) vs 0x49 (high). SDA/SCL
  address pin options (0x4A/0x4B) from the spec are not implemented since the
  canonical test uses 0x48.
- ALERT, high-speed mode, one-shot, extended mode, fault queue, etc. are all
  excluded per the test_spec; not implemented (unused pins left input).
- Resolves address once in `chipInit`; a live ADD0 toggle mid-run is not
  re-resolved (fine for the test).

## Suggestions
- Document the exact byte-order / auto-increment semantics of the register
  file (MSB first, 2 bytes per 16-bit register, pointer wraps at register 3).
- Clarify the intended `attrInit` default-value type (f64 vs u32) and when to
  use `attrReadFloat` vs `attrRead`.
- State a convention for initialising read-ish registers (e.g. Temperature
  register) at power-on when the observable has a default value.