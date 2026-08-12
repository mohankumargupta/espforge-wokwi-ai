# Canonical Test Specification: APDS9960

This specification is deterministic, implementation-independent, and
framework-independent. It is the single source of truth from which simulator
fixtures, firmware configuration, host-side integration tests, and
documentation are generated.

It is not firmware, test code, or simulator configuration.

Source inputs:

- `spec_apds9960.md` (chip specification extracted from the manufacturer
  datasheet)
- `apds9960.mdx` (ESPHome component documentation)
- `apds9960/` (ESPHome component source: `__init__.py`, `apds9960.cpp`,
  `apds9960.h`, `sensor.py`, `binary_sensor.py`)

---

# Device

```yaml
device:

  name: APDS9960

  manufacturer: Avago Technologies (now Broadcom)

  transport: I2C

  address: 0x39
```

---

# Primary Capability

The device's headline feature is touchless gesture detection. Gesture events
are stateful, event-driven outputs (four directional binary pulses) and are
therefore excluded from this deterministic numeric smoke test (see Excluded
Features). The canonical test targets the two measurement paths that produce
stable, numeric sensor outputs under ideal idle conditions:

```
Detect proximity

Measure ambient light intensity and color (RGBC)
```

These five values are the observables the ESPHome component publishes; each is
a percentage of the corresponding channel's full-scale count
(`value / 65535 * 100` for RGBC, `value / 255 * 100` for proximity, per
`apds9960.cpp`).

---

# Observables

All five observables are published as floats by the ESPHome component
(`sensor.py`, `sensor.sensor_schema(unit_of_measurement=UNIT_PERCENT, ...)`).

```yaml
observables:

  - id: clear
    type: float
    units: "%"
    default: 20.0

  - id: red
    type: float
    units: "%"
    default: 15.0

  - id: green
    type: float
    units: "%"
    default: 12.0

  - id: blue
    type: float
    units: "%"
    default: 9.0

  - id: proximity
    type: float
    units: "%"
    default: 7.1
```

### default — single source of truth

Each `default` is the numeric ground truth. It is the value the simulated
device emits over the bus (as raw register counts that ESPHome converts to
these percentages) and the value the test harness asserts it observes in
serial output. No downstream skill may choose its own value.

### Canonical decode (percent → raw counts → register bytes)

The conversion ESPHome applies is fixed (`apds9960.cpp`): RGBC
`value / 65535 * 100`, proximity `value / 255 * 100`. The inverse used to
produce the register values below is deterministic and documented so the
simulated chip and the harness agree:

| Observable | default (%) | Raw count | Decode | Register bytes (Little-Endian pairs) |
|------------|-------------|-----------|--------|--------------------------------------|
| clear      | 20.0 | 13107 (`0x3333`) | 13107 / 65535 × 100 = 20.0 | 0x94 CDATAL = 0x33, 0x95 CDATAH = 0x33 |
| red        | 15.0 |  9830 (`0x2666`) |  9830 / 65535 × 100 = 15.0 | 0x96 RDATAL = 0x66, 0x97 RDATAH = 0x26 |
| green      | 12.0 |  7864 (`0x1EB8`) |  7864 / 65535 × 100 = 12.0 | 0x98 GDATAL = 0xB8, 0x99 GDATAH = 0x1E |
| blue       |  9.0 |  5898 (`0x170A`) |  5898 / 65535 × 100 =  9.0 | 0x9A BDATAL = 0x0A, 0x9B BDATAH = 0x17 |
| proximity  |  7.1 |    18 (`0x12`)   |    18 /   255 × 100 =  7.1 | 0x9C PDATA = 0x12 |

Provenance of `default` values:

- `proximity`: the datasheet's documented no-object test vector is
  `PDATA = 10–25` (spec_apds9960.md, VLEDA=3 V, LDRIVE=100 mA, PPULSE=8,
  PGAIN=4x, PPLEN=8 µs, LED_BOOST=100%, open view). `PDATA = 18` is the
  deterministic representative selected from within that documented range for
  simulation purposes; it is not a boundary value.
- `clear`, `red`, `green`, `blue`: the datasheet provides no single idle
  RGBC measurement vector (only the clear-channel responsivity, which depends
  on an unspecified irradiance, and the `0x00` power-on reset values of the
  data registers). The defaults above are deterministic ground-truth values
  selected to exercise the datasheet-derived full-scale scaling
  (`spec_apds9960.md` Data Conversion); they are documented as selections, not
  as datasheet-measured readings. Distinct values per channel allow a
  swapped-channel encoding bug to be detected.

---

# Assumptions

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

The canonical test operates after the ESPHome component's `setup()` has
completed successfully: the device ID register (0x92) returned a valid
APDS-9960 ID (`0xAB`), the configuration registers have been written
(ATIME=0xDB, WTIME=0xF6, PPULSE=0x87, CONTROL per ESPHome defaults, PERS=0x11,
CONFIG1=0x60, CONFIG2=0x01, CONFIG3=0x00), and ENABLE (0x80) has been written
with PON and the required engine enables (AEN for color, PEN for proximity).

