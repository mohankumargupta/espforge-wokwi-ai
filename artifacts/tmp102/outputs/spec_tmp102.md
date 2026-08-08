# Chip Spec: TMP102

**Manufacturer:** Texas Instruments  
**Category:** temperature  
**Transports:** I²C (Two-Wire / SMBus compatible)

## Overview

The TMP102 is a low-power, two-wire serial interface digital temperature sensor
in a tiny SOT563 package. It requires no external components and reads
temperature at 0.0625°C resolution over –40°C to +125°C. It supports SMBus and
two-wire interfaces, allows up to four devices per bus (via the ADD0 pin), and
features a configurable ALERT/thermostat function with comparator and interrupt
modes. Typical active quiescent current is 10µA, 1µA in shutdown, and the
supply range is 1.4V to 3.6V. It is used for thermal management and thermal
protection in battery, portable, consumer, industrial, and instrumentation
applications.

## Transport Configuration

### I²C
- **Address:** `0x48` (default, ADD0=GND) — `0x49` (ADD0=V+), `0x4A` (ADD0=SDA), `0x4B` (ADD0=SCL)
- **Max clock:** 400 kHz (Fast mode); 3.4 MHz with Hs-mode master code (2.75 MHz max when `V+` < 1.7V)
- **Endianness / Byte Order:** Big-Endian (MSB first — most significant byte is sent first)
- **Protocol Quirks:**
  - The 8-bit Pointer Register (2 LSBs) selects which data register is accessed.
  - A write operation must always send the Pointer Register byte after the slave address.
  - Reads use the last Pointer value written; change pointer by issuing a write of just the pointer byte, then a START + slave address with R/W high.
  - The device remembers the pointer value until the next write (no repeated pointer needed for repeated reads of the same register).
  - SDA and SCL are open-drain with integrated spike-suppression filters and Schmitt triggers.
  - Serial interface resets if SCL is held low for 30ms (typical) — SCL must stay ≥ 1kHz.
  - Supports General Call reset (0000000 + 00000110 second byte).

### SPI
Not applicable.

## Physical pins names and functions

| Pin Number | Pin Name | Description
|------------|----------|------------
| 1          | SCL      | Serial clock input (open-drain, requires pull-up)
| 2          | GND      | Ground
| 3          | ALERT    | Alert/thermostat output (open-drain, requires pull-up)
| 4          | ADD0     | Address select pin: GND→0x48, V+→0x49, SDA→0x4A, SCL→0x4B
| 5          | V+       | Supply voltage (1.4V to 3.6V)
| 6          | SDA      | Serial data input/output (open-drain, requires pull-up)

Package: SOT563 (DRL), 6-pin, package marking CBZ.

## Bus and addressing Rules

- Up to four TMP102 devices per bus via the ADD0 pin; each ADD0 connection
  selects a distinct 7-bit slave address:
  - ADD0 = GND → 1001000 (0x48)
  - ADD0 = V+  → 1001001 (0x49)
  - ADD0 = SDA → 1001010 (0x4A)
  - ADD0 = SCL → 1001011 (0x4B)
- Slave address byte = 7 address bits + R/W bit.
- Fast mode (I2C Fast/Low 1kHz–400kHz) and High-Speed/Hs-mode (up to 3.4MHz,
  requires Hs-mode master code `00001xxx`, not acknowledged).
- Responds to SMBus Alert Response address (`00011001`) in Interrupt mode.
- Responds to General Call address `0000000` (8th bit = 0); second byte
  `00000110` resets internal registers to power-up values.
- Pull-up resistors required on SCL, SDA, and ALERT; 0.01µF bypass cap
  recommended on V+.

## Interrupts / Alert Pins

- **Pin Type:** Open-drain (requires pull-up)
- **Polarity:** Configurable via POL bit (`0` = active-low, `1` = active-high)
- **Latch Behavior:** 
  - Comparator mode (TM=0): ALERT asserts while temp ≥ THIGH (after fault queue);
    de-asserts when temp < TLOW for same number of faults. 
  - Interrupt mode (TM=1): ALERT latches; cleared only by a read of any register,
    SMBus Alert Response, shutdown mode, or general-call reset.
- **Clear Mechanism:** Comparator mode clears itself on TLOW; Interrupt mode
  clears on any register read or SMBus Alert Response (latched).
- **Fault Queue (F1/F0):** consecutive fault count of 1, 2, 4, or 6.

## Register Map

| Address | Name | R/W | Reset | Description |
|---------|------|-----|-------|-------------|
| `0x00`  | Temperature Register | R   | `0x0000` (reads 0°C until first conversion done) | 12/13-bit temperature result |
| `0x01`  | Configuration Register | R/W | `0x60A0` (byte1=0x60, byte2=0xA0) | operational mode control |
| `0x02`  | TLOW Register | R/W | +75°C (0x04B0) | low thermostat limit |
| `0x03`  | THIGH Register | R/W | +80°C (0x0500) | high thermostat limit |

The 8-bit Pointer Register uses bits P1:P0 (LSBs) to select the data register;
P2–P7 must be `0` during a write. Power-up reset value of P1/P0 = `00`
(Temperature register).

### Bit Fields

#### Configuration Register (`0x01`)

Byte 1 (most significant, defaults `0x60`):

