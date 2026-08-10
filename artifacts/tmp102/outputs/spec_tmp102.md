# Chip Spec: TMP102

**Manufacturer:** Texas Instruments  
**Category:** temperature  
**Transports:** I²C

## Overview

The TMP102 is a low-power, two-wire (I²C) serial output digital temperature
sensor in a tiny SOT563 (6-pin) package. It reads temperature to a resolution
of 0.0625°C with a 12-bit ADC (13-bit in Extended mode), requires no external
components (only bus pull-ups and an optional 0.01µF bypass capacitor), and is
specified for operation over -40°C to +125°C. It is SMBus and two-wire
interface compatible, supports up to four devices on one bus via the ADD0
address pin, and features an ALERT pin (SMBus Alert) plus Shutdown and One-Shot
modes for reduced power consumption. It draws 10µA active / 1µA shutdown (max).
Used for thermal management/protection, battery management, notebooks, and
general temperature measurement.

## Transport Configuration

### I²C
- **Address:** `0x48` (default) — `0x49`/`0x4A`/`0x4B` (alternates, selected by ADD0 pin)
- **Max clock:** 400 kHz (Fast mode); 3.4 MHz (High-Speed mode, V+ > 1.7V); 2.75 MHz (High-Speed mode, V+ < 1.7V). Minimum SCL: 1 kHz (below this the 30 ms SCL-low timeout resets the interface).
- **Endianness / Byte Order:** Big-Endian (MSB byte first, then LSB byte)
- **Protocol Quirks:**
  - The device operates as a slave only and never drives SCL.
  - Register access is via an internal 8-bit Pointer Register (two LSBs select the data register). The pointer value is latched by a write and remembered until changed, so repeated reads of the same register need no pointer re-write.
  - A read of a register that follows a write pointer byte requires a (repeated) START: write address (R/W=0) + pointer byte, then START + address (R/W=1) to read.
  - All data bytes are transmitted MSB first.
  - The Temperature/THIGH/TLOW registers are 16-bit two-byte quanta ("word" format). A single-byte read of the MSB only is also allowed (terminate with NACK/STOP).
  - Supports General Call reset (0000110). Responds to Hs-mode master code (00001xxx, no ACK). Supports SMBus Alert Response (00011001).
  - SDA open-drain, requires external pull-up.

### SPI
Not applicable — the TMP102 has no SPI interface.

## Physical pins names and functions

SOT563 (DRL package), 6 pins. Top view, pin 1 = SCL.

| Pin Number | Pin Name | Description
|------------|----------|------------
| 1          | SCL      | Serial clock input (two-wire/SMBus clock). Pull-up required.
| 2          | GND      | Ground
| 3          | ALERT    | Alert/alarm output (open-drain). Pull-up required. SMBus Alert capable; polarity configurable (POL bit).
| 4          | ADD0     | Address select pin ("Address 0"). Sets device slave address; can be tied to GND, V+, SDA, or SCL.
| 5          | V+       | Power supply, 1.4V to 3.6V
| 6          | SDA      | Serial data, open-drain bidirectional I/O. Pull-up required.

## Bus and addressing Rules

- Slave address is 7 bits: `1001` + A1 + A0 + RW. A1/A0 are determined by the ADD0 pin connection, allowing up to four TMP102 devices on one bus.

| ADD0 Pin Connection | A1 A0 | Two-Wire Slave Address (Binary) | Slave Address (Hex, 7-bit) |
|---------------------|-------|---------------------------------|----------------------------|
| Ground              | 0 0   | 1001000                         | 0x48 (default)             |
| V+                  | 0 1   | 1001001                         | 0x49                        |
| SDA                 | 1 0   | 1001010                         | 0x4A                        |
| SCL                 | 1 1   | 1001011                         | 0x4B                        |

- Clock speeds: 1 kHz to 400 kHz (Fast mode); up to 3.4 MHz (Hs-mode, V+ > 1.7V) or 2.75 MHz (V+ < 1.7V).
- SCL, SDA, and ALERT pins require external pull-up resistors (typical for a two-wire bus).
- SCL held low for 30 ms (typ) triggers a serial-interface timeout reset (device releases bus and waits for START).

## Interrupts / Alert Pins

