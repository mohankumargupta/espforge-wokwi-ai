# APDS9960 Conversions Manifest

- Device: APDS9960 (Avago/Broadcom, I2C gesture / proximity / RGBC sensor)
- Source specs: `artifacts/apds9960/outputs/spec_apds9960.md` (datasheet) and
  `artifacts/apds9960/outputs/test_spec_apds9960.md` (canonical test spec,
  ESPHome percent scaling)
- Implementation: `artifacts/apds9960/prompt0c/src/main.zig` (zig 0.16)
- Verdict: `zig build` and `zig build test` both pass.

This file is the single source of truth for APDS9960 register-level bit layout
(alignment, byte order, and sign/magnitude encoding). Any skill that later
needs to encode or decode the same register values MUST reuse or port these
exact functions rather than re-deriving the encoding independently.

## Conversions identified

No CRC or checksum logic exists for this device. The complex logic is: the
Little-Endian 16-bit RGBC register-pair assembly, the full-scale-count formula
for ATIME (and its spec discrepancy, below), the sign/magnitude offset
encoding used by POFFSET_UR/DL and GOFFSET_U/D/L/R, and the two percent
encoders that produce the ESPHome observable register values.

| Function | File | Purpose |
|---|---|---|
| `rgbcFromBytes(low, high)` | src/main.zig | Little-Endian low+high RGBC bytes -> 16-bit count |
| `rgbcToBytes(count)` | src/main.zig | 16-bit count -> `{low, high}` Little-Endian bytes |
| `rgbcPercentFromCount(count)` | src/main.zig | RGBC count -> % of full scale (`count/65535*100`) |
| `rgbcCountFromPercent(pct)` | src/main.zig | ENCODE: % -> RGBC count (clamp) |
| `proxPercentFromCount(count)` | src/main.zig | Proximity count -> % of full scale (`count/255*100`) |
| `proxCountFromPercent(pct)` | src/main.zig | ENCODE: % -> proximity count (clamp) |
| `atimeToCycles(atime)` | src/main.zig | ATIME register -> integration cycles (`256-ATIME`) |
| `atimeToIntegrationMs(atime)` | src/main.zig | ATIME -> integration time ms (`cycles*2.78`) |
| `atimeToFullScale(atime)` | src/main.zig | ATIME -> max count (`min(1024*cycles+1, 65535)`) |
| `wtimeToSteps(wtime)` | src/main.zig | WTIME register -> wait steps (`256-WTIME`) |
| `wtimeToWaitMs(wtime, wlong)` | src/main.zig | WTIME + CONFIG1 WLONG -> wait time ms |
| `offsetFromByte(reg)` | src/main.zig | sign/magnitude offset byte -> signed offset |
| `offsetToByte(offset)` | src/main.zig | ENCODE: signed offset -> sign/magnitude byte (clamp) |
| `pulseCount(ppulse_field)` | src/main.zig | PPULSE field (bits 5:0) -> pulse count (`field+1`) |
| `pulseLengthUs(pplen_field)` | src/main.zig | PPLEN/GPLEN field (bits 7:6) -> LED-on us |
| `proximityResultTimeMs(...)` | src/main.zig | tPROX formula reference algorithm |

## Function details

### `rgbcFromBytes(low: u8, high: u8) u16`
- Worked example: `rgbcFromBytes(0x33, 0x33)` -> `0x3333` (13107).
- Bit layout: Little-Endian 16-bit word, low byte at the even address
  (0x94/0x96/0x98/0x9A), high byte at the odd address. `high<<8 | low`. The
  count spans the full 16-bit register word.

### `rgbcToBytes(count: u16) RgbcBytes` (`RgbcBytes = {low, high}`)
- Worked example: `rgbcToBytes(0x2666)` -> `{low: 0x66, high: 0x26}`.
- Bit layout: inverse of `rgbcFromBytes`; used to place a count into
  Little-Endian register pairs.

### `rgbcPercentFromCount(count: u16) f32`
- Worked example: `rgbcPercentFromCount(13107)` -> `20.0`.
- Formula: `count / 65535 * 100` (ESPHome `apds9960.cpp` scaling, canonical
  observable decode).

### `rgbcCountFromPercent(pct: f32) u16` — ENCODE
- Worked example: `rgbcCountFromPercent(20.0)` -> `0x3333`; `15.0` -> `0x2666`;
  `12.0` -> `0x1EB8`; `9.0` -> `0x170A` (canonical decode table).
- Formula: `round(clamped * 655.35)`.
- Out-of-range policy: **clamp/saturate**. `pct < 0` -> 0x0000; `pct > 100`
  -> 0xFFFF; NaN -> 0x0000.

