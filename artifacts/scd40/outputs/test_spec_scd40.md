# Canonical Test Specification: SCD40

This specification is an intermediate, implementation-independent artifact.
It is the single source of truth from which simulator fixtures, firmware
configuration, and host-side integration tests are rendered.

Source inputs:

- `spec_scd40.md` (chip specification)
- `scd40_datasheet.md` (manufacturer datasheet, `read_measurement` example)
- `scd4x.mdx` (ESPHome component documentation)
- `scd4x/` (ESPHome component source: `scd4x.cpp`, `scd4x.h`, `sensor.py`)

---

## Device

```yaml
device:

  name: SCD40

  manufacturer: Sensirion

  transport: I2C

  address: 0x62
```

---

## Primary Capability

```
Measure ambient carbon dioxide (CO2) concentration
```

The SCD40 also reports temperature and relative humidity from its on-chip
sensor; these are secondary observables of the same measurement cycle.

---

## Observables

Every default value below is the value a single `read_measurement` read of a
chip in ideal idle conditions is expected to return. The three defaults
together form the datasheet's canonical `read_measurement` response example
(CO2 = 500 ppm, Temp. = 25 C, RH = 37%).

```yaml
observables:

  - id: co2
    type: int
    units: ppm
    default: 500

  - id: temperature
    type: float
    units: C
    default: 25.0

  - id: humidity
    type: float
    units: "%"
    default: 37.0
```

---

## Assumptions

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

The canonical test operates in periodic measurement mode, after the 500 ms
post-`stop_periodic_measurement` wait, with a data-ready chip. No external
pressure source is involved.

---

## Excluded Features

Functionality intentionally excluded from the canonical test:

- calibration / forced recalibration (`perform_forced_calibration`)
- automatic self calibration (ASC) state handling
- factory reset (`perform_factory_reset`)
- persisting settings to EEPROM (`persist_settings`)
- temperature offset configuration
- altitude compensation
- ambient pressure compensation (static or dynamic source)
- measurement mode variants (low power periodic, single shot,
  single shot rht only)
- power down / wake up
- sensor variant / serial number identification
- self test / diagnostics
- data-ready status polling (the chip is assumed ready)

---

## Canonical Presentation

Precision values are taken from the ESPHome component's `accuracy_decimals`
(`co2`: 0, `temperature`: 2, `humidity`: 2). Labels mirror the component's
`dump_config` sensor names.

```yaml
presentation:

  co2:

    label: CO2

    precision: 0

    units: ppm

    template: "CO2 = {:.0f} ppm"

  temperature:

    label: Temperature

    precision: 2

    units: C

    template: "Temperature = {:.2f} C"

  humidity:

    label: Humidity

    precision: 2

    units: "%"

    template: "Humidity = {:.2f} %"
```

Note for downstream generators: `{:.0f}` / `{:.2f}` denote numeric precision
(0 and 2 decimal places) and are language-neutral. When emitting C-family
format strings, translate to the equivalent conversion specifier (`%.0f` /
`%.2f`), never embed the brace syntax literally.