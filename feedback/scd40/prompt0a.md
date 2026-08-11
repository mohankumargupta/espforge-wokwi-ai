# Skill Feedback: spec-from-datasheet (prompt0a) — scd40

Device: scd40 (esphome component: scd4x)

## Obstacles

1. Datasheet PDF = SCD4x family datasheet (SCD40/SCD41/SCD43), not SCD40-only. Had to
   disambiguate variant-specific features (single-shot, ASC periods, FRC) and clearly
   mark them as SCD41/SCD43-only in the spec.
2. The `analog.sh` script printed BOTH the original URL and the wayback URL, and the
   wayback URL emitted a trailing space/no newline separating them; needed careful
   parsing to select the `im_/` archive URL for download.
3. pymupdf4llm could not extract the pin-layout figure (Table 6 / Figure 3) as text, so
   exact pin-to-number mapping is missing in the markdown (only pin names/descriptions).
   Noted this in the spec with a pointer to the datasheet figure.
4. Table 40 (CRC) had embedded C example code that OCR'd messily; the CRC properties
   were recoverable but the code block needed manual clean-up.
5. Many tables use unicode primes (e.g. 2'000) and I2C<sup>2</sup> artifacts; normalized
   them in the spec output.

## Improvements

1. Since multiple espforge skills consume this spec, the "worked examples" encoding
   question was resolved up-front: SCD4x uses full 16-bit words with no alignment, so
   every example is a raw-16-bit-count == full register word. This is stated in the
   Worked Examples section header and repeated per row.
2. Consider documenting in the skill how to pick one variant (SCD40) when the datasheet
   covers a family, and how to mark sibling-variant features.
3. Suggest adding guidance: if a datasheet figure (pinout) is dropped by extraction,
   explicitly flag it as "confirm against Figure N" instead of silently omitting.