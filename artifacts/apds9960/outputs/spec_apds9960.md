# Chip Spec: APDS-9960

**Manufacturer:** Avago Technologies (now Broadcom)  
**Category:** gesture (also proximity, ambient light / RGB color)  
**Transports:** I²C

## Overview

The APDS-9960 is an optical module combining gesture detection, proximity
detection, digital Ambient Light Sensing (ALS) and RGB color sensing (RGBC) in a
single small package (L 3.94 × W 2.36 × H 1.35 mm) that integrates an IR LED and
a factory-calibrated LED driver. Four directional photodiodes sense reflected IR
energy from the integrated LED to convert physical motion (velocity, direction,
distance) into digital gesture data; a separate combined photodiode path produces
8-bit proximity results and 16-bit clear/red/green/blue intensity data. It is
used for touchless gestures, device wake / display disable, ambient light
backlight control and color measurement. Communication is over a fast-mode
(400 kHz) I²C interface with a single 7-bit address, `0x39`, and a dedicated
open-drain interrupt pin.

## Transport Configuration

### I²C
- **Address:** `0x39` (7-bit, single address, factory-fixed; other addresses available on request)
- **Max clock:** 400 kHz (I²C Fast Mode); SCL 0–400 kHz
- **Endianness / Byte Order:** 16-bit RGBC data is Little-Endian (LSB first) — low byte at even address (0x94/0x96/0x98/0x9A), high byte at odd address (0x95/0x97/0x99/0x9B)
- **Protocol Quirks:**
  - The first byte written after the slave address is a *command byte* holding either control information or a 5-bit register address; the register addresses listed below are used directly as that command/register byte.
  - Registers 0x00–0x7F are general-purpose RAM; 0x80+ are control/data registers.
  - RGBC reads must read byte pairs (low then high) starting on an even address boundary. Reading the lower byte latches the corresponding upper byte into a shadow register (a read of CDATAL also latches all eight RGBC registers simultaneously — 64-bit latch).
  - In gesture mode, the RAM region is repurposed as a 32×4-byte FIFO accessed via a page read starting at `0xFC`; the internal FIFO pointer and GFLVL update when `0xFF` is reached (every 4th byte).
  - Interrupt-clear registers require a special 2-byte "address accessing" transaction: chip address (R/W=0) followed by the register address, with no data byte.
  - If a read command is issued, the register address from the previous command is reused for data access.

### SPI
Not supported.

## Physical pins names and functions

| Pin Number | Pin Name | Description
|------------|----------|------------
| 1 | SDA | I²C serial data I/O terminal
| 2 | INT | Interrupt output, open drain, active low
| 3 | LDR | LED driver input for proximity IR LED, constant-current source LED driver
| 4 | LEDK | LED cathode; connect to LDR pin when using internal LED driver circuit
| 5 | LEDA | LED anode; connect to VLEDA on PCB
| 6 | GND | Power supply ground (all voltages referenced to GND)
| 7 | SCL | I²C serial clock input terminal
| 8 | VDD | Power supply voltage (2.4–3.6 V typical 3.0 V; VLEDA 3.0–4.5 V)

## Bus and addressing Rules

- Single 7-bit slave address: `0x39`. No alternate address pin (factory-fixed; contact factory for other addressing options).
- I²C Fast Mode compatible, up to 400 kHz. Timing (AC characteristics): tBUF ≥ 1.3 µs, tHD;STA ≥ 0.6 µs, tSU;STA ≥ 0.6 µs, tSU;STO ≥ 0.6 µs, tHD;DAT ≥ 30 ns, tSU;DAT ≥ 100 ns, tLOW ≥ 1.3 µs, tHIGH ≥ 0.6 µs.
- SDA/SCL/INT are open-drain and require pull-up resistors; a 10 kΩ pull-up (RPI) is suggested for the interrupt line.
- Absolute max VDD 3.8 V; recommended VDD 2.4–3.6 V, VLEDA 3.0–4.5 V.

## Interrupts / Alert Pins

