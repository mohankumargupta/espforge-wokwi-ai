# Canonical Test Specification: TMP102

This document is an intermediate, implementation-independent artifact.
It is the single source of truth from which downstream generators produce
simulator fixtures, firmware configuration, host-side integration tests, and
documentation. It is not firmware, not test code, and not simulator
configuration.

```yaml
device:

  name: TMP102

  manufacturer: Texas Instruments

  transport: I2C
```

---

## Primary Capabilities

The reason somebody buys this device.

```yaml
capabilities:

  - Measure ambient temperature
```

---

## Primary Observables

The smallest observable scenario that demonstrates the primary capability.

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 21.0
```

- `temperature` is the ambient temperature measured by the device and published
  to the host.
- The default `21.0` °C is a sensible real-world room-temperature value chosen
  for deterministic behaviour under ideal operating conditions.

---

## Assumptions

The canonical test operates under these assumptions.

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

---

## Excluded Features

Functionality intentionally excluded from the canonical test.

```yaml
excluded_features:

  - calibration
  - self calibration
  - EEPROM
  - power management
  - alarm thresholds
  - interrupt outputs
  - diagnostics
  - self tests
  - fault injection
  - low power modes
  - extended mode
  - high speed mode
  - general call
  - one shot mode
  - conversion rate control
  - fault queue
```

Note: the TMP102 has no EEPROM; it is listed for completeness.

---

## Canonical Presentation

The canonical human-readable representation of each observable.
Downstream generators must not invent or modify these.

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"
```

---

## Sources

Every value in this specification is traceable to an authoritative source.

| Value | Source |
|---|---|
| Device name `TMP102` | `spec_tmp102.md` (datasheet TMP102) |
| Manufacturer `Texas Instruments` | `spec_tmp102.md` |
| Transport `I2C` | `spec_tmp102.md`; ESPHome `Dependencies = ["i2c"]` |
| Capability `Measure ambient temperature` | `spec_tmp102.md` Overview; ESPHome component unit `UNIT_CELSIUS`, device class `temperature` |
| Observable `temperature`, type `float` | ESPHome component publishes float sensor value |
| Units `C` | ESPHome `UNIT_CELSIUS` |
| Default `21.0` °C | Canonical choice of sensible real-world room temperature (skill: avoid min/max/boundary/random) |
| Label `Temperature` | ESPHome `tmp102.cpp` `LOG_SENSOR("  ", "Temperature", this)` |
| Precision `1` | ESPHome `sensor.py` `accuracy_decimals=1`; `tmp102.cpp` log `%.1f` |
| Presentation template | `Temperature = {:.1f} C` (canonical; matches `%.1f` precision) |
| Assumptions | Skill defaults (ideal conditions, calibration complete, deterministic outputs, no faults) |
| Excluded features | Skill defaults plus TMP102-specific features from `spec_tmp102.md` |

Unknowns: none. All required values are determined from the inputs above.
