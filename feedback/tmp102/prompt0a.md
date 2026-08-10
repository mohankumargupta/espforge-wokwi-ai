# Skill Feedback — prompt0a (spec-from-datasheet, device: tmp102)

## What went well

- The datasheet URL was found via `rg` in the esphome component source
  (`esphome/esphome/components/tmp102/__init__.py`), not in the `.mdx` docs
  page — the docs page only links to a SparkFun product page. The skill's
  fallback search (rg in esphome tree) handled this well.
- `analog.sh` returned a working web.archive.org URL; the curl download produced
  a clean 470KB PDF (v1.3, not encrypted).
- `pymupdf4llm` extraction was high quality: all register tables, pointer
  addresses, timing, and the 12-bit/13-bit worked-example tables came through
  cleanly. OCR only kicked in for 3 tail pages (packaging, tape/reel) which are
  not needed for the chip spec.

## Obstacles / notes

1. **mux/alternate address info is not in docs.** esphome.io tmp102 docs only
   mention `0x48`. Real alternate addresses come from the datasheet's
   "Address Pin and Slave Addresses" table (ADD0 → GND/V+/SDA/SCL = 0x48/0x49/0x4A/0x4B).
   The spec captured all four; nothing blocked, just required the datasheet.
2. **PDF has two column-halves mangled by header/footer strip.** The gutter
   "www.ti.com ..." lines get merged into the text as `<br>`-joined cells. Easy
   to ignore but consumes context.
3. **Extended-mode encoding ambiguity.** Datasheet Table 6 lists 13-bit values
   with a leading "0 " or "1 " prefix in binary but a 4-hex char code (e.g.
   +150 → `0 1001 0110 0000` hex `0960`). That hex is the raw 13-bit count, NOT
   the register word. The template's "Encoding (raw N-bit count | full register
   word, alignment bits)" column forced me to resolve this explicitly instead of
   passing it downstream — good design.
4. **128°C quirk:** datasheet Table 5 lists both 128 and 127.9375 → 0x7FF
   (12-bit can't represent 128). I noted this in the worked-examples table since
   it could confuse downstream unit tests.
5. **`uv init` hardcodes project name `datasheet`** — harmless but slightly
   noisy. Running inside an existing repo creates README.md and pyproject
   each time; would be nice to use `--bare`/`--no-readme` for repeatability
   (leaves stray files if not cleaned).
6. The skill's Step numbering is inconsistent ("Step 2" used twice) — minor.

## Suggestions

- Consider scanning both the `.mdx` AND the esphome component `__init__.py` /
  `sensor.py` for datasheet URLs in one pass — here the URL was only in the
  Python source.
- The template_chip.md worked-examples guidance worked very well; consider
  adding an explicit "diagrams stripped" note to the extraction step since
  figures 12-15 (timing waveforms) are dropped by `ignore_images`.