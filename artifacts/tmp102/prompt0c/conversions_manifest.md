# TMP102 Conversions Manifest

Single source of truth for TMP102 register-level bit layout. Any downstream
skill that encodes or decodes TMP102 registers MUST reuse or port these exact
functions rather than re-deriving the encoding.

Implementation: `artifacts/tmp102/prompt0c/src/main.zig`
Source spec: `artifacts/tmp102/outputs/spec_tmp102.md`

---

## Temperature words (Normal Mode, EM=0)

| Function | File | Worked example | Bit-layout assumption |
|---|---|---|---|
| `signExtend(value, bits)` | `main.zig` | `0x190,12 -> 400`; `0xE70,12 -> -400` | Two's-complement count packed in low `bits`, sign at bit `bits-1`; arith-shift sign-extension. |
| `count12FromWord(word)` | `main.zig` | `0x1900 -> 400 counts`; `0xE700 -> -400` | 12-bit signed count left-aligned in bits 15:4; low nibble D3-D0 is 0. |
| `count12ToWord(count)` | `main.zig` | `400 -> 0x1900`; `-400 -> 0xE700` | Left-align count into bits 15:4 of the 16-bit register word; zero the low nibble. |
| `temperatureCFromWord(word)` | `main.zig` | `0x1900 -> 25.0 C` | `count12 * 0.0625 C/count`; resolution 0.0625 C. |
| `temperatureCToRegisterWord12(c)` | `main.zig` | `21.0 C -> 0x1500` | `round(c / 0.0625)` -> 12-bit count (clamped to [-2048, 2047]) `<< 4`. |
| `count12FromTemperatureC(c)` | `main.zig` | `21.0 C -> 336 counts` | Same rounding/clamp; `@round` half-away-from-zero. |
| `temperatureCFromMsbByteOnly(msb)` | `main.zig` | `0x19 -> 25.0 C` | Only MSB byte read (LSB omitted); msb LSB = 4 counts = 0.25 C, low 4 count bits assumed 0. |

## Temperature words (Extended Mode, EM=1)

| Function | File | Worked example | Bit-layout assumption |
|---|---|---|---|
| `count13FromWord(word)` | `main.zig` | `0x0C81 >> 3 = 0x190 -> 400 counts` | 13-bit signed count left-aligned in bits 15:3. |
| `count13ToWord(count)` | `main.zig` | `400 -> 0x0C81`; `-400 -> 0xF381` | Left-align count into bits 15:3 and set bit 0 (D0) = 1 (format marker). |
| `temperatureCFromWordExtended(word)` | `main.zig` | `0x0C81 -> 25.0 C` | `count13 * 0.0625 C/count`. |
| `temperatureCToRegisterWord13(c)` | `main.zig` | `25.0 C -> 0x0C81` | `round(c / 0.0625)` -> 13-bit count (clamped to [-4096, 4095]) `<< 3` then `| 0x0001`. |
| `registerIsExtendedMode(word)` | `main.zig` | `0xF381 -> true`; `0xE700 -> false` | D0 of the register word = 1 in Extended Mode, always 0 in Normal. |
| `temperatureCFromWordAuto(word)` | `main.zig` | `0xC81 -> 25.0 C`; `0xE700 -> -25.0 C` | Dispatch on the D0 marker to the 13-bit or 12-bit decoder. |

## Bus byte packing (I2C, MSB first)

| Function | File | Worked example | Bit-layout assumption |
|---|---|---|---|
| `bytesToWord(msb, lsb)` | `main.zig` | `(0x19, 0x00) -> 0x1900` | Two-byte register word, MSB byte first on the bus. |
| `wordToBytes(word)` | `main.zig` | `0x1900 -> [0x19, 0x00]` | Emits MSB byte first. |
| `temperatureCFromBytes(msb, lsb)` | `main.zig` | `(0x15, 0x00) -> 21.0 C` | Assemble MSB-first bytes then Normal-mode decode. |

---

## Datasheet Table 6-2 vectors validated in `zig build test`

| Real-world | Raw 12-bit count (HEX) | Register word |
|---|---|---|
| 128 / 127.9375 C | `0x7FF` | `0x7FF0` |
| 100 C | `0x640` | `0x6400` |
| 80 C | `0x500` | `0x5000` |
| 75 C | `0x4B0` | `0x4B00` |
| 50 C | `0x320` | `0x3200` |
| 25 C | `0x190` | `0x1900` |
| 0.25 C | `0x004` | `0x0040` |
| 0 C | `0x000` | `0x0000` |
| -0.25 C | `0xFFC` | `0xFFC0` |
| -25 C | `0xE70` | `0xE700` |
| -55 C | `0xC90` | `0xC900` |