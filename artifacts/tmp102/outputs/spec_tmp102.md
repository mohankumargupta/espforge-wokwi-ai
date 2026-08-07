# Chip Spec: TMP102

**Manufacturer:** Texas Instruments
**Datasheet:** `datasheets/temperature/tmp102.pdf`
**Category:** temperature
**Transports:** I²C

## Overview

The TMP102 is a low-power digital temperature sensor designed as an NTC/PTC
thermistor replacement where high accuracy is required. It offers ±0.5°C typical
accuracy without calibration or external signal conditioning, and a highly linear
on-chip 12-bit ADC with a resolution of 0.0625°C (13-bit in Extended Mode).
It is packaged in a 1.6mm × 1.6mm SOT563 (DRL) package, operates from 1.4V to
3.6V with a maximum active quiescent current of 7.5µA, and is specified over
–40°C to 125°C. The device is compatible with SMBus, two-wire, and I²C, supports
the SMBus alert function, and allows up to four devices on one bus via the ADD0
address pin.

## Transport Configuration

### I²C
- **Address:** `0x48` (ADD0 = GND) — `0x49` (ADD0 = V+), `0x4A` (ADD0 = SDA), `0x4B` (ADD0 = SCL)
- **Max clock:** 400 kHz (Fast mode), 2.85 MHz (High-Speed mode)

### SPI
N/A — I²C/SMBus/two-wire only.

## Physical pins names and functions

DRL package, 6-pin SOT563 top view:

| Pin Number | Pin Name | Description
|------------|----------|------------
| 1 | SCL | Serial clock (I)
| 2 | GND | Ground
| 3 | ALERT | Overtemperature alert. Open-drain output; requires a pullup resistor (O)
| 4 | ADD0 | Address select. Connect to GND, V+, SDA, or SCL (I)
| 5 | V+ | Supply voltage, 1.4V to 3.6V (I)
| 6 | SDA | Serial data. Open-drain output; requires a pullup resistor (I/O)

## Bus and addressing Rules

- **Default address:** `0x48` with ADD0 tied to GND. Up to four devices per bus.
- **Address selection (Table 6-4):**

| Device two-wire address | ADD0 pin connection |
|---|---|
| 1001000 (`0x48`) | Ground |
| 1001001 (`0x49`) | V+ |
| 1001010 (`0x4A`) | SDA |
| 1001011 (`0x4B`) | SCL |

- All data bytes are transmitted MSB first.
- SCL, SDA, and ALERT are open-drain; recommend 5-kΩ pullup resistors (must not
  exceed 3 mA on any of those pins). A 0.01-µF supply bypass capacitor is recommended.
- Bus timeout: the serial interface resets if SCL is held low for 30 ms (typ,
  40 ms max) between a START and STOP condition. Keep SCL ≥ 1 kHz.
- High-Speed mode: host issues HS-mode controller code `0000 1xxx` after START
  (device does not ACK), then repeated START, then target address. Bus stays in
  HS mode until a STOP condition.
- General call `000 0000` (8th bit = 0) is acknowledged; second byte `0000 0110`
  resets internal registers to power-up values. The acquire command is not supported.

## Register Map

Registers are addressed via an 8-bit Pointer Register; only bits P1:P0 are used.
The pointer is set by the first byte written after the target address (R/W = 0)
and is remembered until the next write.

| Address | Name | R/W | Reset | Description |
|---------|------|-----|-------|-------------|
| `0x00`  | Temperature Register | R   | reads 0°C until first conversion | Most recent conversion result (12/13-bit) |
| `0x01`  | Configuration Register | R/W | `0x6180` | Control/status bits (see Bit Fields) |
| `0x02`  | TLOW Register | R/W | 75°C (0x04B0) | Low temperature limit, same format as temp register |
| `0x03`  | THIGH Register | R/W | 80°C (0x0500) | High temperature limit, same format as temp register |

Temperature register reset value is 0x0000 (reads 0°C) until the first conversion
completes; register data is zero until then.

### Bit Fields

#### `TEMPERATURE` (`0x00`) — Byte 1 (MSB first)

| Bits | Name | Description |
|------|------|-------------|
| 7:0  | T11:T4 (T12:T5 in Extended Mode) | 12-bit (13-bit) two's-complement temperature, MSB = sign |