### `proxPercentFromCount(count: u8) f32`
- Worked example: `proxPercentFromCount(18)` -> `7.0588` (published as 7.1 at
  precision 1).
- Formula: `count / 255 * 100` (ESPHome scaling).

### `proxCountFromPercent(pct: f32) u8` — ENCODE
- Worked example: `proxCountFromPercent(7.1)` -> `18` (0x12).
- Formula: `round(clamped * 2.55)`.
- Out-of-range policy: **clamp/saturate**. `pct < 0` -> 0x00; `pct > 100`
  -> 0xFF; NaN -> 0x00.

### `atimeToCycles(atime: u8) u16`
- Worked example: `atimeToCycles(0xDB)` -> `37`.
- Formula: `CYCLES = 256 - ATIME` (1..256).

### `atimeToIntegrationMs(atime: u8) f32`
- Worked example: `atimeToIntegrationMs(0xF6)` -> `27.8`.
- Formula: `CYCLES * 2.78 ms`.

### `atimeToFullScale(atime: u8) u16`
- Worked examples: `0xFF` -> 1025, `0xF6` -> 10241, `0xDB` -> 37889,
  `0x00` -> 65535.
- Formula: `CountMAX = min(1024 * CYCLES + 1, 65535)`.
- **Spec discrepancy:** `spec_apds9960.md` Data Conversion states
  `CountMAX = min(1025 x CYCLES, 65535)` inline, but the spec's own
  worked-example table (0xF6 -> 10241, 0xDB -> 37889) only matches
  `1024 * CYCLES + 1`. The worked examples are authoritative; the
  `1024*cycles + 1` form is the single source of truth here.

### `wtimeToSteps(wtime: u8) u16`
- Worked example: `wtimeToSteps(0x00)` -> `256`.
- Formula: `WAIT_STEPS = 256 - WTIME` (1..256).

### `wtimeToWaitMs(wtime: u8, wlong: bool) f32`
- Worked examples: `wtimeToWaitMs(0x00, false)` -> 711.68 ms (spec: ~712 ms);
  `wtimeToWaitMs(0x00, true)` -> 8540.16 ms (spec: ~8.54 s).
- Formula: `WAIT_STEPS * 2.78 ms` (WLONG=0) or `* 2.78 * 12` (WLONG=1, CONFIG1
  bit 1).

### `offsetFromByte(reg: u8) i8`
- Worked examples: `0x7F` -> +127, `0x81` -> -1, `0xFF` -> -127.
- Bit layout: sign/magnitude 8-bit. bit 7 = sign (1 = negative), bits 6:0 =
  magnitude (0..127). Range [-127, +127]. `0x80` (negative zero) decodes to 0
  (non-canonical duplicate of 0x00).

### `offsetToByte(offset: i32) u8` — ENCODE
- Worked examples: `+127` -> 0x7F, `-1` -> 0x81, `-127` -> 0xFF.
- Bit layout: sign/magnitude 8-bit, same as decode.
- Out-of-range policy: **clamp/saturate**. `offset > +127` -> 0x7F; `offset
  < -127` (incl. -128, whose magnitude 128 is unrepresentable) -> 0xFF.

### `pulseCount(ppulse_field: u6) u8`
- Worked example: `pulseCount(0x07)` -> 8 (PPULSE=0x87 gives 8 pulses, as used
  by ESPHome).
- Formula: `pulses = field + 1` (1..64). Field is PPULSE/GPULSE bits 5:0.

### `pulseLengthUs(pplen_field: u2) u16`
- Decode: 0 -> 4 us, 1 -> 8 us, 2 -> 16 us, 3 -> 32 us. Field is PPLEN/GPLEN
  bits 7:6.

### `proximityResultTimeMs(pulses: u8, t_init_us: u16, t_acc_us: u16) f32`
- Formula: `tPROX = (tINIT + tCNVT + pulses * tACC) / 1000`, tCNVT = 796.6 us.
- tINIT and tACC are functions of PPLEN; the spec states they are "per PPLEN"
  but does not tabulate values, so they are caller parameters here rather than
  invented constants.
- **Spec discrepancy:** the tPROX formula line states `tCNVT = 796.6 us` while
  the Timing reference section says the proximity ADC conversion is "~696.6 us
  fixed". 796.6 us (the formula's stated value) is used as the constant here.

## Verification

- `zig build` — compiles.
- `zig build test` — all unit tests pass, including canonical decode-table
  byte pairs, ATIME/WTIME worked examples, offset encode/decode round trips
  over all 256 register codes (excluding non-canonical 0x80), and three
  `std.testing.fuzz` round-trip fuzz tests (RGBC %, proximity %, offset).
