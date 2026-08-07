# Feedback — prompt0c (data-conversions-complex-logic): TMP102

## What went well
- The canonical spec (`spec_tmp102.md`) gives a clean normal-mode (12-bit)
  decode formula and a worked-value table that round-trips cleanly at both 12
  and 13 bits once you encode register words as `count << N` (spec even flags
  this).
- Downstream reuse was natural to design: the module `root.zig` is imported as
  the shared `prompt0c` module, so it already is the single source of truth.

## Obstacles / ambiguities
1. **Extended-mode (13-bit) example is easily misread.** `spec_tmp102.md:168`
   states "150 C = 0x0960". Taken literally as a register word that contradictds
   the stated left-alignment (datasheet Table 6-8/6-9 stores T12..T0 at bits
   15:3 and sets D0 of byte 2 = 1). 0x0960 is the *13-bit count*, not the
   register word. I resolved this by consulting the raw datasheet
   (`prompt0a/datasheet/tmp102_datasheet.md`), implemented the datasheet layout,
   and documented the discrepancy in the manifest. Recommendation: the spec could
   add a note that extended examples are right-aligned counts, not register
   words, so downstream does not have to re-derive it.
2. **`spec_tmp102.md` shifting notation is overloaded.** "shift by 15 bits"
   (line ~146) for extended mode is a typo for an arithmetic right-shift of the
   register word; actual decode is `(i16)reg >> 3` (13-bit) / `>> 4` (12-bit).
3. `config` field semantics were excluded from the canonical test, but they are
   pure bit layouts so I still encoded them + conversion-rate/fault-queue maps;
   required pulling exact bit positions from the datasheet (not the spec, which.
   only shows reset value 0x6080).
4. Minor: `std.math.clamp` needs i32 for the encode path so the 13-bit clamp
   (`[-4096,4096]`) and 12-bit clamp fit within 16-bit signed casts without
   overflow.

## Suggestions
- Clarify the spec that 13-bit examples are right-aligned counts.
- Recommend adding the datasheet Table 6-2 to the canonical spec so the 
   correct extended-mode bit positions (bits 15:3 + bit-0 marker) are 
   authoritative there rather than only in the raw datasheet.