# Chip Spec: TMP102

**Manufacturer:** Texas Instruments
**Category:** temperature
**Transports:** I2C

## Overview

The TMP102 is a low-power digital temperature sensor designed as a drop-in
replacement for NTC/PTC thermistors. It integrates a band-gap temperature
sensor, a 12-bit ADC (13-bit in Extended Mode), a two-wire / SMBus / I2C
serial interface, and an SMBus-compatible ALERT output. It provides
±0.5 °C typical (±2 °C max from -25 °C to 85 °C) accuracy without requiring
calibration or external signal conditioning, a resolution of 0.0625 °C, and a
typical quiescent current of 4.8 µA (7.5 µA max) during continuous
4-conversions-per-second operation. It operates from a 1.4 V to 3.6 V supply
and is specified over a temperature range of -40 °C to 125 °C. The ADD0 pin
selects between four I2C addresses, so up to four TMP102 devices can share one
bus. The device is available in a 1.6 mm x 1.6 mm SOT-563 package and is NIST
traceable. It is used for power-supply temperature monitoring, thermostats,
battery management, and general temperature measurement.

## Transport Configuration

### I2C

- **Address:** `0x48` (default, ADD0 = GND). Alternates: `0x49` (ADD0 = V+), `0x4A` (ADD0 = SDA), `0x4B` (ADD0 = SCL)
- **Max clock:** 400 kHz (fast mode); up to 2.85 MHz (high-speed mode, requires HS-mode controller code from host)
- **Endianness / Byte Order:** Big-Endian (MSB first)
- **Protocol Quirks:**
  - 8-bit pointer register; only bits P1:P0 are significant (values `0x00`-`0x03`). P2-P7 must be 0 during writes.
  - The pointer does **not** auto-increment during block reads. A read returns the register selected by the last pointer value written; the pointer is remembered until the next write.
  - To change the register for a read, write the pointer byte first (target address R/W=0, then pointer byte), then issue a **repeated START** followed by the target address with R/W=1.
  - Data bytes are sent MSB first; the temperature LSB byte may be omitted if not needed.
  - SCL held low for >30 ms (typ, 40 ms max) between START and STOP resets the serial interface, so SCL frequency must stay >= 1 kHz.
  - The device is a bus target only and never drives SCL. Negative temperatures are represented in two's complement.

### SPI

- Not supported.

## Physical pins names and functions

| Pin Number | Pin Name | Description
|------------|----------|------------
| 1 | SCL | Serial clock input (I)
| 2 | GND | Ground
| 3 | ALERT | Overtemperature alert, open-drain output, requires pull-up (O)
| 4 | ADD0 | Address select, connect to GND, V+, SDA, or SCL (I)
| 5 | V+ | Supply voltage, 1.4 V to 3.6 V (I)
| 6 | SDA | Serial data, open-drain I/O, requires pull-up (I/O)

## Bus and addressing Rules

The TMP102 is an I2C/SMBus target only. The ADD0 pin selects one of four
device addresses, allowing up to four devices on a single bus:

| ADD0 connection | Bus address (7-bit) |
|-----------------|---------------------|
| GND             | `0x48` (100 1000)   |
| V+              | `0x49` (100 1001)   |
| SDA             | `0x4A` (100 1010)   |
| SCL             | `0x4B` (100 1011)   |

- Recommended 5 k-ohm pull-up resistors on SDA, SCL, and ALERT.
- 0.01 µF supply bypass capacitor recommended.
- The device responds to the two-wire general call address (0x00) when the
  eighth bit is 0; second byte `0x06` resets internal registers to power-up
  values.
- SMBus Alert Response address `0001 1000` (0x18) acknowledges when ALERT is
  active and returns the device's target address on SDA.

## Register Map

Register access uses an 8-bit pointer register (only P1-P0 decode, values
`0x00`-`0x03`) written before any access. The pointer does not auto-increment.

| Address | Name         | R/W | Reset    | Description |
|---------|--------------|-----|----------|-------------|
| `0x00`  | Temperature  | R   | `0x0000` | 12-bit (13-bit in Extended Mode) conversion result, MSB-first 2 bytes <sup>1</sup> |
| `0x01`  | Configuration| R/W | `0x60A0` | OS, R1/R0, F1/F0, POL, TM, SD, CR1/CR0, AL, EM |
| `0x02`  | TLOW         | R/W | `0x4B00` | Low temperature limit register (12/13-bit) |
| `0x03`  | THIGH        | R/W | `0x5000` | High temperature limit register (12/13-bit) |

1. The temperature register reads 0x0000 (0 °C) until the first conversion
   completes (typically 10 ms after power-up).

### Temperature Register formatting

Decoded as a 12-bit two's-complement count (13-bit in Extended Mode, EM=1)
left-aligned within the 16-bit two-byte word:

- Byte 1 (MSB): D7-D0 = T11..T4 (T11 is the sign bit); in EM, (T12)..(T5).
- Byte 2 (LSB): D7-D0 = T3, T2, T1, T0, 0, 0, 0, 0 — in EM: (T4)..(T0), 0, 0, 1.
  - D0 of Byte 2 = 0 in Normal Mode, 1 in Extended Mode (used to distinguish formats).
- Bits D3-D0 (normal) are always 0. The temperature occupies bits 15:4 of the 16-bit word.

### Bit Fields

#### `CONFIGURATION` (`0x01`) — Byte 1 (MSB, written/read first)