#### `TEMPERATURE` (`0x00`) — Byte 2

| Bits | Name | Description |
|------|------|-------------|
| 7:4  | T3:T0 (T4:T0 in Extended Mode) | Low bits of temperature |
| 3:1  | — | Always 0 |
| 0    | EM indicator | 0 = normal (12-bit) format, 1 = Extended (13-bit) format |

#### `CONFIGURATION` (`0x01`) — Byte 1 (power-up/reset = `0x60`)

| Bits | Name | Description |
|------|------|-------------|
| 7    | OS | One-shot: write 1 in Shutdown mode starts a single conversion; reads 0 during conversion, 1 when done |
| 6:5  | R1:R0 | Converter resolution, read-only; reset `11` (12-bit temperature register) |
| 4:3  | F1:F0 | Fault queue: `00`=1, `01`=2, `10`=4, `11`=6 consecutive faults to trigger ALERT |
| 2    | POL | ALERT polarity: 0 = active low (default), 1 = active high |
| 1    | TM | Thermostat mode: 0 = Comparator mode (default), 1 = Interrupt mode |
| 0    | SD | Shutdown mode: 1 = shut down after current conversion (0.15µA typ) |

#### `CONFIGURATION` (`0x01`) — Byte 2 (power-up/reset = `0x80`)

| Bits | Name | Description |
|------|------|-------------|
| 7:6  | CR1:CR0 | Conversion rate: `00`=0.25 Hz, `01`=1 Hz, `10`=4 Hz (default), `11`=8 Hz |
| 5    | AL | Alert status, read-only (comparator-mode state of ALERT; polarity inverted by POL) |
| 4    | EM | Extended Mode: 0 = Normal 12-bit (default), 1 = Extended 13-bit |
| 3:0  | — | Always 0 |

#### `THIGH` (`0x03`) / `TLOW` (`0x02`)

Same format as the Temperature Register (Byte 1: H11:H4/L11:L4; Byte 2: H3:H0/L3:L0,
lower nibble = 0 in normal mode). Power-up values: THIGH = 80°C, TLOW = 75°C.
Values are compared against the temperature result on every conversion to drive
the ALERT pin.

## Initialization Sequence & State Machine for emulating chip, timings

1. Power up (V+ ≥ 1.4 V). Device resets to continuous-conversion mode at 4 Hz,
   configuration = `0x6180`.
2. First conversion completes in ~10 ms (typ, 15 ms max); temperature register
   reads 0°C until complete.
3. Read flow: START → target address + W (`0x90`) → pointer byte (e.g. `0x00`) →
   repeated START → target address + R (`0x91`) → read MSB → read LSB → NACK/STOP.
   For read of MSB only, host may terminate after a single byte.
4. Write flow: START → target address + W → pointer byte → data byte 1 (MSB) →
   data byte 2 (LSB) → STOP. Registers are updated byte by byte.
5. Timings: conversion time 10 ms typ (15 ms max); SCL low period ≥ 1.3 µs (fast) /
   210 ns (HS); data hold 100–900 ns (fast) / 25–105 ns (HS); timeout if SCL low
   > 30 ms.
6. Shutdown: set SD bit; current conversion completes then device sleeps (0.15 µA).
   One-shot: with SD = 1, write OS = 1; device wakes, converts (~10 ms), reads 1,
   returns to shutdown.

## Data Conversion

One LSB = 0.0625°C. Negative numbers are two's complement (MSB = 1). Resolution
is 12 bits in Normal mode, 13 bits in Extended mode.

```
// 12-bit signed two's-complement, MSB first in Byte 1 (T11..T4) + Byte 2 (T3..T0)
value = raw * 0.0625            // °C, for raw = 12-bit two's-complement int
```

Conversion examples (12-bit format):
- 50°C → 800 dec → `0x320` (0011 0010 0000)
- 25°C → 400 dec → `0x190` (0001 1001 0000)
- 0.25°C → 4 dec → `0x004`
- –25°C → two's complement of 400 → `0xE70` (1110 0111 0000)
- –0.25°C → `0xFFC` (1111 1111 1100)
