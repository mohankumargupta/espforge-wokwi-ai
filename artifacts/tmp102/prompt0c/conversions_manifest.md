# TMP102 Conversions Manifest

- Device: TMP102 (Texas Instruments, I2C digital temperature sensor)
- Source spec: `artifacts/tmp102/outputs/spec_tmp102.md`
- Implementation: `artifacts/tmp102/prompt0c/src/main.zig` (zig 0.16)
- Verdict: `zig build` and `zig build test` both pass.

This file is the single source of truth for TMP102 register-level bit layout
(alignment, byte order, and sign extension). Any skill that later needs to
encode or decode TMP102 temperature registers MUST reuse or port these exact
functions rather than re-deriving the encoding independently.

All temperature registers (Temperature `0x00`, TLOW `0x02`, THIGH `0x03`)
share the same data format: two's complement, left-aligned in the 16-bit
register word, MSB byte first (big-endian). Scale = 0.0625 C/LSB.

## Conversions identified

No CRC or checksum logic exists for this device. The complex logic is the
two's-complement sign extension plus left-alignment encode/decode for the two
temperature data formats (Normal 12-bit / Extended 13-bit), plus two
Configuration-register field decoders (conversion rate and fault queue).

| Function | File | Purpose |
|---|---|---|
| `signExtend(value, bits)` | src/main.zig | Interpret a `bits`-wide two's-complement field as a signed i16 |
| `decodeCount12(word)` | src/main.zig | Normal-mode (12-bit) register word -> signed count |
| `decodeCount13(word)` | src/main.zig | Extended-mode (13-bit) register word -> signed count |
| `decodeCount(word, extended)` | src/main.zig | Mode-select wrapper around the two decoders |
| `countToCelsius(count)` | src/main.zig | signed count -> C (count * 0.0625) |
| `wordToCelsius(word)` | src/main.zig | register word -> `{celsius, extended}` with EM-flag auto-detection |
| `celsiusToWord12(c)` | src/main.zig | C -> Normal-mode (12-bit) register word |
| `celsiusToWord13(c)` | src/main.zig | C -> Extended-mode (13-bit) register word |
| `conversionRateHz(config)` | src/main.zig | CR1:CR0 (bits 7:6) -> conversion rate in Hz |
| `faultQueueCount(config)` | src/main.zig | F1:F0 (bits 12:11) -> consecutive-fault count before ALERT |

## Function details

### `signExtend(value: u16, comptime bits: u5) i16`

- Worked example: `signExtend(0xE70, 12)` -> `-400` (raw 12-bit count for -25 C).
- Bit layout: value holds a two's-complement field in its low `bits` bits;
  the high bits are sign-extended via an arithmetic right shift after
  reinterpreting `value << (16 - bits)` as i16.
- This is THE sign-extension primitive; all decoders route through it.

### `decodeCount12(word: u16) i16`

- Worked example: `decodeCount12(0x3200)` -> `800` (+50 C).
- Bit layout: data occupies bits 15:4 of the register word; bits 3:0 are
  ignored (always 0 in Normal mode). The 12-bit field is then sign-extended.

### `decodeCount13(word: u16) i16`

- Worked example: `decodeCount13(0x4B01)` -> `2400` (+150 C, Extended).
- Bit layout: data occupies bits 15:3; bit 0 is the EM format flag (ignored
  for the count); bits 2:1 read 0. The 13-bit field is then sign-extended.

### `decodeCount(word: u16, extended: bool) i16`

- Runtime mode selector; delegates to `decodeCount13` when `extended` is true,
  else `decodeCount12`.

### `countToCelsius(count: i16) f32`

- Worked example: `countToCelsius(800)` -> `50.0`.
- Formula: `count * 0.0625`. No bit layout involved.

### `wordToCelsius(word: u16) Decoded` (`Decoded = { celsius: f32, extended: bool }`)

- Worked example: `wordToCelsius(0x4B01)` -> `{ celsius: 150.0, extended: true }`.
- Bit layout: bit 0 of the word selects the format — `0` = Normal (12-bit),
  `1` = Extended (13-bit); the matching decoder is applied automatically.
  Bytes are MSB-first; this function operates on the already-assembled word.

### `celsiusToWord12(celsius: f32) u16`  — ENCODE

- Worked example: `50.0 C` -> `0x3200`.
- Bit layout: signed 12-bit count placed left-aligned in bits 15:4; bits 3:0
  are written 0.
- Out-of-range policy: **clamp/saturate**. Range is [-128.0, +127.9375] C.
  Inputs outside are saturated to `0x8000` (-128 C) or `0x7FF0`
  (+127.9375 C); e.g. `celsiusToWord12(128.0)` -> `0x7FF0` because +128 C
  cannot be represented in 12 bits.

### `celsiusToWord13(celsius: f32) u16`  — ENCODE

- Worked example: `150.0 C` -> `0x4B01`.
- Bit layout: signed 13-bit count placed left-aligned in bits 15:3; bit 0 is
  written 1 (EM flag); bits 2:1 are 0.
- Out-of-range policy: **clamp/saturate**. Range is [-256.0, +255.9375] C.
  Inputs outside are saturated to `0x8001` (-256 C) or `0x7FF9`
  (+255.9375 C).

### `conversionRateHz(config: u16) f32`

- Worked example: `conversionRateHz(0x60A0)` -> `4.0` (reset value, CR1:CR0 = 10).
- Bit layout: CR1:CR0 are Configuration bits 7:6 (byte 2 LSB).
  Decode: 00 -> 0.25 Hz, 01 -> 1 Hz, 10 -> 4 Hz, 11 -> 8 Hz.

### `faultQueueCount(config: u16) u8`

- Worked example: `faultQueueCount(0x60A0)` -> `1` (reset value, F1:F0 = 00).
- Bit layout: F1:F0 are Configuration bits 12:11 (byte 1 MSB).
  Decode: 00 -> 1, 01 -> 2, 10 -> 4, 11 -> 6 consecutive faults.

## Verification

- `zig build` — compiles.
- `zig build test` — all unit tests pass, including exhaustive round trips of
  every representable 12-bit and 13-bit register code.
