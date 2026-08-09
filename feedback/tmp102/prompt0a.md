# Skill Feedback: spec-from-datasheet (prompt0a) — tmp102

## What worked

- `components.sh` was fast (both `components` and `esphome` already cloned).
- The esphome.io docs search (`rg -i tmp102 components`) found the component in
  one shot; the esphome source copy path was `esphome/esphome/components/tmp102`
  (nested `esphome/` dir inside the clone), which took a moment to discover.
- The TI TMP102 datasheet downloaded directly with `curl -L` from the symlink URL
  (no wayback fallback needed). `file` confirmed a valid PDF 1.4.
- `uv init` + `uv add pymupdf4llm` + `uv run main.py` produced a clean 1047-line
  markdown. Page/header/footer stripping worked well; all tables (pin functions,
  register formats, temperature data tables, fault settings) came through intact.

## Obstacles / issues

1. **analog.sh prints two URLs.** For a non-`analog.com` URL it echoes the URL
   AND waybackpy also prints a wayback URL, so the command outputs two lines and
   the "real" URL is ambiguous. I ignored the wayback line and used the direct
   URL. The script should capture waybackpy output into a variable for the
   non-analog case too (currently the function assigned 1st line result to
   `newurl`).
2. **OCR noise.** The PDF contains a lot of scanned figure text ("Start of picture
   text" blocks) with garbled superscripts/subscripts (e.g. `I <sup>2</sup> C`,
   table cell soup in Table 6-14/6-15/6-16 where the HIGH/LOW byte fields got
   interleaved). I had to manually re-derive the THIGH/TLOW byte layouts from the
   temperature register layout.
3. **Template `Registers` vs datasheet pointer scheme.** TMP102 uses an 8-bit
   pointer register with 2-bit P1:P0 select (0x00–0x03), which maps cleanly onto
   the template "Address" column, but the template assumes contiguous addresses
   and I had to note the P2–P7-must-be-zero quirk.
4. **Data-Format ambiguity confirmed.** The datasheet HEX column is the bare
   12-bit count (e.g. 25°C = 0x190), not the 16-bit register word (0x1900).
   Following the template guidance I stated the encoding per row ("raw 12-bit
   count; register word = count << 4") so downstream skills do not need to guess.
5. **Reset values** for TLOW/THIGH (75 °C => 0x4B00, 80 °C => 0x5000) were not in
   a single table; they came from prose (Section 6.5.4) and had to be converted
   from °C to the left-aligned word.
6. The `@1`-style footnote I first wrote rendered awkwardly in a table cell; I
   replaced with a `<sup>1</sup>` marker and a numbered note.

## Improvements suggested

- Fix analog.sh so it emits a single URL (quiet waybackpy, and for non-analog
  URLs also check archive as a fallback if the direct download fails).
- After `main.py`, run a pass to merge/reflow the "Start of picture text" ...
  "End of picture text" blocks so broken scanned tables get flagged for manual
  review rather than silently interleaved.
- Consider logging pinned file paths (esphome nested-components source dir) so the
  operator doesn't have to hunt for `esphome/components` vs `esphome/esphome/components`.