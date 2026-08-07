# TMP102 — Conversion Functions Manifest

Single source of truth artifact: `artifacts/tmp102/prompt0c/src/root.zig` (Zig 0.16).
All functions below live there, verified by `zig build test`. Downstream skills
MUST port/reuse these functions rather than re-deriving the bit layout.

Registers are I2C big-endian (MSB first). Temperature result is signed
two's-complement, left-aligned; 1 LSB = 0.0625 C.

## Byte order

| Function | File | Worked example | Bit-layout assumption encoded |
|---|---|---|---|
| `bytesToWord(msb, lsb)` | `src/root.zig` | `bytesToWord(0x64, 0x00)` = `0x6400` | MSB-first: `(msb<<8)\|lsb` |
| `wordToBytes(reg)` | `src/root.zig` | `wordToBytes(0x6400)` = `[0x64, 0x00]` | MSB-first split |

## Temperature — Normal (12-bit, EM=0)

Layout: 12-bit signed value T11..T0 **left-aligned in bits 15:4**; lower nibble
(bits 3:0) reads 0. Decode/encode via arithmetic shift (sign bit = bit 15).

| Function | Meaning | Worked example | Assumption |
|---|---|---|---|
| `decodeTempNormal(reg)` | register word → C | `decodeTempNormal(0x1500)` = `21.0 C` | `((i16)reg >> 4) * 0.0625` |
| `encodeTempNormal(c)` | C → register word | `encodeTempNormal(21.0)` = `0x1500` | round(c/0.0625), clamp [-2048,2047], `<< 4`, lower nibble 0 |

Spec table round-trips tested: 0x6400→100, 0x4B00→75, 0x1900→25, 0x0040→0.25,
0xFFC0→–0.25, 0xE700→–25, 0xC900→–55; clamp 128→0x7FF0, –128.1→0x8000.

## Extended (13-bit, EM=1)

13-bit signed value T12..T0 **left-aligned in bits 15:3**, with **bit 0 set to 1**
(D0 of byte 2) as the extended-mode marker. Decode by arithmetic shift by 3.

| Function | Meaning | Worked example | Assumption |
|---|---|---|---|
| `decodeTempExtended(reg)` | register word → C | `decodeTempExtended(0x0A81)` = `21.0 C` | `((i16)reg >> 3) * 0.0625`; bit 0 marker dropped by shift |
| `encodeTempExtended(value)` | C → register word | `encodeTempExtended(150.0)` = `0x4B01` | round(c/0.0625), clamp [-4096,4095], `<< 3`, `\| 0x0001` marker |

Note: the datasheet's raw "150 °C = 0x0960" example lists the **13-bit two's
complement number**, not the register word; the register word additionally
left-aligns this by 3 places and sets bit 0. `encodeTempExtended(150.0)=0x4B01`
matches the datasheet layout.

## Configuration register (0x01) helpers

Layout: Byte1 `OS R1 R0 F1 F0 POL TM SD`, Byte2 `CR1 CR0 AL EM - - - -`.

| Function | Meaning | Worked example | Layout |
|---|---|---|---|
| `getBit(reg, bit)` / `setBit(...)` | field primitives | `setBit(0,8,true)` → SD set | bit index into MSB-first 16-bit word |
| `configShutdown(reg)`, `configExtendedMode(reg)`, `configPolarity`, `configThermostatMode` | named fields | `configExtendedMode(0x6080)`=false | SD bit 8, EM bit 4, POL bit 10, TM bit 9 |
| `conversionRateField(reg)` | CR1:CR0 | reset → `2` (10b) | bits 7:6 |
| `conversionRateHz(reg)` | field → Hz | `conversionRateHz(0x6080)`=4 Hz | 00→0.25, 01→1, 10→4, 11→8 |
| `faultQueueCount(reg)` | F1:F0 → faults | `faultQueueCount(0x1800)`=6 | 00→1, 01→2, 10→4, 11→6 |