# DHT22 Chip Attributes Manifest (prompt2d)

Source: `artifacts/dht22/prompt2d/chip.zig`
Consumers: `wokwi-chip-diagram` (diagram.json `attrs` / chip.json `controls`)
and any diagram author.

## Environmental observables — exposed as live chip.json controls

These are physical measurements a user plausibly changes while the simulation
runs. They are read with `attrInit`/`attrReadFloat` on every host start signal,
so moving a slider takes effect on the next read. They are wired to the range
controls already present in `chip.json` (ids `temperature`, `humidity`).

| Attribute name | Category | Zig default | Wokwi attrs format | Notes |
|---|---|---|---|---|
| `temperature` | environmental | `25.0` (f64) | decimal string, may include a fractional part (never `0x`-prefixed) | °C → T bytes 0x00 0xFA (word 0x00FA = 250/10); canonical default 25.0 per test_spec_dht22.md |
| `humidity` | environmental | `50.4` (f64) | decimal string, may include a fractional part | %RH → RH bytes 0x01 0xF8 (word 0x01F8 = 504/10); canonical default 50.4 per test_spec_dht22.md |

Defaults are the canonical observable defaults (test_spec_dht22.md) so the
device emits the correct 40-bit frame (`0x01 0xF8 0x00 0xFA 0xF3`) even if a
diagram omits the `attrs` block.

## Fixed / wiring parameters — NOT attributes

These are determined once on real hardware and must NOT be added to
diagram.json `attrs` (doing so has no effect).

| Parameter | Value | How modeled | Notes |
|---|---|---|---|
| DATA pull-up | internal pull-up (~input_pullup) | `pinInit("DATA", input_pullup)` in chip.zig | Real DHT22 needs an external ~4.7 kΩ pull-up on DATA; `diagram.json` connects `esp:3` straight to `chip1:DATA` with no resistor, so the chip provides the pull-up internally to keep the idle bus high. |
| Start-signal low time | >= 1 ms | `START_MIN_LOW_US = 900` threshold measured from the DATA falling edge | Host-initiated only; one start pulse yields one 40-bit frame. The threshold rejects short glitches while tolerating ESPHome's exact 1000 us low pulse. |
| Bus timing | 80/80 µs response, 50 µs bit low, 70 µs (1) / 28 µs (0) high | hard-coded timing constants in chip.zig | Not attributes; they are the wire protocol, fixed by the datasheet. |

No address-strap / mode pins exist on the DHT22 (one sensor per DATA line, no
addressing), so there are no other wiring parameters to model.
