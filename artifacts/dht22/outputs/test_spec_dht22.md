# Canonical Test Specification: DHT22

This specification is an intermediate, implementation-independent artifact.
It is the single source of truth from which simulator fixtures, firmware
configuration, and host-side integration tests are rendered.

Source inputs:

- `spec_dht22.md` (chip specification, derived from the Aosong DHT22 / AM2302
  datasheet)
- `dht.mdx` (ESPHome component documentation)
- `dht/` (ESPHome component source: `dht.cpp`, `dht.h`, `sensor.py`)

---

## Device

```yaml
device:

  name: DHT22

  manufacturer: Aosong Electronics Co., Ltd

  transport: single-wire (proprietary single-bus)
```

The DHT22 (also named AM2302) is a digital-output relative-humidity and
temperature sensor with a capacitive humidity element and full-range
temperature compensation. It exposes a single bidirectional DATA line; the
module has no address and no register map. One host-initiated start signal
yields one 40-bit data frame (MSB first).

---

## Primary Capability

The smallest observable scenario that demonstrates the primary functionality:

```
Measure ambient temperature
Measure relative humidity
```

Both observables are produced by the same 40-bit frame in a single host-initiated
read cycle.

---

## Observables

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 25.0

  - id: humidity
    type: float
    units: "%"
    default: 50.4
```

### default — single source of truth

The `default` values are the numeric ground truth. They are the values the
simulated device emits over the bus on first read and the values the test
harness asserts it observes in serial output. No downstream skill may choose
its own value.

The two defaults together form a single self-consistent 40-bit frame,
constructed from the `spec_dht22.md` inferred test vectors:

- temperature `25.0` C  → T bytes `0x00` `0xFA` (16-bit word `0x00FA` = 250 → 250/10)
- humidity `50.4` %     → RH bytes `0x01` `0xF8` (16-bit word `0x01F8` = 504 → 504/10)
- checksum `0xF3`       → low byte of `(0x01 + 0xF8 + 0x00 + 0xFA)` = low byte of `0x1F3`

Full frame byte stream (MSB first): `0x01 0xF8 0x00 0xFA 0xF3`

Source: `spec_dht22.md` "Worked Examples / Test Vectors" (inferred from the
datasheet frame formula; the datasheet prints no worked-example table).

Both observables carry `type: float` because the device has sub-unit
resolution of 0.1 (0.1 %RH, 0.1 °C) per `spec_dht22.md` "Resolution / sensitivity".

---

## Assumptions

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

The canonical test operates under ideal conditions: stable environment, correct
pull-up on DATA (~4.7 kΩ), the sensor settled past its 1 s power-on window, the
> 2 s collecting period has elapsed before the read, the start signal is applied
for >= 1 ms, and the full 40-bit response plus response preamble (80 µs low,
80 µs high) completes without timeout or checksum error.

---

## Excluded Features

The following functionality is intentionally excluded from the canonical test:

- calibration (factory calibration stored in OTP memory)
- self calibration
- EEPROM / OTP (not user-accessible)
- power management
- alarm thresholds
- interrupt / alert outputs (the device has no interrupt pin)
- diagnostics
- self tests
- fault injection
- low power modes
- model auto-detection (AUTO_DETECT fallback logic)
- DHT11-specific decode path (`dht.cpp` `DHT_MODEL_DHT11` branches)
- invalid-checksum / invalid-reading error paths (the canonical frame checksums clean)
- data-line timeout / error-code handling
- temperature sign-bit encoding (bit 15 of the temperature word)
- checksum mismatch behaviour

---

## Canonical Presentation

Precision values reflect the device resolution (0.1 for both observables)
and the ESPHome documentation recommendation of `accuracy_decimals: 1` for the
DHT22 (the `sensor.py` default of `0` applies only to the DHT11). Labels mirror
the ESPHome component's `dump_config` sensor names.

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"

  humidity:

    label: Humidity

    precision: 1

    units: "%"

    template: "Humidity = {:.1f} %"
```

Note for downstream generators: `{:.1f}` denotes numeric precision (one decimal
place) and is language-neutral. When emitting C-family format strings, translate
to the equivalent conversion specifier (`%.1f`), never embed the brace syntax
literally. Each downstream skill must state which literal format syntax it
emitted.

---

## Traceability

| Specification Field | Value | Source |
|---------------------|-------|--------|
| device.name | DHT22 | spec_dht22.md; ESPHome component `dht` |
| device.manufacturer | Aosong Electronics Co., Ltd | spec_dht22.md |
| device.transport | single-wire (proprietary single-bus) | spec_dht22.md "Transport Configuration" |
| observables.temperature.id | temperature | primary capability "Measure ambient temperature" |
| observables.temperature.type | float | 0.1 °C resolution (spec_dht22.md) |
| observables.temperature.units | C | ESPHome `UNIT_CELSIUS` (`sensor.py`) |
| observables.temperature.default | 25.0 | spec_dht22.md test vector `0x00FA` = 250 → 25.0 |
| observables.humidity.id | humidity | primary capability "Measure relative humidity" |
| observables.humidity.type | float | 0.1 %RH resolution (spec_dht22.md) |
| observables.humidity.units | % | ESPHome `UNIT_PERCENT` (`sensor.py`) |
| observables.humidity.default | 50.4 | spec_dht22.md test vector `0x01F8` = 504 → 50.4 |
| presentation.temperature.precision | 1 | 0.1 °C resolution; dht.mdx `accuracy_decimals: 1` recommendation |
| presentation.humidity.precision | 1 | 0.1 %RH resolution; dht.mdx `accuracy_decimals: 1` recommendation |