- **Pin Type:** Open-drain
- **Polarity:** Active-Low
- **Latch Behavior:** Latched — interrupt bits (PINT, AINT, GINT, PGSAT, CPSAT) remain asserted until explicitly cleared; the INT pin is released once cleared. GINT remains set after FIFO read if new data arrived during the read.
- **Clear Mechanism:**
  - `PICLEAR` (`0xE5`): clears proximity interrupt (and PGSAT).
  - `CICLEAR` (`0xE6`): clears ALS clear-channel interrupt (and CPSAT).
  - `AICLEAR` (`0xE7`): clears all non-gesture interrupts.
  - `IFORCE` (`0xE4`): forces an interrupt (write any value).
  - Gesture interrupt (GINT/GVALID/GFLVL): cleared by emptying the FIFO (reading all 4×GFLVL bytes).
  - All interrupt-clear registers are cleared via the special "address accessing" 2-byte I²C transaction.
  - `PVALID` auto-clears when PDATA is read; `AVALID` auto-clears when any RGBC register is read.

## Register Map

| Address | Name | R/W | Reset | Description |
|---------|------|-----|-------|-------------|
| `0x00`–`0x7F` | RAM | R/W | `0x00` | General-purpose RAM (repurposed as 32×4-byte gesture FIFO in gesture mode) |
| `0x80`  | ENABLE | R/W | `0x00`| Enable states and interrupts |
| `0x81`  | ATIME | R/W | `0xFF`| ALS/Color ADC integration time |
| `0x83`  | WTIME | R/W | `0xFF`| Wait time (non-gesture) |
| `0x84`  | AILTL | R/W | `--` | ALS interrupt low threshold, low byte |
| `0x85`  | AILTH | R/W | `--` | ALS interrupt low threshold, high byte |
| `0x86`  | AIHTL | R/W | `0x00`| ALS interrupt high threshold, low byte |
| `0x87`  | AIHTH | R/W | `0x00`| ALS interrupt high threshold, high byte |
| `0x89`  | PILT | R/W | `0x00`| Proximity interrupt low threshold |
| `0x8B`  | PIHT | R/W | `0x00`| Proximity interrupt high threshold |
| `0x8C`  | PERS | R/W | `0x00`| Interrupt persistence filters (non-gesture) |
| `0x8D`  | CONFIG1 | R/W | `0x40`| Configuration register one (WLONG) |
| `0x8E`  | PPULSE | R/W | `0x40`| Proximity pulse count and length |
| `0x8F`  | CONTROL | R/W | `0x00`| Gain control (LDRIVE, PGAIN, AGAIN) |
| `0x90`  | CONFIG2 | R/W | `0x01`| Configuration register two (saturation int., LED_BOOST) |
| `0x92`  | ID | R | `0xAB`| Device ID (`0xAB` = APDS-9960) |
| `0x93`  | STATUS | R | `0x00`| Device status (reg. description states set to `0x04` at POR) |
| `0x94`  | CDATAL | R | `0x00`| Clear channel data, low byte |
| `0x95`  | CDATAH | R | `0x00`| Clear channel data, high byte |
| `0x96`  | RDATAL | R | `0x00`| Red channel data, low byte |
| `0x97`  | RDATAH | R | `0x00`| Red channel data, high byte |
| `0x98`  | GDATAL | R | `0x00`| Green channel data, low byte |
| `0x99`  | GDATAH | R | `0x00`| Green channel data, high byte |
| `0x9A`  | BDATAL | R | `0x00`| Blue channel data, low byte |
| `0x9B`  | BDATAH | R | `0x00`| Blue channel data, high byte |
| `0x9C`  | PDATA | R | `0x00`| Proximity data |
| `0x9D`  | POFFSET_UR | R/W | `0x00`| Proximity offset, UP/RIGHT pair (sign/magnitude) |
| `0x9E`  | POFFSET_DL | R/W | `0x00`| Proximity offset, DOWN/LEFT pair (sign/magnitude) |
| `0x9F`  | CONFIG3 | R/W | `0x00`| Configuration register three (PCMP, SAI, PMASK) |
| `0xA0`  | GPENTH | R/W | `0x00`| Gesture proximity entry threshold |
| `0xA1`  | GEXTH | R/W | `0x00`| Gesture exit threshold |
| `0xA2`  | GCONF1 | R/W | `0x00`| Gesture configuration one (GFIFOTH, GEXMSK, GEXPERS) |
| `0xA3`  | GCONF2 | R/W | `0x00`| Gesture configuration two (GGAIN, GLDRIVE, GWTIME) |
| `0xA4`  | GOFFSET_U | R/W | `0x00`| Gesture UP offset register (sign/magnitude) |
| `0xA5`  | GOFFSET_D | R/W | `0x00`| Gesture DOWN offset register (sign/magnitude) |
| `0xA6`  | GPULSE | R/W | `0x40`| Gesture pulse count and length |
| `0xA7`  | GOFFSET_L | R/W | `0x00`| Gesture LEFT offset register (sign/magnitude) |
| `0xA9`  | GOFFSET_R | R/W | `0x00`| Gesture RIGHT offset register (sign/magnitude) |
| `0xAA`  | GCONF3 | R/W | `0x00`| Gesture configuration three (GDIMS) |
| `0xAB`  | GCONF4 | R/W | `0x00`| Gesture configuration four (GIEN, GMODE) |
| `0xAE`  | GFLVL | R | `0x00`| Gesture FIFO level |
| `0xAF`  | GSTATUS | R | `0x00`| Gesture status (GFOV, GVALID) |
| `0xE4`  | IFORCE | W | `0x00`| Force interrupt (write any value) |
| `0xE5`  | PICLEAR | W | `0x00`| Proximity interrupt clear (write any value) |
| `0xE6`  | CICLEAR | W | `0x00`| ALS clear-channel interrupt clear (write any value) |
| `0xE7`  | AICLEAR | W | `0x00`| All non-gesture interrupt clear (write any value) |
| `0xFC`  | GFIFO_U | R | `0x00`| Gesture FIFO UP value |
| `0xFD`  | GFIFO_D | R | `0x00`| Gesture FIFO DOWN value |
| `0xFE`  | GFIFO_L | R | `0x00`| Gesture FIFO LEFT value |
| `0xFF`  | GFIFO_R | R | `0x00`| Gesture FIFO RIGHT value |

