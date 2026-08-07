# Feedback: prompt2c (wokwi-test-harness) - TMP102

## Summary

This was a full test harness for the TMP102 I2C temperature sensor:
- ESPHome yaml (`tmp102.yaml`) with an `on_boot` section that triggers a
  sensor update and prints the canonical presentation `Temperature = %.1f C`.
- Rust std test project `qa_test` with happy-path serial assertions.

## What went well

- The template copied cleanly; the only in-block edit was the mandated `on_boot`
  addition, and all device-specific YAML was appended after the template.
- Pin numbers came straight from `assets/esp32c3.yaml` primary `i2c1` bus
  (sda 4, scl 5), so no pin drift with the diagram.json generator.
- `esphome config tmp102.yaml` validated successfully.
- `cargo build --target aarch64-unknown-linux-gnu` compiled cleanly the first
  time; the `assert_serial!` macro and `qa_test` scaffolding were copied
  verbatim from the skill assets.
- Build artifacts stay untracked; only source files were copied to outputs.

## Obstacles

1. The `on_boot` addition must live inside the `esphome:` block, which slightly
   contradicts the "append after the template" wording. Existing template lines
   were preserved in place; the added keys come after `name: dut`. It may help
   to note explicitly that `on_boot` is an allowed exception.
2. The correct begin action to trigger a sensor refresh is `component.update:`
   (not `sensor.update:`, which does not exist). Because tmp102 publishes
   asynchronously, a `delay: 1s` before reading `state` was needed. The skill's
   references don't specify this pattern.
3. For a more deterministic smoke test, the harness relies on the chip's default
   value exactly matching the spec default (21.0). That is the intended
   contract; worth keeping in mind when the chip.zig encoding diverges.

## Improvement suggestions

- Add the `component.update` + `delay` + lambda print pattern to the skill's
  core-configuration reference.
- Clarify the allowed exception for adding `on_boot` to the `esphome:` block.
- Note that `target/`, `.esphome/`, and other build dirs should not be copied
  to outputs.

## Produced files

- `artifacts/tmp102/prompt2c/tmp102.yaml`
- `artifacts/tmp102/prompt2c/qa_test/{Cargo.toml,src,tests/test.rs}`
- `artifacts/tmp102/outputs/wokwi.toml`
- `artifacts/tmp102/outputs/qa_test/...`