Operating conditions:

- no object is present in front of the sensor (open view)
- ambient light is steady
- the ALS/color and proximity conversions are complete and valid
  (STATUS 0x93 reports AVALID and PVALID set), so the data registers hold the
  canonical default values and ESPHome publishes them
- communication completes without error on the I2C bus

---

# Excluded Features

The following functionality is intentionally excluded from the canonical test:

- gesture detection (UP/DOWN/LEFT/RIGHT binary sensors) — stateful,
  event-driven output requiring a scripted FIFO sequence and timing window;
  not a stable numeric observable
- calibration / self calibration
- EEPROM / settings persistence (device has no EEPROM)
- power management / low power / sleep modes (PON, SAI, WEN)
- wait timer (WTIME)
- LED drive strength, proximity gain, ambient light gain, gesture gain /
  LED drive / wait time configuration (LDRIVE, PGAIN, AGAIN, GGAIN, GLDRIVE,
  GWTIME, LED_BOOST) — fixed at ESPHome defaults
- proximity and gesture offsets (POFFSET_UR/DL, GOFFSET_*)
- alarm / interrupt thresholds and persistence (AILT, AIHT, PILT, PIHT, PERS)
- interrupt outputs and clear mechanisms (INT pin, PICLEAR, CICLEAR, AICLEAR,
  IFORCE)
- gesture thresholds / FIFO configuration (GPENTH, GEXTH, GCONF1–4, GPULSE)
- device ID / variant identification beyond the setup() validity check
- diagnostics / self tests / fault injection / saturation handling

---

# Canonical Presentation

Precision values are taken from the ESPHome component's `accuracy_decimals=1`
(`sensor.py`). Labels mirror the component's `dump_config` sensor names
(`apds9960.cpp`): "Clear channel", "Red channel", "Green channel", "Blue
channel", "Proximity".

```yaml
presentation:

  clear:

    label: Clear channel

    precision: 1

    units: "%"

    template: "Clear channel = {:.1f} %"

  red:

    label: Red channel

    precision: 1

    units: "%"

    template: "Red channel = {:.1f} %"

  green:

    label: Green channel

    precision: 1

    units: "%"

    template: "Green channel = {:.1f} %"

  blue:

    label: Blue channel

    precision: 1

    units: "%"

    template: "Blue channel = {:.1f} %"

  proximity:

    label: Proximity

    precision: 1

    units: "%"

    template: "Proximity = {:.1f} %"
```

The presentation section owns labels, wording, capitalization, spacing,
numeric precision, and units. Downstream generators must never invent or
modify these.

Note for downstream generators: `{:.1f}` denotes numeric precision (one
decimal place) and is language-neutral — it specifies wording, ordering, and
precision only. When emitting C-family printf format strings (e.g.
`ESP_LOGI`), translate the precision directive into the equivalent conversion
specifier (`%.1f`), never embed the brace syntax literally. Every downstream
skill that consumes `template` must state in its own output which literal
format syntax it emitted.

---

# Traceability

| Specification Field | Value | Source |
|---------------------|-------|--------|
| device.name | APDS9960 | datasheet; ESPHome component `apds9960` |
| device.manufacturer | Avago Technologies (now Broadcom) | spec_apds9960.md |
| device.transport | I2C | spec_apds9960.md; ESPHome dependency `i2c` (`__init__.py`) |
| device.address | 0x39 | spec_apds9960.md; ESPHome `i2c.i2c_device_schema(0x39)` (`__init__.py`) |
| observables.*.id | clear, red, green, blue, proximity | ESPHome `sensor.py` `TYPES` |
| observables.*.type | float | ESPHome publishes float percentages (`apds9960.cpp`) |
| observables.*.units | "%" | ESPHome `UNIT_PERCENT` (`sensor.py`) |
| observables.clear.default | 20.0 | deterministic ground truth; counts 13107 → 20.0% via `value/65535*100` (`apds9960.cpp`); scaling per spec_apds9960.md Data Conversion |
| observables.red.default | 15.0 | deterministic ground truth; counts 9830 → 15.0% |
| observables.green.default | 12.0 | deterministic ground truth; counts 7864 → 12.0% |
| observables.blue.default | 9.0 | deterministic ground truth; counts 5898 → 9.0% |
| observables.proximity.default | 7.1 | datasheet no-object test vector PDATA 10–25 (spec_apds9960.md); representative PDATA=18 → 7.1% via `value/255*100` |
| presentation.*.precision | 1 | ESPHome `accuracy_decimals=1` (`sensor.py`) |
| presentation.*.label | Clear channel / Red channel / Green channel / Blue channel / Proximity | ESPHome `dump_config` (`apds9960.cpp`) |
| decode register addresses | 0x94–0x9B (RGBC), 0x9C (PDATA) | spec_apds9960.md register map |
| decode byte order | Little-Endian pairs (low at even address) | spec_apds9960.md transport configuration |
