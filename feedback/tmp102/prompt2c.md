# prompt2c feedback — wokwi-test-harness for tmp102

Date: 2026-08-11

## Result

Generated successfully:

- `<artifacts_dir>/tmp102.yaml` (esphome config, validated with `esphome config`)
- `<artifacts_dir>/qa_test` rust std test project (compiles for `aarch64-unknown-linux-gnu`)
- copied `wokwi.toml`, `qa_test`, `tmp102.yaml` into `<outputs_dir>`

## Implementation notes

- Race-condition handling: used `on_boot: component.update: tmp102_sensor` to force the
  first read, but the printable observable is emitted by the sensor's `on_value:`
  automation (logger.log), never by an on_boot block that relies on a fixed delay.
- Format-string translation: spec template `"Temperature = {:.1f} C"` was emitted as
  printf-style `"Temperature = %.1f C"` in the logger.log `format:`; confirmed no `{:` leaks.
- Test ground truth: `assert_serial!("Temperature = 25.0 C")` copied verbatim from the
  spec's observable default (25.0, precision 1); not recomputed.
- Only asserted our own on_value lambda text. The I2C scan / driver log lines are
  framework-generated (version-sensitive) so they were deliberately NOT asserted.

## Obstacles

- `wokwi.toml` (copied verbatim from skill assets) references `.pioenvs/dut` build paths
  (arduino/core profile) while the template yaml uses `esp-idf` framework, which builds to
  a different path. This is a known drift risk in the harness glue — the firmware/elf fields
  may need updating depending on which ESPHome build backend actually runs in wokwi.
- `esphome_component.txt` contains only the component folder name (`tmp102`), so the driver
  log syntax had to be derived from reading `outputs/tmp102/tmp102.cpp` directly; the skill
  could state explicitly that reading the `.cpp` is expected for translation precision.
- Default build on this host is already `aarch64-unknown-linux-gnu`, so the required
  `--target` flag is the identity here; on an x86 host it would need rustc target support.

## Improvements

- Consider making the harness assert I2C discovery (e.g. address 0x48) as a root-cause aid,
  guarded as "framework-generated — verify against actual simulator output first", since a
  values-only assertion cannot distinguish a missing chip from a wrong response.
- Validate the actual firmware build path produced by `esphome compile` and sync it into
  `wokwi.toml` before writing it to outputs, instead of copying the template verbatim.