### Bit Fields

#### `ENABLE` (`0x80`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | Reserved | Write as 0 |
| 6 | GEN | Gesture Enable; gesture state machine can be activated (subject to PEN and GMODE) |
| 5 | PIEN | Proximity Interrupt Enable |
| 4 | AIEN | ALS Interrupt Enable |
| 3 | WEN | Wait Enable |
| 2 | PEN | Proximity Detect Enable |
| 1 | AEN | ALS Enable |
| 0 | PON | Power ON; enables internal oscillator. 0 puts device in low-power sleep (temporarily overridden during I²C transactions) |

#### `CONTROL` (`0x8F`)

| Bits | Name | Description |
|------|------|-------------|
| 7:6 | LDRIVE | LED Drive Strength: 0=100 mA, 1=50 mA, 2=25 mA, 3=12.5 mA |
| 5:4 | Reserved | Write as 0 |
| 3:2 | PGAIN | Proximity Gain Control: 0=1x, 1=2x, 2=4x, 3=8x |
| 1:0 | AGAIN | ALS and Color Gain Control: 0=1x, 1=4x, 2=16x, 3=64x |

#### `PERS` (`0x8C`)

| Bits | Name | Description |
|------|------|-------------|
| 7:4 | PPERS | Proximity interrupt persistence: 0=every cycle, 1=any out-of-range, 2=2 consecutive, ..., 15=15 consecutive |
| 3:0 | APERS | ALS interrupt persistence: 0=every cycle, 1=any, 2=2, 3=3, 4=5, 5=10, 6=15, 7=20, 8=25, 9=30, 10=35, 11=40, 12=45, 13=50, 14=55, 15=60 consecutive out-of-range |

#### `CONFIG1` (`0x8D`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | Reserved | Write as 0 |
| 6 | Reserved | Write as 1 (auto-set at POR) |
| 5 | Reserved | Write as 1 (auto-set at POR; if cleared, wait-state power increases) |
| 4:2 | Reserved | Write as 0 |
| 1 | WLONG | Wait Long: wait cycle ×12 (relative to WTIME) |
| 0 | Reserved | Write as 0 |

