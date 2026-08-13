# Feedback: wokwi-test-harness (prompt2c) — DHT22

## Summary

Created the full test harness for the DHT22 custom chip from the Canonical
Test Specification (`artifacts/dht22/outputs/test_spec_dht22.md`):

- `artifacts/dht22/prompt2c/dht22.yaml` — ESPHome config, validated with
  `esphome config` (valid).
- `artifacts/dht22/prompt2c/qa_test/` — Rust std test project compiled for
  `aarch64-unknown-linux-gnu` (builds clean).
- Copied `dht22.yaml`, `qa_test/`, and the skill's `wokwi.toml` into
  `artifacts/dht22/outputs/`.

## Design decisions

- **Bus wiring**: DHT22 is a single-wire device (no i2c/spi/uart bus), so it
  uses a free primary GPIO. Matched `diagram.json` (prompt2a): `GPIO3` for the
  DATA pin. (pin 3 is not reserved, not on the i2c1/spi1/uart1 pairs).
- **Model**: `model: DHT22` set explicitly — the test spec excludes the
  AUTO_DETECT fallback logic, and forcing the model keeps the read on the
  canonical DHT22 decode path.
- **Race-condition avoidance**: the observables are event-driven, so `on_boot`
  only issues `component.update: dht22` (forces the first read instead of
  waiting up to `update_interval: 60s`), and the actual log lines live in each
  sensor's `on_value:` trigger. This guarantees the printed value is the
  driver-published, non-NaN state — no fixed `delay:` guesswork.
- **Format translation**: spec templates `"Temperature = {:.1f} C"` and
  `"Humidity = {:.1f} %"` were translated to printf-style. The `%` literal in
  the humidity template is escaped as `%%` in the `logger.log` format string.
  Verified no `{:` remains in the generated yaml.
- **Ground truth assertions**: `tests/test.rs` asserts exactly the spec
  defaults — `Temperature = 25.0 C` and `Humidity = 50.4 %` — copied verbatim
  from the spec, not recomputed.
- **Only own-lambda strings asserted**: no framework-generated log lines
  (dump_config, boot banners, etc.) are asserted, per the skill's guidance.

## Notes / obstacles

1. Template preservation: the on_boot exception requires editing the `esphome:`
   block (the only sanctioned modification). The rest of the template lines are
   untouched, and the sensor config is appended after the template content.
2. Humidity default `accuracy_decimals` in `sensor.py` is `0` (DHT11 legacy);
   the spec mandates `1`, so `accuracy_decimals: 1` is set explicitly for both
   sensors.
3. `cargo new` emits a note about the workspace/inheritance keys in Cargo.toml;
   the skill's Cargo.toml dependency-comment block was re-added to match the
   template. Edition 2024 matched the skill asset.
4. Not run against a live simulator in this session — `assert_serial!` strings
   were taken only from the on_value lambdas this skill generated, which are
   fully under the skill's control.
