# Skill Feedback: canonical-test-spec (dht22)

## Summary

Produced `artifacts/dht22/outputs/test_spec_dht22.md` for the DHT22
humidity/temperature sensor from `spec_dht22.md`, `dht.mdx`, and the ESPHome
`dht` component source (`dht.cpp`, `dht.h`, `sensor.py`).

## What went well

- The YAML schema maps cleanly onto a single-wire, host-initiated, 40-bit-frame
  device even though DHT22 is not register-mapped.
- The `default` value guidance ("one default per observable, single source of
  truth") was directly usable. I chose the inferred test vectors from
  `spec_dht22.md` (25.0 C / 50.4 %) and verified they form a single
  self-consistent 40-bit frame with a valid checksum
  (0x01 0xF8 0x00 0xFA 0xF3), which gives the wokwi-customchip skill a concrete
  byte stream to emit and the wokwi-test-harness skill a concrete expected value.
- The "template is language-neutral, translate {:.1f} -> %.1f" note is valuable
  and I carried it forward verbatim-ish.

## Obstacles / points to improve

1. **Not a register-mapped device.** The skill's examples (TMP102, BMP280,
   SCD40) are all I2C register devices. DHT22 is a single-wire 40-bit-frame
   device with no address and no registers. The observables/presentation/
   traceability sections all apply, but there is no guidance on where to record
   the frame-encoding ground truth (the byte stream that encodes the `default`
   values). I put it in a "default — single source of truth" subsection, but a
   dedicated `default_frame:` or `frame:` field (raw bytes that encode the
   defaults) would make the contract machine-readable and unambiguous for
   downstream generator skills instead of requiring them to parse prose.
2. **`units` with `%`** — the SCD40 spec uses `units: "%"` (quoted). This skill
   body only mandates plain-ASCII, not quoting; I followed the SCD40 precedent.
   Consider stating explicitly that `%` should be quoted in YAML.
3. **Multiple observables from one transaction.** The skill examples show
   one-observable-per-transaction devices. DHT22 produces both temperature and
   humidity in a single 40-bit frame. The spec handles it, but a short
   "relationship between observables and transactions" note (e.g. all
   observables share one bus read) would help downstream skills avoid
   generating two independent reads.
4. **Precision sourcing.** Temperature `accuracy_decimals=1` comes from the
   component schema, but humidity defaults to `accuracy_decimals=0` in
   `sensor.py` while the docs note it "is worth" configuring to 1 for DHT22.
   The device resolution (0.1 %RH) argues for precision 1. I sourced precision
   from device resolution + docs recommendation and documented the deviation;
   the skill gives no guidance for this conflict between schema default and
   device resolution.

## Suggested improvements

- Add an optional `frame:` / `default_frame:` field (raw byte stream encoding
  the defaults) for non-register, frame-oriented devices.
- Note whether `%` must be quoted in the `units:` YAML value.
- Add guidance for multi-observable single-transaction devices.
- Clarify which source wins when the ESPHome schema default conflicts with
  documented device resolution for `accuracy_decimals` / precision.

## Environment restated

- original_pwd: /home/pi/Developer/wokwi-ai
- device: dht22
- esphome component: dht
- inputs read: spec_dht22.md, dht.mdx, dht/dht.cpp, dht/dht.h, dht/sensor.py
- output: artifacts/dht22/outputs/test_spec_dht22.md
