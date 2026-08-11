# Chip Spec: SCD40

**Manufacturer:** Sensirion  
**Category:** environmental  
**Transports:** I²C

## Overview

The SCD40 is Sensirion's second-generation optical CO₂ sensor, built on the photoacoustic NDIR sensing principle (PASens®) with integrated CMOSens® signal conditioning. It includes an on-chip SHT4x temperature and humidity sensor used for signal compensation, enabling a highly integrated small form factor (10.1 × 10.1 × 6.5 mm³, LGA package). It is primarily used for indoor air quality (IAQ) monitoring, smart ventilation, and HVAC applications. The SCD40 (base accuracy variant) is specified for a CO₂ measurement range of 400 – 2000 ppm and is compatible with the WELL Building Standard™. The same die is also sold as SCD41 / SCD43 (improved/high accuracy, 400 – 5000 ppm, single-shot mode), distinguished via the `get_sensor_variant` command (0x202f).

## Transport Configuration

### I²C
- **Address:** `0x62` (fixed, 7-bit address, no alternate address)
- **Max clock:** 400 kHz (I²C standard and fast mode)
- **Endianness / Byte Order:** Big-Endian (MSB transmitted first)
- **Protocol Quirks:**
  - Command-based protocol (no register pointer). A 16-bit command word is sent first; commands are classified as "read", "write", "send command", or "send command and fetch result" sequences.
  - Data reads/writes consist of 16-bit data words, each followed by an 8-bit CRC-8 checksum. In write direction the checksum is **mandatory**; in read direction the master may ignore it.
  - Command words themselves are **not** followed by a checksum.
  - After writing the command, the master must wait the command's *execution time* (Table 9 in datasheet, 1–10000 ms) before issuing a read header; no other commands may be sent during a command's execution time.
  - `read_measurement` empties the buffer once read out, and returns a NACK if no data is available. Use `get_data_ready_status` to synchronize.
  - The `wake_up` command (0x36f6) is not acknowledged by the sensor.
  - `get_ambient_pressure` and `set_ambient_pressure` share command code `0xe000`; the I²C R/W bit differentiates them.

### SPI
Not applicable — the SCD40 is I²C only.

## Physical pins names and functions

LGA package, 6 pins (top view; the notched corner of the protection membrane marks pin 1):

| Pin Number | Pin Name | Description |
|------------|----------|-------------|
| 1 (notched corner) | VDDH | Supply voltage, IR source (must be connected to VDD on customer PCB) |
|  | VDD | Supply voltage (2.4 – 5.5 V DC, typically 3.3 or 5.0 V) |
|  | GND | Ground contact |
|  | SDA | I²C serial data, bidirectional, open-drain |
|  | SCL | I²C serial clock, open-drain |
|  | DNC | Do not connect — pads must be soldered to a floating pad on customer PCB |

Since the pin-number/layout figure was a diagram (omitted from extracted text), exact pad numbering beyond the pin-1 polarity mark should be confirmed against Figure 3 of the datasheet.

## Bus and addressing Rules

- Fixed 7-bit I²C address `0x62`; the eighth bit selects direction (0 = write, 1 = read).
- SDA and SCL are open-drain; both lines need external pull-up resistors (e.g. Rp = 10 kΩ, Figure 1 of datasheet). The microcontroller must only drive them low.
- Standard (≤100 kHz) and fast (≤400 kHz) mode are supported. SCL frequency 0 – 400 kHz.
- Power-up time: max 30 ms (after VDD ≥ 2.25 V, idle state). Soft-reset (reinit) time: max 30 ms.
- A low-noise supply (e.g. LDO) able to handle peak current (175 mA typ / 205 mA max at 3.3 V) must be used; unloaded supply ripple must not exceed 30 mV p-p.

## Interrupts / Alert Pins

None. The SCD40 has no interrupt or alert output pin. Data-ready indication is obtained by polling the `get_data_ready_status` command (0xe4b8), or inferred from the ACK/NACK status of `read_measurement`.

## Register Map

The SCD4x is command-based, not register-based. Command codes and their behavior:

| Command code | Name | I²C sequence type | Exec time [ms] | During meas. |
|--------------|------|-------------------|----------------|--------------|
| `0x21b1` | start_periodic_measurement | send command | – | no |
| `0xec05` | read_measurement | read | 1 | yes |
| `0x3f86` | stop_periodic_measurement | send command | 500 | yes |
| `0x241d` | set_temperature_offset | write | 1 | no |
| `0x2318` | get_temperature_offset | read | 1 | no |
| `0x2427` | set_sensor_altitude | write | 1 | no |
| `0x2322` | get_sensor_altitude | read | 1 | no |
| `0xe000` | set_ambient_pressure | write | 1 | yes |
| `0xe000` | get_ambient_pressure | read | 1 | yes |
| `0x362f` | perform_forced_recalibration | send command and fetch result | 400 | no |
| `0x2416` | set_automatic_self_calibration_enabled | write | 1 | no |
| `0x2313` | get_automatic_self_calibration_enabled | read | 1 | no |
| `0x243a` | set_automatic_self_calibration_target | write | 1 | no |
| `0x233f` | get_automatic_self_calibration_target | read | 1 | no |
| `0x21ac` | start_low_power_periodic_measurement | send command | – | no |
| `0xe4b8` | get_data_ready_status | read | 1 | yes |
| `0x3615` | persist_settings | send command | 800 | no |
| `0x3682` | get_serial_number | read | 1 | no |
| `0x3639` | perform_self_test | read | 10000 | no |
| `0x3632` | perform_factory_reset | send command | 1200 | no |
| `0x3646` | reinit | send command | 30 | no |
| `0x202f` | get_sensor_variant | read | 1 | no |
| `0x219d` | measure_single_shot | send command | 5000 | no |
| `0x2196` | measure_single_shot_rht_only | send command | 50 | no |
| `0x36e0` | power_down | send command | 1 | no |
| `0x36f6` | wake_up | send command | 30 | no |
| `0x2445` | set_automatic_self_calibration_initial_period | write | 1 | no |
| `0x2340` | get_automatic_self_calibration_initial_period | read | 1 | no |
| `0x244e` | set_automatic_self_calibration_standard_period | write | 1 | no |
| `0x234b` | get_automatic_self_calibration_standard_period | read | 1 | no |

(`measure_single_shot`, `measure_single_shot_rht_only`, `power_down`, `wake_up`, and the ASC period commands are SCD41/SCD43-only features; on SCD40 the single-shot commands are not available.)

### Bit Fields

#### `get_data_ready_status` — response word[0] (`0xe4b8`)

| Bits | Name | Description |
|------|------|-------------|
| 10:0 | DATA_READY | 0 → data not ready; non-zero → data ready for read-out |

#### `get_sensor_variant` — response word[0] (`0x202f`)

| Bits | Name | Description |
|------|------|-------------|
| 15:12 | VARIANT | `0000` → SCD40; `0001` → SCD41; `0101` → SCD43 (bits 11:0 may differ) |

## Initialization Sequence & State Machine for emulating chip, timings

1. Apply power. Wait ≤30 ms power-up time for the sensor to enter idle state (ready to receive commands).
2. (Optional configuration, only in idle state: e.g. `set_temperature_offset`, `set_sensor_altitude`, ASC settings — each ≤1 ms exec; send `persist_settings` [800 ms] to store to EEPROM.)
3. Send `start_periodic_measurement` (0x21b1). Signal update interval = 5 s. While periodic measurement runs, only `read_measurement`, `get_data_ready_status`, `stop_periodic_measurement`, `set/get_ambient_pressure` are allowed.
4. Wait for data-ready (≥5 s after start), then `read_measurement` (0xec05) — exec time 1 ms — to obtain CO₂, temperature, RH. Buffer empties on read.
5. To reconfigure, send `stop_periodic_measurement` (0x3f86); wait 500 ms before sending further commands (sensor returns to idle).
6. (SCD41/SCD43 — not SCD40) single-shot alternative: `wake_up` → `measure_single_shot` → wait 5000 ms → `read_measurement`.
7. Optional `perform_factory_reset` (1200 ms) to reset EEPROM and erase FRC/ASC history.

EEPROM config settings (temperature offset, sensor altitude, ASC enable/disable) are stored in RAM only until `persist_settings` is issued; guaranteed ≥2000 EEPROM write cycles.

## Data Conversion

- **Data Type:** Unsigned 16-bit integer words, MSB-first (Big-Endian). Range 0x0000 – 0xFFFF (0 – 65535). No sign extension, no left-alignment — the 16-bit count is the full register word.
- **Alignment:** Values occupy the full 16-bit word (bits 15:0), transmitted MSB first. No scaling/shifting between raw count and register word.

```
CO2[ppm] = word[0]
T[°C]    = -45 + 175 * word[1] / 65535
RH[%]    = 100 * word[2] / 65535
```

Other linear conversions:

```
Temperature offset[°C] = word[0] * 175 / 65535
Sensor altitude[m]      = word[0]
Ambient pressure[Pa]   = word[0] * 100
FRC correction[ppm]    = word[0] - 0x8000   (word[0] = 0xffff → FRC failed)
Serial number          = word[0] << 32 | word[1] << 16 | word[2]   (48-bit, big-endian)
ASC initial/standard period[hours] = word[0]
```

Each received/written data word is followed by an 8-bit CRC (polynomial 0x31, init 0xff, no reflection, no final XOR). CRC covers only the two preceding data bytes; verified example: `CRC(0xbeef) = 0x92`.

