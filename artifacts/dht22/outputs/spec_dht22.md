# Chip Spec: DHT22

**Manufacturer:** Aosong Electronics Co., Ltd  
**Category:** environmental  
**Transports:** Single-wire proprietary bus (single-bus, not I²C / SPI / UART)

## Overview

The DHT22 (also named AM2302) is a digital-output relative-humidity and temperature
sensor/module using a capacitive-type humidity sensing element with full-range
temperature compensation. It outputs a calibrated digital signal over a proprietary
single-wire (single-bus) interface. Every sensor is calibrated in an accurate
calibration chamber with its calibration coefficients stored in OTP memory. Low
power consumption, small size, long transmission distance (up to 20 m), and
single-row four-pin packaging make it suited for harsh application environments.
Only one sensor is addressable per DATA line (the module has no addressing).

## Transport Configuration

### Single-wire (proprietary "single-bus")

- **Signal:** single bidirectional DATA line, open-drain/pull-up driven
- **Idle state:** bus high (free status = high voltage level)
- **External pull-up resistor:** required on DATA (≈4.7 kΩ recommended; datasheet
  shows "RL pull up bus's voltage")
- **Timing summary (MCU ↔ sensor):**
  - Start signal: host pulls bus low for **at least 1 ms**, then releases and waits **20–40 µs**
  - Sensor response: low **80 µs**, then high **80 µs** (preparation)
  - Each data bit: low **50 µs**, then high:
    - **26–28 µs** high → data "0"
    - **70 µs** high → data "1"
  - Sensor transmits high data bit first (MSB first)
- **One communication cycle:** ≈ 5 ms (single time communication)
- **Minimum sensing period / sampling rate:** > 2 s (average sensing period 2 s)
- **Power-up settling:** no instruction within the first 1 s after power-on;
  optional 100 nF decoupling capacitor between VDD and GND

## Physical pins names and functions

Pin sequence is counted from left to right (single-row 4-pin package).

| Pin Number | Pin Name | Description |
|------------|----------|------------|
| 1          | VDD      | Power supply (3.3–6 V DC) |
| 2          | DATA     | Signal (single-bus bi-directional data) |
| 3          | NULL     | No connection (NC) |
| 4          | GND      | Ground |

## Bus and addressing Rules

- No device addressing: one DHT22 per DATA line.
- Communication is host-initiated only. Without a start signal from the MCU the
  sensor does NOT respond. One start signal yields one 40-bit response; after the
  data is collected the sensor returns to low-power-consumption mode if no further
  start signal is received.
- Data frame: **40 bits** (5 bytes), transmitted MSB first:

```
DATA = 8-bit integral RH + 8-bit decimal RH + 8-bit integral T + 8-bit decimal T + 8-bit check-sum
```

- Checksum: the last 8 bits must equal the last 8 bits of
  "integral RH + decimal RH + integral T + decimal T" (i.e. the low byte of the
  sum of the four data bytes).
- Electrical characteristics: supply 3.3–6 V DC (typ. 5 V), measuring current
  1–1.5 mA, stand-by 40–50 µA, collecting period ≥ 2 s.
- Operating range: humidity 0–100 %RH, temperature −40 … +80 °C.

## Interrupts / Alert Pins

- **Pin Type:** N/A — the DHT22 has no interrupt/alert output pin. All data (and
  the sensor response) is carried on the single DATA line.
- If the sensor's signal is always high voltage level, the sensor is not working
  properly (check electrical connection).

## Register Map

Not a register-mapped device. The sensor exposes a single 40-bit (5-byte) output
data frame on the DATA line.

| Byte index | Name | R/W | Reset | Description |
|------------|------|-----|-------|-------------|
| 0          | RH_INT | R (from sensor) | – | Humidity integral part (8-bit) |
| 1          | RH_DEC | R (from sensor) | – | Humidity decimal part (8-bit) |
| 2          | T_INT  | R (from sensor) | – | Temperature integral part (8-bit, sign in MSB) |
| 3          | T_DEC  | R (from sensor) | – | Temperature decimal part (8-bit) |
| 4          | CHECK  | R (from sensor) | – | Checksum = low 8 bits of (byte0+byte1+byte2+byte3) |

### Bit Fields

#### Output data frame — 40 bits (`low 50 µs + high pulse per bit`)

