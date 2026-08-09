# Canonical Test Specification: TMP102

Internal specification consumed by downstream code-generation skills.

Not firmware. Not test code. Not simulator configuration.

## Device

```yaml
device:

  name: TMP102

  manufacturer: Texas Instruments

  transport: I2C
```

## Primary Capability

The reason somebody buys a TMP102:

```
Measure ambient temperature
```

## Primary Observables

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 21.0
```

The default value is a deterministic, real-world room-temperature sample. It is
intended only to exercise the normal decode path; it is not a calibration value
and carries no accuracy significance.

## Assumptions

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

- The device has completed its first conversion after power-up before the first
  measurement is taken.
- No ALERT pin wiring, alarm events, or communication failures are present.
- Ambient temperature is stable for the duration of the observation.

## Excluded Features

The following functionality is intentionally excluded from this canonical
specification. Downstream generators must not implement or test these.

- calibration (the device requires none)
- self calibration
- EEPROM (device has no EEPROM; config register is volatile)
- alarm thresholds (TLOW / THIGH registers)
- ALERT output pin behaviour (thermostat / comparator mode, polarity)
- one-shot (OS) conversion
- low power / shutdown (SD) mode
- conversion rate configuration (CR1/CR0)
- extended mode (EM, 13-bit temperature resolution)
- fault queue (F1/F0)
- general-call reset
- SMBus alert response
- diagnostics / self tests
- fault injection

## Canonical Presentation

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"
```

Downstream generators must use exactly these labels, wording, capitalization,
precision, and units. Numeric precision is one digit after the decimal point.
The `template` string specifies wording, ordering and precision only; the
concrete format-syntax translation into the target language is the
downstream generator's responsibility (e.g. `%.1f` in printf-style languages).

## Traceable Source

Every value in this specification is traceable to one of these inputs:

| Value                                   | Source |
|-----------------------------------------|--------|
| name: TMP102                            | datasheet; `esphome_component.txt` (`tmp102`); `tmp102.mdx` title |
| manufacturer: Texas Instruments         | `spec_tmp102.md` |
| transport: I2C                          | `spec_tmp102.md`; `tmp102.mdx` ("I²C Bus required") |
| capability: measure ambient temperature | `spec_tmp102.md` Overview; `sensor.py` docstring; `tmp102.cpp` publish |
| temperature / float / C                 | `sensor.py` (`UNIT_CELSIUS`), 12-bit signed conversion in spec |
| default 21.0                            | deterministic ambient-room convention, 0.0625 °C resolution typical example (25 °C measured scenario) |
| presentation precision: 1 decimal       | `sensor.py` `accuracy_decimals=1`; `tmp102.cpp` `%.1f` |
| excluded: calibration, thresholds, alarms, power modes, EM | `spec_tmp102.md` register / feature sections |