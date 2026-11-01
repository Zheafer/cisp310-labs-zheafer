; =============================================================================
;  CISP 310 - Lab 6: The Telemetry Library (module 2 of 2)     (STUDENT STARTER)
;  File: Lab06_Main.asm               Rover Telemetry Project, Part 6 of 10
;
;  This module drives the library in Lab06_TelemetryLib.asm. Both .asm files
;  go in ONE Visual Studio project (both set to Item Type = Microsoft Macro
;  Assembler). The linker joins them. INVOKE here calls procedures that live
;  in the other file, guided only by the PROTOs in Lab06_Common.inc.
;
;  Author:            <your name>
;  Date:              <date>
; =============================================================================

.686
.model flat, stdcall
option casemap:none
.stack 4096

includelib kernel32.lib
includelib msvcrt.lib
includelib legacy_stdio_definitions.lib

printf PROTO C :PTR SBYTE, :VARARG

INCLUDE Lab06_Common.inc

; =====================================================================
;  SELF-CHECK HARNESS  (instructor-provided -- DO NOT EDIT)
;  You will learn how MACROs work in Chapter 6. Until then all you
;  need to know: mCHECK compares one of your results with the expected
;  value and prints PASS or FAIL.  It destroys EAX, ECX, EDX.
; =====================================================================
CheckEq  PROTO C :PTR BYTE, :DWORD, :DWORD
Summary  PROTO C

mCHECK MACRO nameText:REQ, actualMem:REQ, expectedVal:REQ
    LOCAL nm
    .data
nm  BYTE nameText, 0
    .code
    INVOKE CheckEq, ADDR nm, actualMem, expectedVal
ENDM

; ---------------------------------------------------------------------------
;  TODO 4: your first MACRO. A macro is text that the assembler pastes in
;  wherever you use it. mCHECK (just above) is your model. Finish mPrintDec
;  so that       mPrintDec <"minTemp">, stats.minTemp
;  prints        minTemp = -73
;
;  Four lines, copied from mCHECK's shape:
;      .data
;  fm  BYTE labelText, " = %d", 10, 0     ; build the format string
;      .code
;      INVOKE printf, ADDR fm, value
;  (LOCAL fm is given: each use gets its own fresh label name.)
; ---------------------------------------------------------------------------
mPrintDec MACRO labelText:REQ, value:REQ
    LOCAL fm
        .data
fm  BYTE labelText, " = %d", 10, 0
    .code
    INVOKE printf, ADDR fm, value

    ; >>> TODO 4: .data / fm BYTE labelText, " = %d", 10, 0 / .code / INVOKE printf, ADDR fm, value (4 lines) <<<
ENDM
; =============================================================================
.data
;                SYNC  ID   FLAGS TEMlo TEMhi BATlo BAThi CHK
packets     BYTE 0A5h, 01h, 13h, 0F2h, 0FFh, 5Eh, 0Fh, 0E9h   ; 0
            BYTE 0A5h, 02h, 21h, 0D7h, 00h,  04h, 10h, 4Dh    ; 1
            BYTE 0A5h, 03h, 01h, 7Eh,  01h,  88h, 0Eh, 42h    ; 2
            BYTE 0A5h, 04h, 15h, 0B7h, 0FFh, 0EAh, 0Bh, 97h   ; 3
            BYTE 0A5h, 05h, 35h, 78h,  00h,  0AEh, 0Bh, 0F0h  ; 4
            BYTE 5Ah,  06h, 01h, 00h,  00h,  68h,  10h, 0DCh  ; 5 bad sync
            BYTE 0A5h, 07h, 09h, 0FFh, 00h,  28h,  0Fh, 16h   ; 6 bad checksum
            BYTE 0A5h, 08h, 03h, 0C7h, 00h,  10h,  0Eh, 6Bh   ; 7

stats       STATS <>              ; one statistics record
fmtTitle    BYTE "=== Lab 6: The Telemetry Library ===",10,10,0