- **Pin Type:** Open-drain (requires external pull-up of ~5kΩ or less; an RC filter RF < 5kΩ / CF > 10nF may be added on V+ for noise)
- **Polarity:** Configurable via the POL bit. POL = 0 → Active-Low (default); POL = 1 → Active-High (state inverted).
- **Latch Behavior:** Depends on Thermostat Mode (TM bit):
  - **Comparator mode (TM = 0):** ALERT asserts when temperature ≥ THIGH for the programmed consecutive faults; deasserts when temperature falls below TLOW for the same number of faults (self-clearing, no read required; ignores state of TM for the AL status bit).
  - **Interrupt mode (TM = 1):** ALERT asserts when temperature ≥ THIGH for consecutive faults; stays asserted until cleared (see below); re-asserts only after temperature falls below TLOW then exceeds THIGH again.
- **Clear Mechanism:** In Interrupt mode, cleared by (a) a read operation of any register, (b) a successful response to the SMBus Alert Response address (device returns its slave address, with LSB indicating THIGH/TLOW cause), or (c) placing the device in Shutdown mode. A General Call reset returns the device to Comparator mode (TM = 0). If multiple devices respond to the SMBus Alert command, the lowest address wins arbitration and clears its ALERT.
- **Fault Queue (F1/F0):** consecutive fault count before ALERT asserts: 1, 2, 4, or 6.
- **AL bit (config register bit 5):** read-only, reports comparator-mode status (inverted by POL).

## Register Map

Registers are selected via the Pointer Register (two LSBs, P7:P2 must be 0 during writes). Power-up pointer value = `00` (Temperature register). All 16-bit registers are written/read as two bytes, MSB first.

| Address | Name        | R/W | Reset      | Description |
|---------|-------------|-----|------------|-------------|
| `0x00`  | Temperature | R   | 0x0000     | Most recent conversion result, 12-bit (Normal mode) or 13-bit (Extended mode), two's complement, left-aligned. Reads 0°C until first conversion completes. |
| `0x01`  | Configuration| R/W | 0x60A0   | 16-bit control register. Byte 1 (MSB) compatible with TMP75/TMP275 config register. |
| `0x02`  | TLOW        | R/W | 0x4B00    | Low-limit temperature; same data format as Temperature register. Reset = +75°C. |
| `0x03`  | THIGH       | R/W | 0x5000    | High-limit temperature; same data format as Temperature register. Reset = +80°C. |

### Pointer Register Byte

| P7 | P6 | P5 | P4 | P3 | P2 | P1 | P0 |
|----|----|----|----|----|----|----|----|
| 0  | 0  | 0  | 0  | 0  | 0  | Register select bits |

| P1 | P0 | Register |
|----|----|----------|
| 0  | 0  | Temperature Register (Read Only) |
| 0  | 1  | Configuration Register (Read/Write) |
| 1  | 0  | TLOW Register (Read/Write) |
| 1  | 1  | THIGH Register (Read/Write) |

### Bit Fields

#### `Temperature` (`0x00`) — two bytes

Byte 1 (MSB): D7..D0 = T11..T4 (Normal) / T12..T5 (Extended)
Byte 2 (LSB): D7..D0 = T3..T0, then 0,0,0,0 (Normal) / T4..T0 then 0,0,1 (Extended)

**Byte 1 (MSB first)**

| Bits | Name | Description |
|------|------|-------------|
| 7:0  | T11:T4 | Temperature magnitude bits 11:4 (12-bit Normal). Extended mode: T12:T5 (13-bit). |
|       | (T12:T5) | |

**Byte 2 (LSB last)**

| Bits | Name | Description |
|------|------|-------------|
| 7:4  | T3:T0 | Temperature magnitude bits 3:0 (Normal). Extended mode: T4:T1. |
| 3:1  | —     | Always read `0`. |
| 0    | —     | Data-format flag: `0` = Normal mode (EM=0), `1` = Extended mode (EM=1). |

Data is 12-bit (13-bit in Extended mode) two's complement, left-aligned in the
16-bit register word (bits 15:4 in Normal; bits 15:3 in Extended). One LSB =
0.0625°C. Negative numbers are two's complement. Unused bits always read 0
(except extended-mode bit 0 which is 1). The register is read-only.