| Bits | Name | Description |
|------|------|-------------|
| D7 | OS | One-shot start (write 1 starts one conversion in Shutdown; reads 0 during conversion) |
| D6 | R1 | Converter resolution (read-only, TMP102 fixed at 1 = 12-bit) |
| D5 | R0 | Converter resolution (read-only, fixed at 1) |
| D4 | F1 | Fault queue bit 1 (consecutive faults before alert) |
| D3 | F0 | Fault queue bit 0 |
| D2 | POL | ALERT polarity (0 = active low default, 1 = active high) |
| D1 | TM | Thermostat mode (0 = comparator, 1 = interrupt) |
| D0 | SD | Shutdown mode (1 = shut down after current conversion, 0 = continuous) |

Reset value: `0x60` (0110 0000).

#### `CONFIGURATION` (`0x01`) — Byte 2 (LSB)

| Bits | Name | Description |
|------|------|-------------|
| D7 | CR1 | Conversion rate bit 1 (00=0.25 Hz, 01=1 Hz, 10=4 Hz default, 11=8 Hz) |
| D6 | CR0 | Conversion rate bit 0 |
| D5 | AL | ALERT status (read-only; 1 = normal state, 0 = alert active, POL-inverted) |
| D4 | EM | Extended Mode (0 = 12-bit, 1 = 13-bit) |
| D3-D0 | - | Always read 0 |

Reset value: `0xA0` (1010 0000).

## Interrupts / Alert Pins

- **Pin Type:** Open-drain (requires external pull-up, e.g. 5 kΩ)
- **Polarity:** Configurable via POL bit (default active-low; POL=1 inverts -> active high)
- **Latch Behavior:**
  - Comparator mode (TM=0): ALERT activates when temp >= THIGH for the programmed
    number of consecutive faults and stays active until temp < TLOW for the same count.
  - Interrupt mode (TM=1): ALERT activates on the THIGH fault condition and stays
    active until cleared (see below); it re-arms again when temp < TLOW.
- **Clear Mechanism:** Interrupt mode — cleared by any register read, by a
  successful response to the SMBus Alert Response address (a device that loses
  the alert arbitration keeps ALERT active), by entering Shutdown mode, or by
  General-Call reset. Comparator mode — cleared automatically when the
  temperature falls below TLOW.

## Initialization Sequence & State Machine for emulating chip, timings

1. Power-up / General-Call reset: registers load defaults. Config = `0x60A0`
   (continuous conversion, 4 Hz, comparator mode, active-low alert, fault=1).
2. First conversion starts immediately at power-up; the first result is
   available after 10 ms typical (15 ms max). Until then the temperature
   register reads 0 °C.
3. Continuous-conversion mode produces one result every 250 ms..4 s depending
   on CR1/CR0, each completed conversion taking ~10 ms.
4. For a temperature read: write pointer byte `0x00`, then read 2 bytes
   (MSB first) with a repeated START. Read completes in < 20 µs after a
   fresh conversion.
5. One-shot mode (SD=1, then OS=1): single conversion ~10 ms, returns to
   shutdown; >= 80 conversions per second are possible this way.
6. If SCL is held low > 30 ms (typ), the serial interface resets and SDA is
   released; the host must then re-send a START.

## Data Conversion

- **Data Type:** Two's complement, 12-bit signed (+ 13-bit Extended Mode variant)
- **Alignment:** 12-bit value left-aligned in a 16-bit two-byte register word
  (occupies bits 15:4; the low nibble D3-D0 reads 0). In Extended Mode the
  13-bit value occupies bits 15:3 and the register's D0 reads 1.
- **Resolution / LSB:** 0.0625 °C per count

```
temperature_C = (int16_t)register_word >> 4;   /* 12-bit sign-extended count */
temperature_C = sign_extended_12bit_count * 0.0625;
```

Decoding example: 25 °C -> 0x190 = 400 counts -> 400 x 0.0625 = 25.0 °C.
-25 °C -> |25 / 0.0625| = 400 = 0x190; two's complement of 0x190 is 0xE70.

### Worked Examples / Test Vectors

All rows below come from datasheet Table 6-2 (12-bit format, EM = 0). The
datasheet **HEX** column lists the 12-bit count; the value as it appears in the
16-bit register word is that count left-shifted into bits 15:4.

| Real-world Value | Raw Register Value (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|---------------------------------|--------------------------------------------------------------------|-------|
| 128 °C           | `0x7FF`                         | raw 12-bit count; register word = `0x7FF0` (count << 4)           | Max positive count; datasheet lists both 128 and 127.9375 as 0x7FF |
| 100 °C           | `0x640`                         | raw 12-bit count; register word = `0x6400` (<< 4) | |
| 80 °C            | `0x500`                         | raw 12-bit count; register word = `0x5000` (<< 4) | |
| 75 °C            | `0x4B0`                         | raw 12-bit count; register word = `0x4B00` (<< 4) | TLOW default = 75 °C |
| 50 °C            | `0x320`                         | raw 12-bit count; register word = `0x3200` (<< 4) | 50/0.0625 = 800 = 0x320 |
| 25 °C            | `0x190`                         | raw 12-bit count; register word = `0x1900` (<< 4) | 25/0.0625 = 400 = 0x190 |
| 0.25 °C          | `0x004`                         | raw 12-bit count; register word = `0x0040` (<< 4) | |
| 0 °C             | `0x000`                         | raw 12-bit count; register word = `0x0000` (<< 4) | |
| -0.25 °C         | `0xFFC`                         | raw 12-bit two's complement; register word = `0xFFC0` (<< 4) | 0xFFC = -4 counts |
| -25 °C           | `0xE70`                         | raw 12-bit two's complement; register word = `0xE700` (<< 4) | 400 counts; two's complement of 0x190 |
| -55 °C           | `0xC90`                         | raw 12-bit two's complement; register word = `0xC900` (<< 4) | |

The datasheet also gives a 13-bit (Extended Mode) table (Table 6-3); those
values are three bits wider and the register word will place the 13-bit count
in bits 15:3 with the LSB of byte 2 set to 1.