#### `PPULSE` (`0x8E`)

| Bits | Name | Description |
|------|------|-------------|
| 7:6 | PPLEN | Proximity pulse length (LED-on width): 0=4 µs, 1=8 µs (default), 2=16 µs, 3=32 µs |
| 5:0 | PPULSE | Proximity pulse count: number of pulses = PPULSE value + 1 (1–64) |

#### `CONFIG2` (`0x90`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | PSIEN | Proximity Saturation Interrupt Enable |
| 6 | CPSIEN | Clear Photodiode Saturation Interrupt Enable |
| 5:4 | LED_BOOST | Proximity/Gesture LED boost: 0=100%, 1=150%, 2=200%, 3=300% (of LDRIVE/GLDRIVE current) |
| 3:1 | Reserved | Write as 0 |
| 0 | Reserved | Write as 1 (set by default at POR) |

#### `STATUS` (`0x93`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | CPSAT | Clear Photodiode Saturation; cleared by CICLEAR or AEN=0 |
| 6 | PGSAT | Proximity/Gesture analog saturation; cleared by PICLEAR or PEN=0 |
| 5 | PINT | Proximity Interrupt (interrupts if PIEN set) |
| 4 | AINT | ALS Interrupt (interrupts if AIEN set) |
| 3 | Reserved | Do not care |
| 2 | GINT | Gesture Interrupt; set when GFLVL > GFIFOTH or GVALID asserted on GMODE→0; cleared when FIFO emptied |
| 1 | PVALID | Proximity Valid; cleared when PDATA read |
| 0 | AVALID | ALS Valid; cleared when any RGBC register read |

#### `CONFIG3` (`0x9F`)

| Bits | Name | Description |
|------|------|-------------|
| 7:6 | Reserved | Write as 0 |
| 5 | PCMP | Proximity Gain Compensation; adds 2× gain (F.S. back to 255) when only one diode of a pair is contributing |
| 4 | SAI | Sleep After Interrupt: auto low-power when INT asserted and state machine at SAI decision; resumes when INT cleared |
| 3 | PMASK_U | Proximity Mask UP Enable (1 disables this photodiode) |
| 2 | PMASK_D | Proximity Mask DOWN Enable |
| 1 | PMASK_L | Proximity Mask LEFT Enable |
| 0 | PMASK_R | Proximity Mask RIGHT Enable |

#### `GCONF1` (`0xA2`)

| Bits | Name | Description |
|------|------|-------------|
| 7:6 | GFIFOTH | Gesture FIFO threshold: 0=1 dataset, 1=4, 2=8, 3=16 datasets before interrupt |
| 5:2 | GEXMSK | Gesture exit mask (bits correspond to U,D,L,R): 0000=all included, 0001=R excluded, ..., 1111=all excluded |
| 1:0 | GEXPERS | Gesture exit persistence: 0=1st, 1=2nd, 2=4th, 3=7th "gesture end" occurrence exits |

#### `GCONF2` (`0xA3`)

| Bits | Name | Description |
|------|------|-------------|
| 7 | Reserved | Write as 0 |
| 6:5 | GGAIN | Gesture gain: 0=1x, 1=2x, 2=4x, 3=8x |
| 4:3 | GLDRIVE | Gesture LED drive strength: 0=100 mA, 1=50 mA, 2=25 mA, 3=12.5 mA |
| 2:0 | GWTIME | Gesture wait time: 0=0 ms, 1=2.8 ms, 2=5.6 ms, 3=8.4 ms, 4=14.0 ms, 5=22.4 ms, 6=30.8 ms, 7=39.2 ms |

#### `GPULSE` (`0xA6`)

| Bits | Name | Description |
|------|------|-------------|
| 7:6 | GPLEN | Gesture pulse length (LED-on width): 0=4 µs, 1=8 µs (default), 2=16 µs, 3=32 µs |
| 5:0 | GPULSE | Gesture pulse count: number of pulses = GPULSE value + 1 (1–64) |

