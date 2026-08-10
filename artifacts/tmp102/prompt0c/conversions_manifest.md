# TMP102 conversions manifest

Source of truth for register-level bit layout (alignment, byte order, sign
extension) for the TMP102. Any skill that later encodes/decodes the same
registers MUST reuse or port these exact functions rather than re-deriving
the encoding.

Files: `src/root.zig` (all conversion functions, module `prompt0c`),
`src/main.zig` (CLI demo + fuzz roundtrip).

## Temperature register (0x00), TLOW (0x02), THIGH (0x03)

Data is 12-bit (13-bit in Extended mode) two's complement, left-aligned in
the 16-bit word, MSB byte first. Scale: 0.0625 C/LSB.

### Normal mode (EM=0)

| Function | Input | Output | Worked example |
|---|---|---|---|
| `decodeTempNormal(word)` | full 16-bit register word | °C | `0x6400` -> `100.0` C |
| `decodeTempNormal12(count)` | raw u12 count | °C | `0x190` -> `25.0` C |
| `encodeTempNormal(temp_c)` | °C | full 16-bit word | `100.0` C -> `0x6400` |
| `signExtend12(count)` | raw u12 count | i16 count | `0xE70` -> `-880` |

- **Bit layout encoded:** value left-aligned in bits 15:4; bits 3:0 = 0.
  Sign extension via `@bitCast(word) >> 4` (arithmetic shift on i16).
- **Out-of-range (encode):** **clamp/saturate** to representable range
  [-128.0, +127.9375] C. `+128` C saturates to `0x7FF0` (127.9375 C) because
  12 bits cannot represent +128 exactly (documented wrap in datasheet Table 5).
  NaN input -> `0x0000` (0 C).

### Extended mode (EM=1)

| Function | Input | Output | Worked example |
|---|---|---|---|
| `decodeTempExtended(word)` | full 16-bit register word | °C | `0x4B01` -> `150.0` C |
| `decodeTempExtended13(count)` | raw u13 count | °C | `0x0960` -> `150.0` C |
| `encodeTempExtended(temp_c)` | °C | full 16-bit word | `150.0` C -> `0x4B01` |
| `signExtend13(count)` | raw u13 count | i16 count | `0x1C90` -> `-880` |

- **Bit layout encoded:** value left-aligned in bits 15:3; bit 0 = 1 (EM mode
  flag, always written by encode, ignored on read); bits 2:1 = 0.
  Sign extension via `@bitCast(word) >> 3` (arithmetic shift on i16).
- **Out-of-range (encode):** **clamp/saturate** to representable range
  [-256.0, +255.9375] C. NaN input -> `0x0001` (0 C).

## Byte order (I2C transport)

| Function | Input | Output | Worked example |
|---|---|---|---|
| `wordFromMsbLsb(msb, lsb)` | two wire bytes | u16 word | `(0x64, 0x00)` -> `0x6400` |
| `msbLsbFromWord(word)` | u16 word | `{msb, lsb}` | `0x6400` -> `(0x64, 0x00)` |

- **Bit layout encoded:** big-endian, MSB byte first. No out-of-range issue
  (total functions over fixed-width bytes).

## Configuration register (0x01) bit fields

Packed/unpacked by `Config.fromWord(u16)` / `Config.toWord()`. Layout:
byte1 = bit15 OS | bit14:13 R1:R0 (read-only, `11` = 12-bit) | bit12:11 F1:F0 |
bit10 POL | bit9 TM | bit8 SD; byte2 = bit7:6 CR1:CR0 | bit5 AL (read-only) |
bit4 EM | bit3:0 reserved. Reset value `0x60A0` (TM=comparator, AL=1, CR=4 Hz,
F1:F0=00).

### Fault queue (F1:F0)

| Function | Input | Output | Worked example |
|---|---|---|---|
| `faultQueueCount(bits)` | u2 field | faults | `0b10` -> `4` |
| `faultQueueBits(count)` | faults | u2 field | `4` -> `0b10` |

- **Bit layout encoded:** 00=1, 01=2, 10=4, 11=6.
- **Out-of-range (encode):** **error** (`error.InvalidFaultQueueCount`) for any
  count not in {1, 2, 4, 6}.

### Conversion rate (CR1:CR0)

| Function | Input | Output | Worked example |
|---|---|---|---|
| `conversionRateHz(bits)` | u2 field | Hz | `0b10` -> `4.0` Hz |
| `conversionRateBits(hz)` | Hz | u2 field | `4.0` -> `0b10` |

- **Bit layout encoded:** 00=0.25, 01=1, 10=4, 11=8 Hz.
- **Out-of-range (encode):** **clamp/round-to-nearest**; above 8 Hz clamps to
  0b11. Midpoints 0.625/2.5/6.0 are rounded up to the next rate.

## Bus addressing

| Function | Input | Output | Worked example |
|---|---|---|---|
| `slaveAddress(a1a0)` | u2 A1:A0 strap | u7 7-bit addr | `0b10` -> `0x4A` |

- **Bit layout encoded:** base `0b1001000` (0x48) | A1:A0 -> 0x48/0x49/0x4A/0x4B
  for ADD0 = GND/V+/SDA/SCL. Total, no out-of-range case.