# Canonical Test Specification: TMP102

Source of truth for downstream generators (simulator fixture, firmware
configuration, host-side integration tests, documentation).

This is an intermediate artifact. Do not edit manually.

---

## Device

```yaml
device:

  name: TMP102

  manufacturer: Texas Instruments

  transport: I2C
```

## Primary Capability

  measure_ambient_temperature: true

## Observables

  observables:

    - id: temperature
      type: float
      units: C
      default: 21.0

The default `21.0` °C is a deterministic, room-temperature value chosen as the
steady-state reading the device must produce under ideal operating conditions.

## Assumptions

  assumptions:

    ideal_conditions: true

    calibration_complete: true

    deterministic_outputs: true

    hardware_faults_present: false

## Excluded Features

  excluded:

    - calibration
    - ALERT / thermostat alarm thresholds (TLOW, THIGH)
    - comparator and interrupt modes (TM bit)
    - fault queue (F1/F0)
    - ALERT polarity (POL bit)
    - shutdown mode / low power modes (SD bit)
    - one-shot conversions (OS bit)
    - conversion rate selection (CR1/CR0)
    - extended 13-bit mode (EM bit)
    - multiple device addressing via ADD0 (addresses other than 0x48)
    - general call reset
    - diagnostics and self tests

## Presentation

  presentation:

    temperature:

      label: Temperature

      precision: 1

      units: C

      template: "Temperature = {:.1f} C"