; =============================================================================
.code
main PROC C USES ebx esi edi
    INVOKE printf, ADDR fmtTitle

    INVOKE Stats_Reset, ADDR stats

    ; -------------------------------------------------------------------
    ;  TODO 3: feed all 8 packets through Stats_Update. With INVOKE the
    ;  loop is short. ESI = packet pointer, EBX = packets left:
    ;      mov  esi, OFFSET packets
    ;      mov  ebx, NUM_PACKETS
    ;    scan_loop:
    ;      INVOKE Stats_Update, ADDR stats, esi
    ;      add  esi, PACKET_SIZE
    ;      dec  ebx
    ;      jnz  scan_loop
    ;  ESI survives because Stats_Update declares USES esi. EBX survives
    ;  because no procedure in the call chain ever writes it (and under the
    ;  Win32 convention EBX is callee-saved: whoever uses it must restore it).
    ; -------------------------------------------------------------------
    ; >>> TODO 3: loop over the 8 packets, INVOKE Stats_Update on each (7 lines) <<<

        mov  esi, OFFSET packets
    mov  ebx, NUM_PACKETS
scan_loop:
    INVOKE Stats_Update, ADDR stats, esi
    add  esi, PACKET_SIZE
    dec  ebx
    jnz  scan_loop

    ; ---- report through YOUR macro (expands 4 times - find them in the .lst)
    mPrintDec <"validCount">, stats.validCount
    mPrintDec <"sumTemp">,    stats.sumTemp
    mPrintDec <"minTemp">,    stats.minTemp
    mPrintDec <"maxTemp">,    stats.maxTemp

    ; -------------------------------------------------------------------
    ;  BONUS (not graded): the OTHER calling convention. printf is cdecl:
    ;  the CALLER cleans the stack. Declare a procedure "PROC C" and then a
    ;  hand-made call needs ADD ESP after it:
    ;      push arg2 / push arg1 / call MyProc / add esp, 8
    ;  Try it: write  AvgTimes10 PROC C sumT:SDWORD, cnt:DWORD  in the
    ;  library, add its PROTO C to the .inc, and call it both by hand and
    ;  with INVOKE. Compare the two call sites in the .lst file.
    ; -------------------------------------------------------------------

    ; =====================================================================
    ;  SELF-CHECK (do not edit)
    ; =====================================================================
    mCHECK <"validCount">, stats.validCount, 6
    mCHECK <"sumTemp">,    stats.sumTemp,    829
    mCHECK <"minTemp">,    stats.minTemp,    -73
    mCHECK <"maxTemp">,    stats.maxTemp,    382
    INVOKE Summary

    xor  eax, eax
    ret
main ENDP

; =====================================================================
;  Self-check implementation (DO NOT EDIT below this line)
; =====================================================================
.data
chkTotal  DWORD 0
chkFail   DWORD 0
fmtPass   BYTE "  PASS   %-22s  got %d (0x%08X)", 10, 0
fmtFail   BYTE "* FAIL   %-22s  got %d (0x%08X), expected %d (0x%08X)", 10, 0
fmtAllOk  BYTE 10, ">>> ALL %d CHECKS PASSED -- lab complete!", 10, 0
fmtBad    BYTE 10, ">>> %d of %d checks failing -- keep going.", 10, 0

.code
CheckEq PROC C pName:PTR BYTE, actualVal:DWORD, expectVal:DWORD
    inc  chkTotal
    mov  eax, actualVal
    cmp  eax, expectVal
    jne  ce_fail
    INVOKE printf, ADDR fmtPass, pName, eax, eax
    ret
ce_fail:
    inc  chkFail
    INVOKE printf, ADDR fmtFail, pName, eax, eax, expectVal, expectVal
    ret
CheckEq ENDP

Summary PROC C
    mov  eax, chkFail
    test eax, eax
    jnz  sm_bad
    INVOKE printf, ADDR fmtAllOk, chkTotal
    ret
sm_bad:
    INVOKE printf, ADDR fmtBad, chkFail, chkTotal
    ret
Summary ENDP

END
