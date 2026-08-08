# TMP102 — Conversion Functions Manifest

Single source of truth artifact: `artifacts/tmp102/prompt0c/src/root.zig` (Zig 0.16).
All functions below live there, verified by `zig build test`. Downstream skills
MUST port/reuse these functions rather than re-deriving the bit layout.

Registers are I2C big-endian (MSB first). The 16-bit temperature result is a
signed two's-complement count, left-aligned; 1 LSB = 0.0625 C.

## Byte order

| Function | File | Worked example | Bit-layout assumption encoded |
|---|---|---|---|
| `bytesToWord(msb, lsb)` | `src/root.zig` | `bytesToWord(0x64, 0x00)` = `0x6400` | MSB-first: `(msb<<8)\|lsb` |
| `wordToBytes(reg)` | `src/root.zig` | `wordToBytes(0x6400)` = `[0x64, 0x00]` | MSB-first split |
| `signExtend(value, n)` | `src/root.zig` | `signExtend(0xE70, 12)` = `-400` | `(i16)x << (16-n) >> (16-n)` arithmetic shift |

## Temperature — Normal mode (12-bit, EM=0)

Layout: 12-bit signed count T11..T0 **left-aligned in bits 15:4**; lower nibble
(bits 3:0) reads 0. Decode via arithmetic shift of the register word:
`temp_C = ((i16)reg >> 4) * 0.0625`.

| Function | Meaning | Worked example | Assumption |
|---|---|---|---|
| `decodeTempNormal(reg)` | register word → C | `decodeTempNormal(0x1900)` = `25.0 C` | `((i16)reg >> 4) * 0.0625` |
| `encodeTempNormal(c)` | C → register word | `encodeTempNormal(25.0)` = `0x1900` | round(c/0.0625), clamp [-2048,2047], `<< 4`, lower nibble 0 |

All spec worked examples round-trip: 0x7FF0→127.9375, 0x6400→100, 0x5000→80,
0x4B00→75, 0x3200→50, 0x1900→25, 0x0040→0.25, 0x0000→0, 0xFFC0→−0.25,
0xE700→−25, 0xC900→−55. Clamp: 128→0x7FF0, −128.1→0x8000.

## Temperature — Extended mode (13-bit, EM=1)

Layout: 13-bit signed count T12..T0 **left-aligned in bits 15:3**; bit 2:1 of
the register word reads 0, **bit 0 (D0 of byte 2) reads 1** as the
extended-format marker. Decode: `temp_C = ((i16)reg >> 3) * 0.0625` (the bit-0
marker is discarded by the shift).

| Function | Meaning | Worked example | Assumption |
|---|---|---|---|
| `decodeTempExtended(reg)` | register word → C | `decodeTempExtended(0x4B01)` = `150.0 C` | `((i16)reg >> 3) * 0.0625`; bit-0 marker dropped |
| `encodeTempExtended(value)` | C → register word | `encodeTempExtended(150.0)` = `0x4B01` | round(c/0.0625), clamp [-4096,4095], `<< 3`, `\| 0x0001` marker |

> **Note:** the datasheet's "150 C = 0x0960" examples are the **13-bit count**
> (right-aligned), NOT a register word. The register word is `count << 3` plus
> the bit-0 marker; `150.0` → count `0x0960` → word `0x4B01`. Decode is
> independent of the marker: `decodeTempExtended(0x4B00)` = `150.0 C` too.

## Configuration register (0x01) — field bit layout

Byte 1 (MSB): `OS R1 R0 F1 F0 POL TM SD` → bits 15..8.
Byte 2 (LSB): `CR1 CR0 AL EM - - - -` → bits 7..4 (3..0 always 0).
Reset value: `0x60A0` (byte1 `0x60` R1,R0=11; byte2 `0xA0` CR1,CR0=10 → 4 Hz,
AL=1 → not asserted, EM=0).

| Function | Meaning | Worked example | Layout |
|---|---|---|---|
| `getBit(reg, bit)` / `setBit(reg, bit, v)` | field primitives | `setBit(0, 8, true)` → SD set | bit index into MSB-first 16-bit word |
| `configPolarity(reg)` | POL | `configPolarity(CONFIG_RESET)`=false | bit 10, 0=active-low 1=active-high |
| `configThermostatMode(reg)` | TM | reset → false | bit 9, 0=comparator 1=interrupt |
| `configShutdown(reg)` | SD | reset → false | bit 8 |
| `configExtendedMode(reg)` | EM | reset → false | bit 4 |
| `conversionRateField(reg)` | CR1:CR0 index | reset → `0b10` | bits 7:6 |
| `conversionRateHz(reg)` | field → Hz | `conversionRateHz(0x0080)` = `4 Hz` | 00→0.25, 01→1, 10→4, 11→8 |
| `faultQueueField(reg)` | F1:F0 index | `0x1800` → `0b11` | bits 12:11 |
| `faultQueueCount(reg)` | F1:F0 → faults | `faultQueueCount(0x1800)` = `6` | 00→1, 01→2, 10→4, 11→6 |

## Transport — ADD0 address straps

| Function | Meaning | Worked example | Assumption |
|---|---|---|---|
| `Add0Addr.gnd/.vcc/.sda/.scl` | 7-bit addresses | `Add0Addr.gnd` = `0x48` | GND→0x48, V+→0x49, SDA→0x4A, SCL→0x4B |
| `add0Index(addr)` | addr → 0..3 | `try add0Index(0x4B)` = `3` | 0x48..0x4B ordered; error.InvalidAdd0 else |

## Register map (pointer bytes)

| Function | Value |
|---|---|
| `REG_TEMPERATURE` | `0x00` (read) |
| `REG_CONFIGURATION` | `0x01` (R/W) |
| `REG_LOW_LIMIT` | `0x02` (TLOW, R/W, reset +75 C = `0x4B00`) |
| `REG_HIGH_LIMIT` | `0x03` (THIGH, R/W, reset +80 C = `0x5000`) |