#### `Configuration` (`0x01`) — 16-bit R/W, reset 0x60A0

**Byte 1 (MSB), bits 15:8 — same bit layout as TMP75/TMP275 configuration**

| Bits | Name | Description |
|------|------|-------------|
| 15   | OS    | One-Shot / Conversion Ready. In Shutdown mode, writing 1 starts one conversion; reads 0 during conversion, 1 when idle. (RW) |
| 14:13| R1:R0 | Converter Resolution — read-only, set to `11` at start-up (12-bit resolution). (RO) |
| 12:11| F1:F0 | Fault queue: 00=1, 01=2, 10=4, 11=6 consecutive faults to trigger ALERT. |
| 10   | POL   | ALERT polarity: 0 = active-low, 1 = active-high (inverts). |
| 9    | TM    | Thermostat mode: 0 = Comparator, 1 = Interrupt. |
| 8    | SD    | Shutdown mode: 1 = shut down after current conversion, 0 = continuous conversion. |

Reset value byte 1: `0110 0000` = 0x60.

**Byte 2 (LSB), bits 7:0**

| Bits | Name | Description |
|------|------|-------------|
| 7:6  | CR1:CR0 | Conversion rate: 00=0.25 Hz, 01=1 Hz, 10=4 Hz (default), 11=8 Hz. |
| 5    | AL    | Alert status (read-only). 1 until temp ≥ THIGH for programmed faults, then 0 (for POL=0); unaffected by TM. State inverted by POL. |
| 4    | EM    | Extended mode: 0 = Normal (12-bit), 1 = Extended (13-bit, allows >+128°C). |
| 3:0  | —     | Reserved, write `0`. |

Reset value byte 2: `1010 0000` = 0xA0.

#### `TLOW` / `THIGH` (`0x02` / `0x03`) — 16-bit R/W

Same data format as the Temperature register (12-bit Normal / 13-bit Extended),
two's complement, left-aligned, MSB byte first. Power-up reset: THIGH = +80°C
(0x5000), TLOW = +75°C (0x4B00).

## Initialization Sequence & State Machine for emulating chip, timings

1. Apply power (1.4V–3.6V) or issue General Call reset (0x0000110). Device starts a conversion immediately upon power-up/reset.
2. Wait for first conversion to complete before reading: 26 ms typical, 35 ms max. Until the first conversion completes, Temperature register reads 0°C.
3. Read the Temperature register (pointer 0x00) as two bytes, MSB first. (Repeated START needed after pointer write.)
4. After each conversion, device powers down and waits for the interval set by CR1/CR0 (conversion rate), then converts again:
   - CR1:CR0 = 00 → 0.25 Hz (one conversion every 4 s)
   - CR1:CR0 = 01 → 1 Hz
   - CR1:CR0 = 10 → 4 Hz (default) — active quiescent current 7µA typ during delay, 40µA typ during conversion
   - CR1:CR0 = 11 → 8 Hz
5. Typical conversion time: 26 ms (min 26 typ, max 35 ms per EC table; timing diagram shows 26ms). Internal MCU wait timer must account for first-conversion latency (26–35 ms).
6. One-Shot mode: set SD=1, then write OS=1 to start a single conversion; OS reads 0 during conversion; device returns to shutdown on completion; read result after ~26 ms.
7. ALERT comparison: each new conversion result is compared against THIGH/TLOW and the fault queue (F1/F0) updates; if comparator/interrupt conditions met, ALERT pin asserts (open-drain, pulled low for POL=0).
8. Shutdown: with SD=1, device completes current conversion then goes to shutdown (<0.5µA); any read is still possible via the serial interface.

## Data Conversion

- **Data Type:** Two's complement (signed integer count)
- **Alignment:** 12-bit value left-aligned in a 16-bit register word: data occupies bits 15:4, bits 3:0 = 0 (Normal mode). In Extended mode the 13-bit value occupies bits 15:3, bit 0 = 1 (mode flag). The datasheet's "Digital Output (Binary)/Hex" columns list the raw 12-bit (or 13-bit) count, not the full 16-bit register word.
- **Scale:** 0.0625 °C/LSB

