# Skill Feedback: data-conversions-complex-logic — TMP102 (prompt0c)

Artifact dir: `artifacts/tmp102/prompt0c`
Zig version used: 0.16.0
Spec: `artifacts/tmp102/outputs/spec_tmp102.md`
Result: `zig build test` -> 13/13 pass; `zig build` OK.

## What was implemented

Data conversions:
- `raw12ToCelsius` / `raw13ToCelsius` (two's-complement raw -> °C, LSB = 0.0625 °C)
- `celsiusToRaw12` / `celsiusToRaw13` (reverse, nearest-LSB rounding)
- `registerToCelsius` (16-bit register -> °C, auto-detects 12-bit vs 13-bit extended
  from bit D0 of byte 2 = EM indicator)
- `celsiusToRegister12` / `celsiusToRegister13` (encodes into the register layout,
  incl. setting the EM indicator bit in extended mode)
- Integer millidegree reference (`registerToMilliC12/13`, `milliCToRaw12/13`) as an
  exact cross-check of the float path

Complex logic / reference algorithms:
- `i2cAddress` (ADD0 pin -> device address, Table 6-4)
- `decodePointer` (P1:P0 pointer register)
- `Config.decode/encode` (all configuration bit fields incl. OS/R/F/POL/TM/SD/CR/AL/EM)
- `conversionRateHz`, `faultQueueCount`, `resolutionBits`
- `AlertTracker` (comparator + interrupt thermostat state machine with fault queue,
  hysteresis via TLOW, interrupt latch cleared on temperature-register read, re-arm)

Unit tests cover every spec conversion example (50, 25, 0.25, -25, -0.25 °C),
reset register values (TLOW = 0x4B00 = 75 °C, THIGH = 0x5000 = 80 °C), config reset,
and both thermostat modes with 1- and 4-sample fault queues.

## Obstacles / notes for the skill author

1. **Spec inconsistency on config reset value.** The register-map table says config
   reset = `0x6180`, but the bit-field tables give Byte 1 reset = `0x60` and Byte 2
   reset = `0x80`, and the init sequence claims continuous-conversion at 4 Hz.
   `0x6180` has the SD (shutdown) bit set and CR = 1 Hz, which contradicts both the
   bit-field table and the datasheet (Byte 1 reset = `0110 0000`, i.e. SD = 0).
   Verified against TI datasheet (SBOS397) and the Linux `drivers/hwmon/tmp102.c`
   bit definitions. Implemented reset as `0x6080`. The spec's register-map `0x6180`
   should be corrected to `0x6080`.

2. **Zig 0.16 API gotchas** (not spec issues):
   - `zig init` now creates a library module + executable + separate root.zig module
     with fuzz/allocator tests and `std.Io`-style `main`. I simplified `build.zig` to
     a single executable + test step and deleted `src/root.zig`; otherwise the extra
     module pulls in unrelated smoke tests.
   - `@bitCast` requires equal bit widths: widen `i12`/`i13` to `u12`/`u13` first,
     then `@as(u16, ...)` before shifting.
   - `0x48 + @intFromEnum(add0)` fails to compile (result typed as `u2`); use
     `0x48 + @as(u8, @intFromEnum(add0))`.
   - `@intCast` from `f32` must go through `@intFromFloat(@round(...))` for rounding.

3. **Naming conflict:** the temp-register bit that distinguishes formats is called
   "EM indicator" (bit D0 of byte 2) and the configuration register also has an EM
   (Extended Mode) bit (bit 4 of byte 2). The two are related (register bit mirrors
   config EM) but distinct; worth disambiguating in the spec to avoid confusion.
