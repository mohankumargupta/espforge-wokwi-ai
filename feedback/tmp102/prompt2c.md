# Feedback: wokwi-test-harness for tmp102

## Summary

Generated the full test harness for the TMP102 temperature sensor:

- `artifacts/tmp102/prompt2c/tmp102.yaml` — ESPHome config
- `artifacts/tmp102/prompt2c/qa_test/` — Rust std integration test project
- `artifacts/tmp102/outputs/{tmp102.yaml,wokwi.toml,qa_test}` — copied artifacts

## What worked

- `esphome config tmp102.yaml` validated cleanly (ESPHome 2026.5.3).
- `cargo build --target aarch64-unknown-linux-gnu` compiled with no errors.
- Spec was complete: canonical presentation `Temperature = {:.1f} C` with default
  21.0 C made the on_boot serial assertion straightforward.

## Obstacles

1. The skill's STEP 1 says "copy assets/template.yaml to <artifacts_dir>/<device>.yaml"
   and the one-and-only exception is adding `on_boot`. Adding `on_boot` inside the
   `esphome:` block conflicts with the "do not edit existing values" rule — this
   required inserting a new key inside the esphome block, which technically modifies
   the template section. I kept the modification minimal (only inserted on_boot).

2. The template has `esp32:` before `logger:`, but the TMP102 needs `i2c:` and
   `sensor:` sections. These must be appended after the template content, which is
   fine per the rules, but nothing in the skill states the order for i2c vs sensor
   vs on_boot. I used primary i2c1 (SDA GPIO4, SCL GPIO5) from esp32c3.yaml as
   instructed.

3. The on_boot lambda reads `id(dut_temp).state`. At boot the sensor may not have a
   first reading yet (update_interval 1s), so I used `priority: 250` plus a
   `delay: 1500ms` before logging to give the sensor time to publish. This timing
   is empirical and could be fragile — the spec does not define boot-up ordering.
   Worth a note in the skill that on_boot assertions must wait for the first
   sensor sample.

4. The default `assert_serial!` timeout is 60s. The example uses an 800ms timeout
   for periodic reads. For a single-shot boot read this is fine, but a generic
   guideline about when to pass explicit timeouts would help.

5. `logger: hardware_uart: UART0` is retained from template (required for Wokwi
   serial over the rfc2217 port). Good.

## Improvements

- Explicitly document where to place the on_boot read relative to sensor setup
  (recommend an on_boot with priority 250 and a delay, or a "wait for first value"
  pattern).
- Note that `cargo new --lib qa_test` creates edition 2024 by default; the skill
  example Cargo.toml also uses edition 2024, so no mismatch.
- Could document the target triple requirement for the build (aarch64-unknown-linux-gnu
  must be installed via rustup) — it failed silently-fast only because the target
  was already installed here.
