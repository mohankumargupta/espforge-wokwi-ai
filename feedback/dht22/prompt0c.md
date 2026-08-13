# Skill Feedback: data-conversions-complex-logic (prompt0c)

Device: dht22

## Outcome

Completed successfully. Zig 0.16 project at `artifacts/dht22/prompt0c`
with conversion functions (humidity/temperature encode+decode, checksum,
whole-frame decode/encode) and 10 unit tests. `zig build` passes,
`zig build test` passes 11/11.

## Obstacles / notes

1. **Spec-internal contradiction in the worked-example table.** The table
   labels raw `0x8000` as `−10.0 °C` while its own derived comment says the
   formula produces `0.0`. The skill's own resolution rule ("worked-example
   table is authoritative over prose") did not directly apply because the
   table contradicts itself. I had to fall back on the decode formula as
   authoritative and record the discrepancy in the manifest + test. The skill
   could add guidance for the "table self-contradicts" case (table's derived
   value vs. its own label disagree).

2. **Spec has no true worked examples printed in the datasheet** — all vectors
   are inferred. This made it harder to validate against real data samples; I
   followed the "derive expected via the decode primitive" rule for the
   sign/negative raw vectors rather than hand-computing.

3. **Zig 0.16 test API confirmed** — `std.testing.expect*` return error unions
   and must be `try`'d, as the skill's note stated. No fuzz test included, so
   the `std.testing.Smith` note was not exercised.

4. **Template main() signature.** The `zig init` template uses
   `pub fn main(init: std.process.Init) !void`. I replaced it with a plain
   `pub fn main() void`, which compiled and ran fine under 0.16.0. Not an
   obstruction, but worth noting the template's generated example
   (`prompt0c.printAnotherMessage` import) must be removed alongside the
   rewrite so the exe module still builds.