#### `GCONF3` (`0xAA`)

| Bits | Name | Description |
|------|------|-------------|
| 7:2 | Reserved | Write as 0 |
| 1:0 | GDIMS | Gesture dimension select: 0=both pairs active, 1=only UP-DOWN, 2=only LEFT-RIGHT, 3=both active |

#### `GCONF4` (`0xAB`)

| Bits | Name | Description |
|------|------|-------------|
| 7:2 | Reserved | Write as 0 |
| 1 | GIEN | Gesture Interrupt Enable (unmasks all gesture interrupts) |
| 0 | GMODE | Gesture Mode; read: 1=gesture running, 0=ALS/Proximity/Color. Write 1=enter gesture (as if GPENTH exceeded); write 0=exit when current conversion finishes (as if GEXTH exceeded) |

#### Offset registers `POFFSET_UR`/`POFFSET_DL`/`GOFFSET_U`/`GOFFSET_D`/`GOFFSET_L`/`GOFFSET_R`

Sign/magnitude 8-bit encoding (bit 7 = sign). Positive offset values *decrease* the signal result (offset is subtracted from signal accumulation).

| Bits | Name | Description |
|------|------|-------------|
| 7 | Sign | 0 = positive, 1 = negative |
| 6:0 | Magnitude | 0–127 |

## Initialization Sequence & State Machine for emulating chip, timings

1. Apply power; device runs POR (~5.7 ms), initializes registers to reset values and enters low-power SLEEP state.
2. Write configuration registers (order not strictly required, but recommended before enabling engines):
   - `ATIME` (0x81) — ALS/Color integration time (e.g. 0xDB = 103 ms as used by ESPHome).
   - `WTIME` (0x83) — wait time (e.g. 0xF6 ≈ 27 ms).
   - `CONFIG1` (0x8D) — WLONG / reserved bits (e.g. 0x60).
   - `PPULSE` (0x8E) — proximity pulse length + count (e.g. 0x87 = 16 µs, 8 pulses).
   - `CONTROL` (0x8F) — LDRIVE, PGAIN, AGAIN.
   - `PERS` (0x8C) — interrupt persistence (e.g. 0x11).
   - `CONFIG2` (0x90) — LED_BOOST / saturation enables (e.g. 0x01).
   - `CONFIG3` (0x9F) — PCMP/SAI/PMASK (e.g. 0x00).
   - `POFFSET_UR/DL` (0x9D/0x9E), `GOFFSET_*` (0xA4/0xA5/0xA7/0xA9) — crosstalk offsets (0x00 to disable).
   - Gesture: `GPENTH` (0xA0), `GEXTH` (0xA1), `GCONF1` (0xA2), `GCONF2` (0xA3), `GPULSE` (0xA6), `GCONF3` (0xAA).
3. Write `ENABLE` (0x80) with PON=1 (power on). Device exits SLEEP (EXIT SLEEP ≈ 7 ms) the first time an engine is enabled.
4. Set AEN (bit 1), PEN (bit 2), GEN (bit 6) as needed. The state machine order is: idle → proximity → gesture (if GMODE=1) → wait (if WEN=1) → color/ALS → sleep (if SAI=1 and INT asserted).
5. Poll `STATUS` (0x93) for AVALID/PVALID, or wait for interrupts, then read data:
   - RGBC: block-read bytes from 0x94 (8 bytes, low-high pairs).
   - Proximity: read PDATA (0x9C).
   - Gesture: poll `GSTATUS` (0xAF) GVALID, read `GFLVL` (0xAE), page-read 4×GFLVL bytes from 0xFC.

Timing reference: ALS/color ADC integration step 2.78 ms, 1–256 steps; proximity ADC conversion ~696.6 µs fixed; gesture ADC conversion 1.39 ms per U/D or L/R pair (696.6 µs each). Proximity result time `tPROX = tINIT + tCNVT + PPULSE × tACC`.

## Data Conversion

