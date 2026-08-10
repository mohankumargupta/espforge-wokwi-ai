# Canonical Test Specification: TMP102

This specification is deterministic, implementation-independent, and
framework-independent. It is the single source of truth from which simulator
fixtures, firmware configuration, host-side integration tests, and
documentation are generated.

It is not firmware, test code, or simulator configuration.

---

# Device

```yaml
device:

  name: TMP102

  manufacturer: Texas Instruments

  transport: I2C
```

---

# Primary Capability

The smallest observable scenario that demonstrates the primary functionality:

```
Measure ambient temperature
```

---

# Primary Observables

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 25.0
```

### default — single source of truth

The `default` value is the numeric ground truth. It is the value the simulated
device emits over the bus on first read and the value the test harness asserts
it observes in serial output. No downstream skill may choose its own value.

- Decoding: register word `0x1900` → 12-bit raw count `0x190` (400) →
  `400 * 0.0625 = 25.0`
- Source: datasheet test vector `+25°C` (spec_tmp102.md Table 5).

---

# Assumptions

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

The canonical test operates under ideal conditions: stable environment,
communication completes without error, first conversion is complete before the
temperature register is read (TMP102 conversion time <= 26 ms typ / 35 ms max),
and the default conversion rate (CR1:CR0 = 10, 4 Hz) is in effect.

---

# Excluded Features

The following functionality is intentionally excluded from the canonical test:

- calibration
- self calibration
- EEPROM (device has no EEPROM)
- power management
- alarm thresholds (THIGH / TLOW)
- interrupt / alert outputs (ALERT pin)
- fault queue (F1:F0)
- alert polarity / thermostat mode / one-shot / shutdown control (POL, TM, OS, SD)
- conversion-rate configuration (CR1:CR0)
- extended mode (EM, 13-bit / >+128°C)
- one-shot and shutdown modes
- diagnostics
- self tests
- fault injection
- low power modes

---

# Canonical Presentation

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"
```

The presentation section owns labels, wording, capitalization, spacing,
numeric precision, and units. Downstream generators must never invent or modify
these.

- `precision: 1` — one digit after the decimal point.
  Source: ESPHome `sensor.py` sets `accuracy_decimals=1`; ESPHome driver log
  uses one decimal (`Got Temperature=%.1f°C`).
- `units: C` — Celsius. Source: ESPHome `UNIT_CELSIUS`.
- `template` — specifies wording, ordering, and precision. Downstream
  generators translate the precision directive into their target language's
  conversion specifier (e.g. `%.1f` in C/C++) and MUST state which literal
  format syntax they emitted. `{:.1f}` must not be copied verbatim into a
  printf-style format string.

---

# Traceability

| Specification Field | Value | Source |
|---------------------|-------|--------|
| device.name | TMP102 | datasheet; ESPHome component `tmp102` |
| device.manufacturer | Texas Instruments | spec_tmp102.md |
| device.transport | I2C | spec_tmp102.md; ESPHome dependency `i2c` |
| observables.temperature.id | temperature | primary capability "Measure ambient temperature" |
| observables.temperature.type | float | derived from 0.0625 °C/LSB scale |
| observables.temperature.units | C | ESPHome `UNIT_CELSIUS` (`sensor.py`) |
| observables.temperature.default | 25.0 | datasheet test vector `+25°C` → `0x1900` (spec_tmp102.md Table 5) |
| presentation.temperature.precision | 1 | ESPHome `accuracy_decimals=1` (`sensor.py`) |