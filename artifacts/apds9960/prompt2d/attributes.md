# APDS9960 Chip Attributes Manifest (prompt2d)

Source: `artifacts/apds9960/prompt2d/chip.zig`
Consumers: `wokwi-chip-diagram` (diagram.json `attrs`) and any diagram author.

## Environmental observables — exposed as live chip.json controls

These are physical measurements a user plausibly changes while the simulation
runs. They are read with `attrInit`/`attrReadFloat` on every data-register
access, so moving a slider takes effect on the next read. They are wired to the
range controls in `chip.json` (ids `clear`, `red`, `green`, `blue`,
`proximity`).

| Attribute name | Category | Zig default | Wokwi attrs format | Notes |
|---|---|---|---|---|
| `clear` | environmental | `20.0` (f64) | decimal string, may include a fractional part (never `0x`-prefixed) | % of full scale → CDATAL/CDATAH (0x94/0x95, Little-Endian); canonical default 20.0 → 0x3333 |
| `red` | environmental | `15.0` (f64) | decimal string, may include a fractional part | → RDATAL/RDATAH (0x96/0x97); 15.0 → 0x2666 |
| `green` | environmental | `12.0` (f64) | decimal string, may include a fractional part | → GDATAL/GDATAH (0x98/0x99); 12.0 → 0x1EB8 |
| `blue` | environmental | `9.0` (f64) | decimal string, may include a fractional part | → BDATAL/BDATAH (0x9A/0x9B); 9.0 → 0x170A |
| `proximity` | environmental | `7.1` (f64) | decimal string, may include a fractional part | % of full scale → PDATA (0x9C); 7.1 → 0x12 |

## Fixed / wiring parameters — NOT attributes

These are determined once on real hardware and must NOT be added to
diagram.json `attrs` (doing so has no effect).

| Parameter | Value | How modeled | Notes |
|---|---|---|---|
| I2C address | `0x39` | hard-coded `const I2C_ADDR: u32 = 0x39` in chip.zig | Factory-fixed single address; APDS9960 has no address-strap pin (spec_apds9960.md "Bus and addressing Rules"). Not configurable. |
