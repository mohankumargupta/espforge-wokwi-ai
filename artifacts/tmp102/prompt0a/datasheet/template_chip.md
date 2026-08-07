# Chip Spec: <ChipName>

**Manufacturer:** <Manufacturer>  
**Category:** <category directory, e.g. environmental, imu, temperature>  
**Transports:** <SPI | I²C | both | UART>

## Overview

<!-- One paragraph: what the chip does and why you'd use it. -->

## Transport Configuration

### I²C
- **Address:** `0x??` (default) — `0x??` (alternate, if applicable)
- **Max clock:** <e.g. 400 kHz>
- **Endianness / Byte Order:** <Big-Endian (MSB first) | Little-Endian (LSB first)>
- **Protocol Quirks:** <e.g. Requires Repeated Start for reads? Does the register pointer auto-increment during block reads?>

### SPI
- **Mode:** CPOL=? CPHA=? (Mode ?)
- **Max clock:** <e.g. 10 MHz>
- **Bit order:** MSB first
- **CS active:** low

## Physical pins names and functions

| Pin Number | Pin Name | Description
|------------|----------|------------

## Bus and addressing Rules

Default Address Configuration if applicable, clock speeds

## Interrupts / Alert Pins

- **Pin Type:** <Open-drain | Push-pull>
- **Polarity:** <Active-Low | Active-High | Configurable>
- **Latch Behavior:** <Latched until cleared | Pulses for N ms>
- **Clear Mechanism:** <How is it cleared? e.g., "Cleared by reading register 0x00" or "Cleared by writing 1 to bit 5">

## Register Map

| Address | Name | R/W | Reset | Description |
|---------|------|-----|-------|-------------|
| `0x00`  | NAME | R   | `0x00`| |

### Bit Fields

#### `REGISTER_NAME` (`0x00`)

| Bits | Name | Description |
|------|------|-------------|
| 7:4  | FIELD_A | |
| 3:0  | FIELD_B | |

## Initialization Sequence & State Machine for emulating chip, timings

1. <step>
2. <step>
3. Wait <N> ms for <reason>

## Data Conversion

<!-- Formulas mapping raw register values to real-world units. -->
<!-- CRITICAL: Explicitly state Data Type, Alignment, and Sign Extension -->

- **Data Type:** <e.g., Two's complement, Unsigned integer, Offset binary>
- **Alignment:** <e.g., 12-bit value left-aligned in a 16-bit register (bits 15:4)>

```
value = raw * <scale> + <offset>
```

### Worked Examples / Test Vectors
<!-- CRITICAL: Extract any tables or examples from the datasheet that show specific real-world values and their corresponding raw hex/binary register values. These are required for downstream unit tests. -->

| Real-world Value | Raw Register Value (Hex/Binary) | Notes |
|------------------|---------------------------------|-------|
|                  |                                 |       |
```