- **Data Type:**
  - RGBC: unsigned 16-bit counts (Little-Endian, low byte at even address).
  - Proximity: unsigned 8-bit counts.
  - Gesture FIFO: unsigned 8-bit counts per direction (U/D/L/R).
  - Offsets: sign/magnitude 8-bit.
- **Alignment:** RGBC 16-bit values occupy the full 16-bit register word (low byte then high byte). Proximity and gesture values occupy the full 8-bit register byte.

ALS/Color integration time and full-scale count:
```
CYCLES      = 256 - ATIME            (1..256)
tINTEGRATE  = CYCLES × 2.78 ms       (2.78 ms .. 712 ms)
CountMAX    = min(1025 × CYCLES, 65535)
```

Wait time (non-gesture):
```
WAIT_STEPS = 256 - WTIME             (1..256)
tWAIT      = WAIT_STEPS × 2.78 ms          (WLONG = 0)
tWAIT      = WAIT_STEPS × 2.78 ms × 12     (WLONG = 1, 0.03 s .. 8.54 s)
```

Proximity result time:
```
tPROX = tINIT + tCNVT + PPULSE × tACC     (tINIT, tACC per PPLEN; tCNVT = 796.6 µs)
```

Clear-channel irradiance responsivity (AGAIN=16×, 560 nm, neutral white LED): 23.60 counts/(mW/cm²) typical — allows estimating irradiance `Ee ≈ C_counts / 23.60 mW/cm²` under those conditions. ESPHome instead publishes RGBC and proximity as percentages of full scale: `value / 65535 × 100%` (RGBC) and `value / 255 × 100%` (proximity). Lux/color temperature are computed in host software; no direct lux formula is given in the datasheet.

### Worked Examples / Test Vectors

| Real-world Value | Raw Register Value (Hex/Binary) | Encoding (raw N-bit count \| full register word, alignment bits) | Notes |
|------------------|---------------------------------|--------------------------------------------------------------------|-------|
| ATIME → 1 cycle, 2.78 ms, max 1025 counts | `0xFF` | Full register word (16-bit max count) | CountMAX table row |
| ATIME → 10 cycles, 27.8 ms, max 10241 counts | `0xF6` | Full register word (16-bit max count) | CountMAX table row |
| ATIME → 37 cycles, 103 ms, max 37889 counts | `0xDB` | Full register word (16-bit max count) | CountMAX table row; ESPHome uses 0xDB |
| ATIME → 256 cycles, 712 ms, max 65535 counts | `0x00` | Full register word (16-bit max count) | CountMAX table row |
| WTIME → 1 step, 2.78 ms | `0xFF` | 8-bit value (256−WTIME steps) | |
| WTIME → 256 steps, 712 ms (WLONG=0) / 8.54 s (WLONG=1) | `0x00` | 8-bit value (256−WTIME steps) | |
| Proximity no object | PDATA = 10–25 | Raw 8-bit count (full PDATA byte) | VLEDA=3 V, LDRIVE=100 mA, PPULSE=8, PGAIN=4x, PPLEN=8 µs, LED_BOOST=100%, open view |
| Proximity, 90% grey card @ 100 mm | PDATA = 96–144 (typ 120) | Raw 8-bit count (full PDATA byte) | same conditions; avg of 5 readings |
| Gesture no object (sum of UP+DOWN) | GFIFO U+D = 10–25 | Raw 8-bit counts (full bytes) | GLDRIVE=100 mA, GPULSE=8, GGAIN=4x, GPLEN=8 µs, LED_BOOST=100% |
| Gesture, 90% grey card @ 100 mm (sum UP+DOWN) | GFIFO U+D = 96–144 (typ 120) | Raw 8-bit counts (full bytes) | same conditions; avg of 5 readings |
| Device ID APDS-9960 | `0x92` ID = `0xAB` | Full 8-bit register word | ID register |
| Offset factor +127 | `0x7F` (0111 1111) | Sign/magnitude 8-bit | positive offset decreases result |
| Offset factor −1 | `0x81` (1000 0001) | Sign/magnitude 8-bit | bit7 = sign |
| Offset factor −127 | `0xFF` (1111 1111) | Sign/magnitude 8-bit | bit7 = sign |
