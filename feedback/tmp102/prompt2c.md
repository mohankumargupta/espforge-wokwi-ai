# prompt2c feedback — tmp102 test harness

Skill: wokwi-test-harness
Device: tmp102

## What went well

- Followed template preservation rules: added only i2c/sensor sections and the
  single allowed `on_boot` under `esphome:`; kept `name: dut`.
- `on_boot` only issues `component.update` on the sensor id; the observable log
  lives in the sensor's `on_value:` trigger, so the printed value is guaranteed
  non-NaN/published (avoids the documented `delay()` race).
- Ground-truth value `21.0` taken verbatim from the Canonical Test Spec; the
  presentation string "Temperature = 21.0 C" matches the spec template
  `"Temperature = {:.1f} C"`.
- Used primary i2c1 pins (sda 4, scl 5) from assets/esp32c3.yaml.
- Compiled cleanly for aarch64-unknown-linux-gnu on first try.

## Obstacles / notes

- The esphome `tmp102` driver itself logs `Got Temperature=%.1f°C` at DEBUG in
  tmp102.cpp before publishing; the harness asserts on the canonical-pmu
  "Temperature = 21.0 C" line emitted by the `on_value` lambda, not on that
  driver-internal debug log, to keep ground truth spec-based.
- `assert_serial!` uses substring `contains`, so the boot-log timestamp prefix
  on the logger line is harmless.
- Keep `cargo test -- --test-threads=1` because the rfc2217 stream is a single
  mutable connection shared across tests (one reader per test process via
  thread-local storage).
- The I2C scan assertion `Found i2c device at address 0x48` depends on the
  chip being wired to the primary bus; confirmed by diagram.json at outputs.

## Improvements

- Could assert component `dump_config` "TMP102:" as a setup heartbeat before the
  i2c discovery lines; left out to keep to happy path.
- If the simulated chip reports anything other than 21.0C, that is a chip.zig
  encoding defect, not a reason to change the expected string (per skill rule).