# Chip Spec: TMP102

**Manufacturer:** Texas Instruments  
**Category:** temperature  
**Transports:** I²C

## Overview

The TMP102 is a digital temperature sensor intended as a high-accuracy
replacement for NTC/PTC thermistors. It integrates a 12-bit (13-bit in Extended
mode) ADC giving 0.0625 °C resolution with accuracy of ±0.5 °C (typ) over
–25 °C to 85 °C without calibration. It uses a two-wire / SMBus / I²C interface,
supports up to four devices per bus via the ADD0 address pin, operates from
1.4 V to 3.6 V with 7.5 µA max active quiescent current, and provides an
overtemperature ALERT output.

## Transport Configuration

### I²C
- **Address:** `0x48` (ADD0 = GND, default) — alternates `0x49` (ADD0 = V+), `0x4A` (ADD0 = SDA), `0x4B` (ADD0 = SCL)
- **Max clock:** 400 kHz (Fast Mode); 2.85 MHz (High-Speed Mode, requires HS controller code `0000 1xxx`)
- **Endianness / Byte Order:** Big-Endian (MSB first)
- **Protocol Quirks:** Register pointer is set separately by a write of the
  pointer byte; it is NOT auto-incremented across block reads. Repeated reads
  of the same register do not need a new pointer write. Repeated START is used
  to change the register before a read. Time-out: SCL held low >30 ms (typ)
  resets the serial interface. The LSB of the temperature register may be
  omitted by terminating with a single-byte read.

### SPI
- Not supported (two-wire/SMBus only) — Mark the template's SPI section as N/A.

## Physical pins names and functions

| Pin Number | Pin Name | Description
|------------|----------|------------
| 1 | SCL | Serial clock (input). Requires pullup.
| 2 | GND | Ground.
| 3 | ALERT | Overtemperature alert. Open-drain output; requires pull-up resistor.
| 4 | ADD0 | Address select. Connect to GND, V+, SDA, or SCL.
| 5 | V+ | Supply voltage, 1.4 V to 3.6 V.
| 6 | SDA | Serial data (I/O). Open-drain output; requires pull-up resistor.

## Bus and addressing Rules

Default two-wire address is `1001000` (0x48) for a 7-bit address bus (plus R/W
bit). Up to four devices may share one bus using the ADD0 pin strap as follows:

| Device Two-Wire Address | ADD0 Pin Connection |
|---|---|
| 1001000 (0x48) | Ground |
| 1001001 (0x49) | V+ |
| 1001010 (0x4A) | SDA |
| 1001011 (0x4B) | SCL |

Clock speeds: Fast Mode 0.001–0.4 MHz; High-Speed Mode 0.001–2.85 MHz. SCL/SDA
must be pulled up via 5-kΩ (typ) pull-ups (≤ 3 mA). Operating supply V+ = 1.4 V
to 3.6 V (NOM 3.3 V).

## Interrupts / Alert Pins

- **Pin Type:** Open-drain (requires external pull-up, 5 kΩ recommended)
- **Polarity:** Configurable via POL bit; default Active-Low (POL=0), Active-High (POL=1)
- **Latch Behavior:**
  - Comparator Mode (TM=0): latches active while T ≥ THIGH; clears when T < TLOW (after fault count)
  - Interrupt Mode (TM=1): latches active until a read of any register, a successful SMBus Alert Response, Shutdown, or a General Call reset
- **Clear Mechanism:** Comparator Mode – temperature falling below TLOW; Interrupt Mode – cleared by reading any register, responding to SMBus Alert Response address (0001100 th address), or General Call reset
- Also exposes the SMBus Alert function: host sends alert command `0001 1001`; if ALERT active, device ACKs and returns its target address on SDA, with the LSB indicating T ≥ THIGH (low) or T < TLOW (high), polarity inverted per POL.
- **Fault queue:** programmable via F1/F0 bits to require 1, 2, 4, or 6 consecutive fault measurements.

## Register Map

| Address | Name | R/W | Reset | Description |
|---------|------|-----|-------|-------------|
| `0x00` | Temperature Register | R | `0x0000` | 12-bit (or 13-bit EM) signed temperature result; MSB byte first |
| `0x01` | Configuration Register | R/W | `0x6080` | Byte1 `0110 0000`, Byte2 `1000 0000` |
| `0x02` | TLOW Register | R/W | 75 °C | Low-limit threshold (same format as temperature) |
| `0x03` | THIGH Register | R/W | 80 °C | High-limit threshold (same format as temperature) |

Power-up reset: Temperature = 0x0000 (0 °C) until first conversion done
(~10 ms). THIGH reset = 80 °C, TLOW reset = 75 °C.

### Bit Fields

#### `TEMP_REG` (`0x00`) — 16-bit, read-only

Byte 1 (D7:D0 = T11:T4), Byte 0 (D7:D0 = T3:T0, then 0 0 0 0). In Extended
Mode (EM=1) a 13th bit is added, shifting to T12 (Byte0 bit D5 = T4..T0). Lower
NIBBLE of byte 0 always reads 0 in Normal mode; unused bits read 0. D0 of byte 1
indicates normal (0) vs extended (1) data format.

