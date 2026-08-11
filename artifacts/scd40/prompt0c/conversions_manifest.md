# SCD40 — Conversions Manifest

Source of truth for register-level bit layout, byte order, and sign extension
for the SCD40. Any downstream skill that encodes/decodes these values MUST
reuse or port these exact functions rather than re-deriving them.

All functions live in `src/main.zig` (artifacts/scd40/prompt0c).

## Bus-domain model (applies to every function)

- Each payload data word is a **16-bit unsigned count**, transmitted MSB-first
  (big-endian), occupying the **full register word (bits 15:0)** — no
  alignment, no shifting, no sign extension in the wire format.
- Every data word is followed by an 8-bit **CRC-8**: poly `0x31`
  (x^8+x^5+x^4+1), init `0xff`, no reflection, no final XOR. Covers only the
  two bytes of the word. Verified: `crc8Word(0xbeef) == 0x92`.
- CRC function name: `crc8(data)`, `crc8Word(word)`.

## Conversion functions

| Function | Direction | Formula / mapping | Bit-layout assumption | Worked example | Out-of-range policy |
|---|---|---|---|---|---|
| `co2ToRaw` / `co2FromRaw` | encode / decode | ppm = raw count | full 16-bit word, identity | 500 ppm ↔ `0x01f4` | saturate at u16 bounds (0..0xffff) |
| `tempFromRaw` | decode | T[°C] = −45 + 175·word/65535 | full 16-bit word, linear map, no sign extension | `0x6667` (26215) → 25.0 °C | n/a (decode) |
| `tempToRaw` | encode | word = round((T+45)·65535/175) | linear inverse, **round to nearest**, saturate to 0x0000/0xffff | 25.0 °C → 26214 (±1 of datasheet 0x6667) | clamp: < −45 °C → 0x0000; > 130 °C → 0xffff |
| `rhFromRaw` | decode | RH[%] = 100·word/65535 | full 16-bit word, linear map | `0x5eb9` (24249) → 37.0 % | n/a (decode) |
| `rhToRaw` | encode | word = round(RH·65535/100) | round to nearest, saturate | 37.0 % → 24248 (±1 of datasheet 0x5eb9) | clamp: < 0 → 0x0000; > 100 → 0xffff |
| `tempOffsetFromRaw` | decode | offset[°C] = 175·word/65535 | full 16-bit word, linear map | `0x0912` (2322) → 6.2 °C | n/a (decode) |
| `tempOffsetToRaw` | encode | word = round(offset·65535/175) | round to nearest, saturate | 6.2 °C → 2322 (`0x0912`); 5.4 °C → 2022 (`0x07e6`) | clamp: < 0 → 0x0000; > 175 °C → 0xffff |
| `altitudeFromRaw` / `altitudeToRaw` | encode / decode | meters = raw count | full 16-bit word, identity | 1100 m ↔ `0x044c`; 1950 m ↔ `0x079e` | saturate at u16 bounds |
| `pressureFromRaw` | decode | pressure[Pa] = word·100 | full 16-bit word × 100 | `0x03db` (987) → 98700 Pa | n/a (decode) |
| `pressureToRaw` | encode | word = round(Pa/100) | round to nearest (half away from zero), saturate | 98700 Pa → 987 | clamp: > 6.5536 MPa → 0xffff (below 50 Pa → 0) |
| `frcTargetToRaw` | encode | word = target ppm | identity (write side of FRC) | 480 ppm → `0x01e0` | saturate at u16 bounds |
| `frcCorrectionFromRaw` | decode | corr[ppm] = word − 0x8000 (**signed**, centered 0x8000) | two's-complement bias; the wire word is still an unsigned count | `0x7fce` (32718) → −50 ppm | n/a (decode); `frcFailed` true when word == `0xffff` |
| `ascEnabledFromRaw` / `ascEnabledToRaw` | encode / decode | bool ↔ 0x0001 / 0x0000 | doc’d values exactly 0/1; any non-zero decodes true | true ↔ `0x0001`; false ↔ `0x0000` | n/a (canonical values) |
| `ascTargetFromRaw` / `ascTargetToRaw` | encode / decode | target = raw ppm | identity | 435 ↔ `0x01b3`; 420 ↔ `0x01a4` | saturate at u16 bounds |
| `ascPeriodFromRaw` / `ascPeriodToRaw` | encode / decode | hours = raw count | identity | 76 ↔ `0x004c`; 156 ↔ `0x009c` | saturate at u16 bounds |
| `serialFromRaw` | decode | sn = w0<<32 \| w1<<16 \| w2 (48-bit big-endian) | three words, most-significant first | `0xf896`,`0x9f07`,`0x3bbe` → 273,325,796,834,238 | n/a (decode) |
| `serialToRaw` | encode | w0/w1/w2 = split of u64 | three words, big-endian | 273,325,796,834,238 → `0xf896`,`0x9f07`,`0x3bbe` | **error** (`error.OutOfRange`) for any value > 0xFFFF_FFFF_FFFF — not saturate |
| `dataReady` | decode | ready = (word & 0x07ff) != 0 | DATA_READY in bits **10:0**, upper bits ignored | `0x8000` → false; `0x0400` / `0x0001` → true | n/a |
| `variantFromRaw` | decode | variant = bits 15:12 | upper nibble of the word | `0x0440`→SCD40, `0x1440`→SCD41, `0x5441`→SCD43, `0x4440`→unknown | n/a; unknown returned for undefined nibble |

## Choices that downstream skills inherit (do NOT re-derive)

1. **Encode rounding** = nearest integer (`@round`, half away from zero). For
   quantities that share no exact integer count (25.0 °C, 37.0 %RH, offsets),
   this may produce a count one away from the datasheet worked-example word;
   datasheet words chosen for display purposes. Decode-side tests always use
   the datasheet raw words as input — never a hand-computed signed decimal.
2. **Encode out-of-range** = clamp/saturate everywhere **except** `serialToRaw`,
   which returns `error.OutOfRange` (silent truncation would corrupt device
   identity). Policies are documented in each function doc comment.
3. **FRC**: write side is a plain target count (`frcTargetToRaw`); read side is
   the biased signed correction (`frcCorrectionFromRaw`), with `0xffff`
   reserved as "FRC failed" (`frcFailed`).
4. **Pressure**: decode is exact (word×100); encode rounds Pa/100 to nearest,
   so a decode/encode round trip is exact to ±50 Pa.

## Verification

`zig build test` — 15 conversion/algorithm tests + 1 fuzz (temp count
encode/decode round-trip within one count) in the executable module; 16/16
pass under Zig 0.16.0.