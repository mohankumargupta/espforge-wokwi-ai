# TMP102 custom chip — attribute manifest

Single source of truth for `chip.json` attrs/controls vs. the chip's
`attrInit`/pin configuration. A diagram-generation skill must consult this
before inventing an `attrs` entry for the custom chip part.

## Inputs

| Attribute name | Category | Zig default | Wokwi attrs format | Notes |
|---|---|---|---|---|
| `temperature` | environmental | `25.0` (f64) | decimal string, may include a fractional part (e.g. `"25.0"`, `"-3.25"`). Never `0x`-prefixed. | Safe to expose as a `chip.json` range control (and it is: `controls[0]`, min -40 / max 125 / step 0.25). Read live with `attrReadFloat` on every temperature-register read. |
| `address` | fixed / wiring | n/a — derived from `ADD0` pin level at `chip_init()`, per datasheet Table 6-4 | **not an attribute — do not add to diagram.json `attrs`** | `ADD0` is modelled as a real strap pin (`pinInit("ADD0", input_pulldown)`). The canonical test spec only exercises 0x48, so only GND/V+ are distinguished by the digital read: pin low -> 0x48, pin high -> 0x49. Tying `ADD0` to GND (as in `outputs/diagram.json`) yields the canonical 0x48. |

## Rules

- Only `temperature` may appear in `chip.json` `controls` / `diagram.json`
  `attrs`.
- Never generate an `attrs` entry for `address` — it is fixed wiring derived
  from the `ADD0` pin connection.
- The `chip.json` `controls` range must stay in sync with the temperature
  attribute: min -40, max 125, step 0.25 (chip.json already reflects this).