### Configuration Register (`0x01`) — 16-bit, R/W, ×MSB first

#### Byte 1 of Configuration (Reset `0110 0000`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | OS | One-Shot/Conversion-Read; write 1 in shutdown starts a single conversion; reads 0 during conv, 1 when ready |
| 6 | R1 | Converter resolution (read-only). Set to 1 at start-up for 12-bit. |
| 5 | R0 | Converter resolution (read-only). Set to 1 at start-up for 12-bit. |
| 4 | F1 | Fault queue 1/2/4/6 (with F0) |
| 3 | F0 | Fault queue: 00=1,01=2,10=4,11=6 consecutive faults |
| 2 | POL | Alert polarity: 0=active-low, 1=active-high |
| 1 | TM | Thermostat mode: 0=Comparator, 1=Interrupt |
| 0 | SD | Shutdown mode: 1=shutdown, 0=continuous |

#### Byte 2 of Configuration (Reset = `1000 0000`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | CR1 | Conversion rate MSB |
| 6 | CR0 | Conversion rate: 00=0.25 Hz, 01=1 Hz, 10=4 Hz (default), 11=8 Hz |
| 5 | AL | Alert (read-only). Comparator status (infers inversion). 1 until ≥ THIGH faults, then 0 until < TLOW. |
| 4 | EM | Extended Mode: 0=12-bit (Normal/TMP75 compat), 1=13-bit |
| 3:0 | — | Reserved (read as 0) |

## Conversion Rate Settings (CR1:CR0)

| CR1 | CR0 | Rate |
|-----|-----|------|
| 0 | 0 | 0.25 Hz |
| 0 | 1 | 1 Hz |
| 1 | 0 | 4 Hz (default) |
| 1 | 1 | 8 Hz |

## Initialization Sequence & State Machine for emulating chip, timings

1. Power-up / General-Call Reset Command (`0000 0110`, address `000 0000`) — loads defaults: continuous mode, 12-bit (EM=0), CR=4 Hz, R=11.
2. Immediately starts a conversion. First result available after ~10 ms (15 ms max).
3. Wait for conversion (~10 ms) for the temperature register to be valid; reads before first conversion return 0 °C until first conversion completes.
4. Continuous mode repeats a conversion, then sleeps delay set by CR (0.25/1/4/8 Hz) → next result.
5. To write configuration: send START, slave addr + W, pointer byte `0x01`, then Config Byte 1, then Config Byte 2. Registers maximize individually.
6. To read temperature: send START, slave addr + W, pointer `0x00`; then Repeated START, slave addr + R, read MSB byte, read LSB byte, NACK, STOP.
7. One-shot (OS) mode: set SD=1, then write OS=1; conversion run ~10 ms, result available, device returns to shutdown. 80+ conversions/sec are possible.
8. Conversion rates & timing: fast-mode SCL up to 400 kHz; HS-mode up to 2.85 MHz. SMBus timeout 30 ms (40 ms max) on SCL low.

## Data Conversion

- **Data Type:** Two's complement, signed (negative numbers in two's complement)
- **Alignment:** 12-bit value left-aligned in a 16-bit register (bits 15:4). In Extended Mode, 13-bit value occupies bits 15:3. Unused lower bits (3:0) always read 0.
- **Scale / Resolution:** 1 LSB = 0.0625 °C

```
temperature_degC = ((int16_t)raw >> 4) * 0.0625
```
(in Normal mode; in Extended mode shift by 15 bits then scale 0.0625, range to 150 °C).

Equivalently the raw left-justified value COUNT = temp / 0.0625 (0x0000 = 0 °C,
0x00h bits 15:4).

### Worked Examples / Test Vectors

| Real-world Value | Raw Register Value (Hex/Binary) | Notes |
|------------------|---------------------------------|-------|
| 128 °C | 0x7FF0 (0111 1111 1111 0000) | Max reading (12-bit) |
| 127.9375 °C | 0x7FF0 (0111 1111 1111 0000) | |
| 100 °C | 0x6400 (0110 0100 0000 0000) | |
| 80 °C | 0x5000 (0101 0000 0000 0000) | THIGH default |
| 75 °C | 0x4B00 (0100 1011 0000 0000) | TLOW default |
| 50 °C | 0x3200 (0011 0010 0000 0000) | 800 = 0x320 |
| 25 °C | 0x1900 (0001 1001 0000 0000) | 400 = 0x190 |
| 0.25 °C | 0x0040 (0000 0000 0100 0000) | 4 = 0x004 |
| 0 °C | 0x0000 | power-up |
| –0.25 °C | 0xFFC0 (1111 1111 1100 0000) | two's complement |
| –25 °C | 0xE700 (1110 0111 0000 0000) | |
| –55 °C | 0xC900 (1100 1001 0000 0000) | |

Extended Mode (13-bit) examples: 150 °C = 0x0960 (`0 1001 0110 0000`), –25 °C = 0x1E70 (`1 1110 0111 0000`).

Note: Downstream tests must left-shift the 12-bit hex column values by 4 to
obtain the stored 16-bit register word and interpret as signed two's complement.