| Bits | Name | Description |
|------|------|-------------|
| 7    | OS   | One-Shot start: write 1 in shutdown mode starts a single conversion; reads 0 during conversion, 1 when complete |
| 6    | R1   | Converter resolution (read-only), power-up `11` (12-bit) |
| 5    | R0   | Converter resolution (read-only) |
| 4    | F1   | Fault queue setting |
| 3    | F0   | Fault queue setting (00=1, 01=2, 10=4, 11=6) |
| 2    | POL  | ALERT pin polarity (0=active low, 1=active high) |
| 1    | TM   | Thermostat mode (0=Comparator, 1=Interrupt) |
| 0    | SD   | Shutdown mode (1=shutdown; device shuts down after current conversion) |

Byte 2 (defaults `0xA0`):

| Bits | Name | Description |
|------|------|-------------|
| 7    | CR1  | Conversion rate high bit |
| 6    | CR0  | Conversion rate low bit (00=0.25Hz, 01=1Hz, 10=4Hz default, 11=8Hz) |
| 5    | AL   | Active-low alert status (read-only); POL inverts polarity of data |
| 4    | EM   | Extended mode (1 = 13-bit), 0 = Normal (12-bit, TMP75-compatible |
| 3:0  | —    | Reserved; always `0` |

## Initialization Sequence & State Machine for emulating chip, timings

1. On power-up or general-call reset, immediately start a first conversion; the
   result is available after 26ms (typical), 35ms (max).
2. Default conversion rate is 4Hz (CR1=1, CR0=0): device converts (typ 26ms,
   ~40µA) then powers down and waits the CR-configured delay.
3. To read temperature:
   - Write slave address (R/W=0), then pointer `0x00` (Temperature register).
   - Send START + slave address with R/W=1; read 2 bytes (MSB first).
4. Timeout function: if SCL is held low for, the serial interface resets (pin
   release) — maintain at least 1kHz bus speed to avoid it.
5. Shutdown mode: set SD=1; device shuts down after completing current
   conversion. One-shot startup via OS bit.

## Data Conversion

<!-- Formulas mapping raw register values to real-world units. -->

- **Data Type:** signed two's complement; bit 15 MSB is the sign bit.
- **Alignment:** 12-bit value left-aligned in a 16-bit register (bits 15:4);
  lower 4 bits (bits 3:0) of byte 3 read as `0`.
- **Extended mode (EM=1):** 13-bit value left-aligned in bits 15:3; bit 2:1 read
  `0`, bit 0 reads `1` (order: D7–D1 = T4–T0, D0 = 1).
- **One LSB = 0.0625°C.**

```
temp_C = (signed_16bit_word >> shifts) * 0.0625
```

where `shifts = 4` for 12-bit Normal mode, `shifts = 3` for 13-bit Extended mode.

### Worked Examples / Test Vectors

Datasheet Table 5 values are written as a **12-bit two's-complement count** at
`0000 0000 0000` granularity; the hex shown corresponds to that 12-bit value
**in the register word**, i.e., byte1 `T11..T4`, byte2 `T3..T0 0000` 
(EspHome reads 16-bit the 12-bit word and then does `raw >> 4`).

| Real-world Value | Raw Register Value (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|---------------------------------|--------------------------------------------------------------------|-------|
| +127.9375 °C | 0x7FF, `0111 1111 1111` | raw 12-bit count (word = count<<4, bits 15:4) | max positive count in Normal mode |
| +100 °C | 0x640, `0110 0100 0000` | raw 12-bit count (word = count<<4, bits 15:4) | |
| +80 °C | 0x500, `0101 0000 0000` | raw 12-bit count (word = count<<4, bits 15:4) | THIGH power-up value |
| +75 °C | 0x4B0, `0100 1011 0000` | raw 12-bit count (word = count<<4, bits 15:4) | TLOW power-up value |
| +50 °C | 0x320, `0011 0010 0000` | raw 12-bit count (word = count<<4, bits 15:4) | |
| +25 °C | 0x190, `0001 1001 0000` | raw 12-bit count (word = count<<4, bits 15:4) | |
| +0.25 °C | 0x004, `0000 0000 0100` | raw 12-bit count (word = count<<4, bits 15:4) | |
| 0 °C | 0x000, `0000 0000 0000` | raw 12-bit count (word = 0x0000) | |
| −0.25 °C | 0xFFC, `1111 1111 1100` | raw 12-bit two's-complement count (word = count<<4) | |
| −25 °C | 0xE70, `1110 0111 0000` | raw 12-bit two's-complement count (word = count<<4) | |
| −55 °C | 0xC90, `1100 1001 0000` | raw 12-bit two's-complement count (word = count<<4) | |

> **Critical encoding note:** the HEX column of datasheet Table 5 gives the
> **raw 12-bit count** (e.g. `190` = 400 counts for +25°C). In the 16-bit
> register word this count is **left-aligned into bits 15:4** with bits 3:0 = 0,
> i.e. the word read from the I²C bus is `count << 4` (`0x1900` for +25°C).
> ESPHome reads the full 16-bit word, does `raw >> 4`, then multiplies by
> 0.0625. Verify: `0x190` = 400; `400 × 0.0625 = 25°C`.

13-bit Extended-mode format (EM=1), 13-bit two's complement, count left-aligned
into bits 15:3 (bit 0 of byte 2 reads `1`):

| Real-world | Raw Register Value | Encoding |
|------------|--------------------|----------|
| +150 °C    | 0x0960, `0 1001 0110 0000` | raw 13-bit count (word = count<<3) |
| +128 °C    | 0x0800, `0 1000 0000 0000` | raw 13-bit count (word = count<<3) |
| +100 °C    | 0x0640, `0 0110 0100 0000` | raw 13-bit count (word = count<<3) |
| −55 °C     | 0x1C90, `1 1100 1001 0000` | raw 13-bit two's-complement count |