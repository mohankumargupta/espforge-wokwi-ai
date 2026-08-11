# prompt2c Feedback — wokwi-test-harness (scd40)

## What went well

- The Canonical Test Specification (`test_spec_scd40.md`) gave exact observable
  defaults (CO2=500 ppm, Temperature=25.00 C, Humidity=37.00 %) and exact
  printf-style presentation templates, which made generating both the yaml and
  the qa_test assertions straightforward and consistent.
- The scd4x component source (`*.cpp` / `*.h`) clarified that the driver only
  publishes after data-ready, so the `on_value` trigger approach (rather than a
  fixed `delay:` after `component.update`) is correct and race-free.

## Obstacles / observations

- The spec's `presentation.<observable>.template` uses Python-style precision
  (`{:.0f}` / `{:.2f}`). These must be translated to printf specifiers
  (`%.0f` / `%.2f`) inside the ESP_LOGI lambdas. The Humidity template ends with
  a literal `%`, which also has to be escaped as `%%` in the printf string.
- Initial yaml relied on a single `on_boot -> component.update` without an
  `update_interval`; since scd4x initialization is asynchronous (setup timers:
  1000ms stop-measurement, 500ms recovery), a single boot-time update may race.
  Keeping the log in `on_value` and setting `update_interval: 5s` makes the
  first publish deterministic without a fixed delay.
- The `component.update: scd40` id referenced at the platform level; sensor
  ids are the child `co2`/`temperature`/`humidity`. Glad the scd4x component
  uses `PollingComponent`, so updating the platform id works.

## Improvements for next time

- The skill could state explicitly that printf literal-`%` escaping (`%%`) is
  part of the "format-string translation" rule, since the humidity template
  contains a bare `%`.