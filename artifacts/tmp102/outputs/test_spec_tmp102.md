# Canonical Test Specification: TMP102

Status: final

## Device

```yaml
device:

  name: TMP102

  manufacturer: Texas Instruments

  category: temperature

  transport: I2C
```

## Primary Capability

Measure ambient temperature.

## Observables

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 21.0
```

Rationale: 21.0 °C is a sensible room-temperature default for a deterministic
ambient temperature smoke test. Precision is 0.0625 °C per datasheet; 21.0 °C
is exactly representable at that resolution.

## Assumptions

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

## Excluded Features

The following device functionality is intentionally excluded from the canonical
test:

- calibration / factory calibration (device ships calibrated)
- alarm thresholds (TLOW, THIGH)
- ALERT output / interrupt (comparator and interrupt thermostat modes)
- fault queue (F1:F0)
- alert polarity (POL)
- extended mode (EM, 13-bit)
- shutdown / low power mode (SD)
- one-shot conversion (OS)
- SMBus Alert response
- General Call reset
- conversion rate configuration (CR1:CR0)
- reserved register bits
- multiple device addressing (ADD0 variants)

## Canonical Presentation

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"
```

## Hallucination Prevention

All fields above are traceable to the following authoritative sources:

- `artifacts/tmp102/outputs/spec_tmp102.md` (chip specification)
- `artifacts/tmp102/outputs/tmp102.mdx` (ESPHome docs)
- `artifacts/tmp102/outputs/tmp102/sensor.py` (unit `UNIT_CELSIUS`,
  `accuracy_decimals=1`, device class `temperature`, address `0x48`,
  `update_interval` 60s)
- `artifacts/tmp102/outputs/tmp102/tmp102.cpp` (0.0625 conversion factor,
  "Temperature" log label)

No values are invented.

Unknown fields:

```yaml
status: known
```

All information required for the canonical smoke test is available from the
authoritative sources.
