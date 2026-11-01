# Lab 6 — The Telemetry Library (PROC, INVOKE, Macros, Two Modules)

**Released:** Monday, Week 7 · **Due:** Sunday end of Week 8, 11:59 PM
**Reading:** Detmer Ch. 6 (incl. §6.5 macros) · **Files:** `Lab06_Common.inc`, `Lab06_TelemetryLib.asm`, `Lab06_Main.asm`

## Mission brief

Last week you built stack frames by hand. This week the assembler takes over the boilerplate — and because of last week, you can read what it writes. You also split the ground station into **two modules** sharing one contract file, which is how real assembly projects are organized.

## Project setup (different this week!)

One VS project, **both** `.asm` files added, each set to Item Type = Microsoft Macro Assembler. `Lab06_Common.inc` sits in the same folder.

## New machinery, one line each

- `Pkt_GetTemp PROC USES edx, pPkt:PTR BYTE` — the assembler writes the frame; `pPkt` means `[ebp+8]`
- `INVOKE Stats_Update, ADDR stats, esi` — the assembler writes the pushes and the call
- `[esi].STATS.minTemp` — a struct field through a pointer; assembles to `[esi+8]`
- `@@:` / `@F` — an unnamed label / "jump forward to the next one"
- `mPrintDec MACRO` — text the assembler pastes in wherever you use it

## The TODOs

| TODO | File | Lines | What | Check |
|---|---|---|---|---|
| 1 | Lib | 15 | `Pkt_IsValid` — your Lab 5 body, `pPkt` instead of `[ebp+8]` | `validCount` 6 (needs TODO 3 too) |
| 2 | Lib | 7 | min/max in `Stats_Update` with struct fields and `@@` | `minTemp` −73, `maxTemp` 382 |
| 3 | Main | 7 | the scan loop with INVOKE | `sumTemp` 829 (needs TODO 1 too) |
| 4 | Main | 4 | the `mPrintDec` macro body | (prints four lines) |

**Suggested order: 1 → 3 → build → 2 → 4.** No check can pass until TODO 1 and TODO 3 are both in, because nothing calls the library until the scan loop exists. After 1 and 3: two PASS. After 2: four PASS.

## Required experiment (README)

Build with a listing file on (Project → the `.asm` file's Properties → Listing File → Assembled Code Listing). In `Lab06_TelemetryLib.lst`, find the prologue the assembler wrote for `Stats_Update`. Quote the 3–4 generated lines and match each to a line you typed by hand in Lab 5.

## README questions

1. In the `.lst` or map file, find the decorated name of `Stats_Update`. It ends in `@8`. What is the 8?
2. `Stats_Update` ends in plain `RET`, yet the stack balances. Reconcile this with Lab 5's `RET 8`.
3. Why does EBX survive eight `INVOKE Stats_Update` calls in your TODO 3 loop without you saving it?

## Submit

Push to `cisp310-labs-<username>/Lab06/`: the `.asm` files, `README.md`, and a screenshot of `ALL 4 CHECKS PASSED`. Paste the folder URL into Canvas. Canvas timestamp is the official clock.

## Grading

Builds with 0 errors · all 4 checks PASS · code quality (right instruction for the data type, comments that say *why*) · README. Point values are in the syllabus.

## Survival notes

- Error **A2137 "conflicting parameter definition"** = your PROC's parameters don't match the PROTO in the `.inc`. They must agree exactly.
- Macro body missing `.code` after the `.data` line → everything after the first use assembles into the data segment; the errors are baroque. Check that first.