### Worked Examples / Test Vectors

All values below are the raw 16-bit unsigned count, transmitted MSB-first, equal to the full register word (no alignment/shift).

| Real-world Value | Raw Register Value (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|---------------------------------|--------------------------------------------------------------------|-------|
| CO₂ = 500 ppm | `0x01f4` (=500) | raw 16-bit count = full register word | read_measurement example, CRC = 0x33 |
| Temp = 25 °C | `0x6667` (=26215) | raw 16-bit count = full register word | -45 + 175·26215/65535 = 25.0 °C; CRC = 0xa2 |
| RH = 37 % | `0x5eb9` (=24249) | raw 16-bit count = full register word | 100·24249/65535 = 37.0 %; CRC = 0x3c |
| Temperature offset = 6.2 °C | `0x0912` (=2322) | raw 16-bit count = full register word | 2322·175/65535 = 6.2 °C; CRC = 0x63 |
| Temperature offset = 5.4 °C (write) | `0x07e6` (=2022) | raw 16-bit count = full register word | set_temperature_offset; CRC = 0x48 |
| Sensor altitude = 1950 m (write) | `0x079e` (=1950) | raw 16-bit count = full register word | set_sensor_altitude; CRC = 0x09 |
| Sensor altitude = 1100 m | `0x044c` (=1100) | raw 16-bit count = full register word | get_sensor_altitude; CRC = 0x42 |
| Ambient pressure = 98700 Pa (write/read) | `0x03db` (=987) | raw 16-bit count = full register word | 987·100 = 98700 Pa; CRC = 0x42 |
| FRC correction = −50 ppm (from 480 ppm ref vs 530 ppm sensor) | `0x7fce` (=32718) | raw 16-bit count = full register word | 0x7fce − 0x8000 = −50 ppm; CRC = 0x7b |
| FRC input target = 480 ppm (write) | `0x01e0` (=480) | raw 16-bit count = full register word | perform_forced_recalibration input; CRC = 0xb4 |
| ASC enabled (write) | `0x0001` | raw 16-bit count = full register word | set_automatic_self_calibration_enabled; CRC = 0xb0 |
| ASC disabled | `0x0000` | raw 16-bit count = full register word | get_automatic_self_calibration_enabled; CRC = 0x81 |
| ASC target = 435 ppm (write) | `0x01b3` (=435) | raw 16-bit count = full register word | set_automatic_self_calibration_target; CRC = 0x99 |
| ASC target = 420 ppm | `0x01a4` (=420) | raw 16-bit count = full register word | get_automatic_self_calibration_target; CRC = 0x4d |
| Data not ready | `0x8000` | raw 16-bit count = full register word | least significant 11 bits = 0 → not ready; CRC = 0xa2 |
| ASC initial period = 76 hours | `0x004c` (=76) | raw 16-bit count = full register word | get/set_automatic_self_calibration_initial_period; CRC = 0xc1 |
| ASC standard period = 156 hours | `0x009c` (=156) | raw 16-bit count = full register word | get/set_automatic_self_calibration_standard_period; CRC = 0xc5 |
| Variant = SCD40 | `0x0440` | raw 16-bit count = full register word | bits[15:12] = 0000 → SCD40; CRC = 0x3f |
| Variant = SCD41 | `0x1440` | raw 16-bit count = full register word | bits[15:12] = 0001 → SCD41; CRC = 0x51 |
| Variant = SCD43 | `0x5441` | raw 16-bit count = full register word | bits[15:12] = 0101 → SCD43; CRC = 0xe9 |
| Serial number example = 273'325'796'834'238 | words `0xf896`, `0x9f07`, `0x3bbe` | raw 16-bit counts = full register words | 48-bit big-endian; CRCs = 0x31, 0xc2, 0x89 |
| CRC check value | `0xbeef` → `0x92` | raw 16-bit count = full register word | CRC-8(0xbeef) = 0x92 per Table 40 |

## Performance Specifications (reference)

| Parameter | Value |
|-----------|-------|
| CO₂ output range | 0 – 40000 ppm |
| SCD40 CO₂ accuracy (400–2000 ppm) | ±(50 ppm + 5% of reading) |
| SCD40 CO₂ accuracy (400–1000 ppm) | ±(50 ppm + 2.5% of reading) |
| CO₂ repeatability | ±10 ppm |
| CO₂ response time (τ63, 400→2000 ppm step) | 60 s |
| Humidity range / accuracy (typ) | 0–100 %RH / ±6 %RH (15–35 °C, 20–65 %RH) |
| Temperature range / accuracy (typ) | −10–60 °C / ±0.8 °C (15–35 °C) |
| Supply voltage | 2.4 – 5.5 V DC (typ. 3.3 or 5.0 V) |