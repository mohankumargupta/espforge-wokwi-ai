# Skill Feedback: spec-from-datasheet (dht22)

## Summary

Produced `artifacts/dht22/outputs/spec_dht22.md` for the DHT22 humidity/temperature
sensor from the Aosong DHT22 (AM2302) datasheet.

## What went well

- `components.sh` fast-path worked (components + esphome already cloned).
- Datasheet URL found in `components/sensor/dht.mdx`; `analog.sh` produced both the
  direct SparkFun URL and a wayback URL; direct curl download succeeded; no qpdf
  needed.
- `pymupdf4llm` OCR conversion produced usable markdown from a scanned datasheet.
- Template `template_chip.md` maps cleanly onto the device even though DHT22 is not
  register-mapped.

## Obstacles / points to improve

1. **Not a register-mapped chip.** DHT22 is a single-wire (proprietary "single-bus")
   host-initiated 40-bit frame device — no I²C/SPI/UART, no registers, no addressing,
   no interrupt pin. Several template sections (I²C/SPI transport, Register Map,
   Interrupts/Alert Pins) are structurally not applicable. The skill gives no
   guidance on a "single-wire" transport variant; I substituted a custom
   "Single-wire (proprietary)" transport section and mapped Register Map to a
   byte-indexed data-frame table. Consider adding a dedicated single-wire transport
   stanza (like `transport_uart.md`) to the template.

2. **No worked examples in datasheet.** The datasheet gives the 40-bit frame formula
   and resolution (0.1 %RH / 0.1 °C) but NO explicit hex/binary ↔ real-world example
   table. The template's "Worked Examples / Test Vectors" section is marked CRITICAL
   but had nothing to extract verbatim; I constructed inferred test vectors and
   clearly annotated them as derived (not datasheet-printed). Downstream skills should
   be aware inferred vectors may not be authoritative.

3. **OCR garbling.** The scanned datasheet produced noisy picture-text (e.g.
   "T_INT" sign bit details, checksum phrasing) though key values (voltage 3.3–6 V,
   ranges, accuracy, timings 50 µs / 26–28 µs / 70 µs, ≥1 ms start, 20–40 µs wait,
   80 µs response, >2 s collecting period) were recoverable. The temperature sign-bit
   encoding is NOT explicit in the datasheet text and had to be inferred from the
   −40…+80 °C range + ESPHome implementation.

4. **`analog.sh` only special-cases analog.com.** For non-analog URLs it still echoes
   the wayback fallback, which is fine, but the dual-output (original + wayback) was
   slightly confusing; direct curl at the original URL was sufficient.

5. **Minor:** "DHT22 also named as AM2302" — datasheet is shared with AM2302/RHT03
   family; the spec notes this only in passing. Fine for a device-level spec.

## Suggested improvements

- Add a "single-wire / one-wire" transport template section (start-signal, response,
  bit-encoding timing) analogous to `transport_uart.md`.
- In Step 5, when the datasheet lacks worked-example tables, either (a) require the
  skill to explicitly flag that and generate clearly-annotated inferred vectors, or
  (b) relax the "CRITICAL" worked-examples requirement for non-register devices.
- Consider a PDF-checkstep using `pdftotext`/`pdfinfo` page count to pre-warn about
  scanned-only (OCR) datasheets before the LLM step.

## Environment restated

- original_pwd: /home/pi/Developer/wokwi-ai
- device: dht22
- esphome component: dht (wrote `esphome_component.txt` to outputs)