| Bits | Name | Description |
|------|------|-------------|
| 39:32 | RH_INT      | Humidity integral part (8-bit unsigned, 0–100) |
| 31:24 | RH_DEC      | Humidity decimal part (8-bit unsigned) |
| 23:16 | T_INT       | Temperature integral part (8-bit, bit 15 of full T word is the sign) |
| 15:8  | T_DEC       | Temperature decimal part (8-bit unsigned) |
| 7:0   | CHECK       | Checksum = low byte of the sum of the four preceding bytes |

## Initialization Sequence & State Machine for emulating chip, timings

Timing values are per the datasheet; reference an ESPHome-style ISR bit sampler
(see the emulator/QA test harness) for the rising/falling-edge transitions.

1. **Idle:** bus held high (pull-up), sensor in low-power-consumption mode.
2. **Power-up:** wait 1 s before the first instruction (unstable status). (sensor
   requires sampling interval > 2 s between reads.)
3. **Start signal (MCU → sensor):** pull DATA low for **≥ 1 ms** (DFH22 low),
   then release; bus pulled high by the pull-up resistor.
4. **Wait for response:** MCU waits **20–40 µs** after releasing the bus.
5. **Response signal (sensor → MCU):** sensor pulls low for **80 µs**, then
   releases high for **80 µs**.
6. **40-bit data transmission (sensor → MCU):** for each bit, sensor pulls low
   for **50 µs**, then:
   - high for **26–28 µs** → bit "0"
   - high for **70 µs** → bit "1"
7. **End:** AFTER the final bit, the sensor releases the bus high (pull-up) so
   the line returns to idle for the next transmission.
8. Wait **> 2 s** (collecting period) before the next start signal. The sensor
   returns to low-power-consumption mode if no further start signal is issued.

## Data Conversion

- **Data Type:** Humidity = unsigned integer (16-bit word = `(RH_INT << 8) | RH_DEC`,
  ÷10). Temperature = integer interpreted as signed (16-bit word =
  `(T_INT << 8) | T_DEC`, MSB (bit 15) is the sign bit), ÷10.
- **Alignment:** values are sent as full 16-bit words formed from integral-then-
  decimal bytes, transmitted MSB first. No left/right alignment within a register
  — the frame is a byte stream.
- **Resolution / sensitivity:** humidity 0.1 %RH, temperature 0.1 °C.
- **Accuracy:** humidity ±2 %RH (max ±5 %RH); temperature < ±0.5 °C.

```
humidity_%RH       = ((RH_INT << 8) | RH_DEC) / 10.0
temperature_C_raw  = (T_INT << 8) | T_DEC          // bit 15 = sign
temperature_C      = (bit15 set) ? -(raw & 0x7FFF) / 10.0 : raw / 10.0
checksum_ok        = ((RH_INT + RH_DEC + T_INT + T_DEC) & 0xFF) == CHECK
```

### Worked Examples / Test Vectors

The datasheet does **not** provide explicit worked-example (raw-to-real) tables.
The encoding statement above is inferred directly from the datasheet's 40-bit
frame definition: each full 16-bit value is formed as `integral<<8 | decimal`
and divided by 10, with the temperature sign carried in bit 15 of the 16-bit
temperature word (temperature range is −40 … +80 °C, so negative values must be
sign-encoded).

| Real-world Value | Raw Frame (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|------------------------|------------------------------------------------------------------|-------|
| 25.0 °C          | T bytes = `0x00` `0xFA` | full 16-bit word `0x00FA` = 250 → 250/10 = 25.0 | inferred from `T_INT<<8\|T_DEC`, ÷10 |
| 50.4 %RH         | RH bytes = `0x01` `0xF8`| full 16-bit word `0x01F8` = 504 → 504/10 = 50.4 | inferred from `RH_INT<<8\|RH_DEC`, ÷10 |
| −10.0 °C         | T bytes = `0x80` `0x00` | full 16-bit word `0x8000`, bit 15 set → −(0x0000)/10 = 0.0 (sign shown) | sign convention implied by −40…+80 °C range |

> These vectors are derived from the byte-stream encoding defined in the
> datasheet's data-frame formula; they are NOT tables printed in the datasheet.
> Downstream unit tests should treat real code/data samples (e.g. from an
> ESPHome-style read) as authoritative where available.