```
temp_c = raw_count * 0.0625
```

- Positive values: convert to 12-bit left-justified binary with MSB = 0 (no two's complement applied). E.g. (+50°C) / (0.0625 °C/count) = 800 = 0x320 = `0011 0010 0000`.
- Negative values: take absolute value count, two's complement it, and set MSB = 1. E.g. |-25°C| / 0.0625 = 400 = 0x190 = `0001 1001 0000`; two's complement → `1110 0110 1111` + 1 = `1110 0111 0000` = 0xE70.

### Worked Examples / Test Vectors

Table 5 (12-bit data format). "Raw Register Value" below is the datasheet's
**raw 12-bit two's-complement count**; the Full Register Word column shows how
it appears left-aligned in bits 15:4 of the 16-bit temperature word (bits 3:0 = 0).

| Real-world Value | Raw Register Value (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|---------------------------------|--------------------------------------------------------------------|-------|
| +128             | 0x7FF / `0111 1111 1111`         | raw 12-bit count                                                   | Two distinct table rows both map to 0x7FF (datasheet shows 128 and 127.9375 both = 0x7FF; 12-bit cannot represent +128 exactly — wraps to 127.9375) |
| +127.9375        | 0x7FF / `0111 1111 1111`         | raw 12-bit count                                                   | 0x7FF * 0.0625 = 127.9375 |
| +100             | 0x640 / `0110 0100 0000`         | raw 12-bit count → register word 0x6400                            | 1600 * 0.0625 = 100 |
| +80              | 0x500 / `0101 0000 0000`         | raw 12-bit count → register word 0x5000                            | 1280 * 0.0625 = 80 |
| +75              | 0x4B0 / `0100 1011 0000`         | raw 12-bit count → register word 0x4B00                            | 1200 * 0.0625 = 75 |
| +50              | 0x320 / `0011 0010 0000`         | raw 12-bit count → register word 0x3200                            | 800 * 0.0625 = 50 |
| +25              | 0x190 / `0001 1001 0000`         | raw 12-bit count → register word 0x1900                            | 400 * 0.0625 = 25 |
| +0.25            | 0x004 / `0000 0000 0100`         | raw 12-bit count → register word 0x0040                            | 4 * 0.0625 = 0.25 |
| 0                | 0x000 / `0000 0000 0000`         | raw 12-bit count → register word 0x0000                            | 0 |
| -0.25            | 0xFFC / `1111 1111 1100`         | raw 12-bit count → register word 0xFFC0                            | two's complement of 4 |
| -25              | 0xE70 / `1110 0111 0000`         | raw 12-bit count → register word 0xE700                            | two's complement of 0x190 |
| -55              | 0xC90 / `1100 1001 0000`         | raw 12-bit count → register word 0xC900                            | two's complement of 0x370 (880 * 0.0625 = 55) |

Table 6 (13-bit Extended-mode data format). Data occupies bits 15:3 of the word;
bit 0 of the word = 1 in Extended mode. Reference rows:

| Real-world Value | Raw Register Value (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|---------------------------------|--------------------------------------------------------------------|-------|
| +150             | 0x0960 / `0 1001 0110 0000`      | raw 13-bit count → register word 0x0960<<3 with bit0=1 = 0x4B01   | 2400 * 0.0625 = 150 |
| +128             | 0x0800 / `0 1000 0000 0000`      | raw 13-bit count → word data bits 15:3                            | 2048 * 0.0625 = 128 |
| +100             | 0x0640 / `0 0110 0100 0000`      | raw 13-bit count                                                    | 1600 * 0.0625 = 100 |
| +25              | 0x0190 / `0 0001 1001 0000`      | raw 13-bit count                                                    | 400 * 0.0625 = 25 |
| 0                | 0x0000 / `0 0000 0000 0000`      | raw 13-bit count                                                    | 0 |
| -0.25            | 0x1FFC / `1 1111 1111 1100`      | raw 13-bit count                                                    | two's complement of 4 |
| -25              | 0x1E70 / `1 1110 0111 0000`      | raw 13-bit count                                                    | two's complement of 0x190 |
| -55              | 0x1C90 / `1 1100 1001 0000`      | raw 13-bit count                                                    | two's complement of 0x370 |