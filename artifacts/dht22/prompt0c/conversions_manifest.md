# DHT22 Conversions Manifest

Zig project: `artifacts/dht22/prompt0c` (source of truth: `src/main.zig`)
Spec source: `artifacts/dht22/outputs/spec_dht22.md`

This manifest is the single source of truth for register-level bit layout
(alignment, byte order, and sign extension) for the DHT22. Any other skill
that later needs to encode or decode DHT22 frame bytes MUST reuse or port
these exact functions rather than re-deriving the encoding independently.

## Frame layout (fixed)

40-bit / 5-byte frame, transmitted MSB first on the single-wire bus:

| Byte | Name  | Meaning                         |
|------|-------|---------------------------------|
| 0    | RH_INT| Humidity integral part (u8)     |
| 1    | RH_DEC| Humidity decimal part (u8)      |
| 2    | T_INT | Temperature integral part (u8)  |
| 3    | T_DEC | Temperature decimal part (u8)   |
| 4    | CHECK | Checksum (low byte of sum)      |

No left/right alignment within a register — the frame is a byte stream and
each 16-bit value is formed as `integral<<8 | decimal`.

## Conversion functions

All in `src/main.zig`.

### `humidityWord(hi: u8, lo: u8) u16`
- Bit layout: `(RH_INT << 8) | RH_DEC` — big-endian byte stream, no alignment.
- Worked example: input `0x01, 0xF8` → word `0x01F8` (= 504).

### `humidityDecode(hi, lo) f32`
- Formula: `word / 10.0` → %RH. Resolution 0.1 %RH.
- Worked example: `0x01, 0xF8` → `504 / 10 = 50.4` %RH.
- Not clamped: a raw word of `0xFFFF` decodes to `6553.5` %RH even though the
  sensor's valid operating range is 0–100 %RH (bit content mapped faithfully).

### `humidityEncode(f32) -> { rh_int, rh_dec }`
- Inverse of the above; rounds to nearest 0.1 %RH (uses `round`).
- Out-of-range policy: **clamp/saturate** to the sensor's physical operating
  range `[0, 100]` %RH.
- Worked example: `50.4` → `0x01, 0xF8`; `150.0` clamps to `100.0` → `0x03, 0xE8`.

### `temperatureWord(hi: u8, lo: u8) u16`
- Bit layout: `(T_INT << 8) | T_DEC` — big-endian byte stream.
- Worked example: `0x00, 0xFA` → word `0x00FA` (= 250).

### `temperatureDecodeRaw(raw: u16) f32` and `temperatureDecode(hi, lo) f32`
- Sign/magnitude, **bit 15 = sign**, bits 14:0 = magnitude.
- Formula: `(bit15 set) ? -(raw & 0x7FFF)/10.0 : raw/10.0` → °C. Res. 0.1 °C.
- Worked example: `0x00, 0xFA` → `250/10 = 25.0` °C.
- `0x80, 0x64` → `-(0x0064)/10 = -10.0` °C.

### `temperatureEncode(f32) -> { t_int, t_dec }`
- Inverse of the above for the sign/magnitude word; rounds to nearest 0.1 °C.
- Out-of-range policy: **clamp/saturate** to the sensor's physical operating
  range `[-40, +80]` °C.
- Canonical zero: encodes `0.0` → `0x00, 0x00` (`0x0000`), NEVER `0x80, 0x00` —
  see "Duplicate encoding of ±0" below.
- Worked example: `-10.0` → `0x80, 0x64`; `1500.0` clamps to `80.0`.

### `checksum(frame) u8`
- Formula: low 8 bits of `RH_INT + RH_DEC + T_INT + T_DEC` (u32 sum `@truncate`).
- Worked example: `(0x01 + 0xF8 + 0x00 + 0xFA) & 0xFF = 0xF3`.

### `checksumValid(frame) bool`
- `frame.check == checksum(frame)`.

### `decode(frame) Reading` / `encode(humidity, temp) Frame`
- Whole-frame decoders/encoders; `encode` fills in the checksum.

## Contradiction inside the spec (mandatory record)

The spec's "Worked Examples / Test Vectors" table (line 154) lists a row:

> `−10.0 °C` | T bytes = `0x80` `0x00` | word `0x8000`, bit 15 set →
> `−(0x0000)/10 = 0.0` (sign shown)

The real-world label (`−10.0 °C`) and the table's own derived decode comment
(`0.0`) mutually disagree. The decode formula reproduces, for raw `0x8000`,
`-(0x0000)/10 = 0.0` — NOT `−10.0`.

Implemented: **the sign/magnitude decode formula is authoritative**; the raw
`0x8000` is kept as-is and decodes to `0.0`. A true `−10.0 °C` is encoded as
`0x80 0x64`. Rationale: the table is internally inconsistent (its own
derived-value comment contradicts its label) and cannot be directly tested,
whereas the formula is fully testable; the label `−10.0` for `0x8000` is a
spec-authoring error. This is recorded in `src/main.zig` test
"temperature decode of spec's negative raw 0x80 0x00 -> 0.0".

## Duplicate encoding of ±0 (sign/magnitude)

In the 16-bit sign/magnitude temperature field, zero is representable in two ways:
`0x0000` (+0) and `0x8000` (−0).
- Decoder: both canonicalize to the same real-world value `+0.0`
  (`temperatureDecode` handles both; test "canonical zero" asserts this).
- Encoder: picks exactly one canonical byte, `0x0000`. It never emits `0x8000`.

No exhaustive "every byte round-trips" encoder test was written because
`0x8000` would fail it; the canonical-zero test covers the duplicate instead.

## Out-of-range policies (summary)

| Function        | Policy       | Bounds                    |
|-----------------|--------------|---------------------------|
| `humidityEncode`| clamp        | [0, 100] %RH              |
| `temperatureEncode`| clamp     | [-40, +80] °C             |

Both round to the nearest 0.1 unit. Decoders never clamp.

## Verification

- `zig build` — passes
- `zig build test` — 11/11 tests pass (10 DHT22 conversion tests + 1 template)