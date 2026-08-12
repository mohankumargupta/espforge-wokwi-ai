# Feedback: spec-from-datasheet for apds9960

## What went well

- analog.sh returned a working wayback URL; datasheet downloaded cleanly (the
  `file` "password protected" report was indeed a false flag — qpdf confirmed
  not encrypted).
- PyMuPDF4LLM produced a clean 1484-line markdown with all register tables,
  bit fields, pin table, and electrical characteristics intact. OCR handled 2
  pages fine.
- Full register map with reset values, bit fields, and worked example tables
  (ATIME/WTIME cycles, proximity counts, sign/magnitude offsets) were all
  present and extractable.

## Obstacles / gotchas

1. The register table has a typo in the datasheet extraction: the row for
   ATIME is labelled `0x81` in the register-set table but the register
   description section calls it `0x81` too (the printed row `0x81|ATIME` is
   correct; 0x80 is ENABLE). No real obstacle.
2. The datasheet's `STATUS` register is listed as reset `0x00` in the register
   map but the STATUS section text says "set to 0x04 at power-up". I recorded
   both (table value in the map, note pointing at the description). Downstream
   skills should be aware this discrepancy exists.
3. No direct Lux formula is given in the datasheet — only clear-channel
   irradiance responsivity (counts/(mW/cm²)) and ESPHome publishes raw counts
   as percentages of full scale. Data-conversion section documents both, but
   there is no canonical lux/color-temperature formula to encode.
4. The register addresses (0x80+) are actually 5-bit register addresses inside
   a command byte (MSB set). This quirk was captured in Protocol Quirks, but
   could be a trap for a chip-emulator skill that assumes plain 8-bit
   register addressing.
5. Worked-example values for proximity/gesture are ranges (typ min/max), not
   single test vectors — unit tests will need to pick a representative value
   (e.g. typ 120 @ 100 mm).

## Improvements suggested

- The skill says "If that returns empty ... search esphome" — fine. But it may
  help to explicitly note that the esphome component source lives under
  `esphome/esphome/components/<name>` (nested esphome dir), since the initial
  `esphome/components/...` path does not exist.
- For devices like this with no explicit lux formula, consider adding a note
  in the template Data Conversion section that "no datasheet formula; host
  computes lux" is an acceptable answer.
