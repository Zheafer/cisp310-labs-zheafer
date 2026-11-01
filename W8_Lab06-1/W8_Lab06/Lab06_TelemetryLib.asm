; =============================================================================
;  CISP 310 - Lab 6: The Telemetry Library (module 1 of 2)     (STUDENT STARTER)
;  File: Lab06_TelemetryLib.asm       Rover Telemetry Project, Part 6 of 10
;
;  THE STORY SO FAR: Last week you wrote stack frames by hand. This week the
;  assembler writes them for you:
;
;      Pkt_GetTemp PROC USES edx, pPkt:PTR BYTE
;
;  means: "push ebp / mov ebp,esp / push edx" at the top, "pop edx / leave /
;  ret 4" at the bottom (LEAVE = mov esp,ebp + pop ebp in one instruction),
;  and every "pPkt" in the body becomes [ebp+8].
;  Exactly what you typed in Lab 5. Build with a listing file and look.
;
;  This file has NO main. It is a library. Lab06_Main.asm calls it, guided
;  only by the PROTOs in Lab06_Common.inc.
;
;  Author:            <Shea Fuller>
;  Date:              <11/1/26>
; =============================================================================

.686
.model flat, stdcall
option casemap:none

INCLUDE Lab06_Common.inc

.code

; ---------------------------------------------------------------------------
;  Pkt_GetTemp (GIVEN) - compare with your Lab 5 version. Same instructions,
;  no frame to type.
; ---------------------------------------------------------------------------
Pkt_GetTemp PROC USES edx, pPkt:PTR BYTE
    mov   edx, pPkt
    movsx eax, WORD PTR [edx+3]
    ret
Pkt_GetTemp ENDP

; ---------------------------------------------------------------------------
;  Stats_Reset (GIVEN) - zero the record. [esi].STATS.field is how you reach
;  a field through a pointer; the assembler turns it into [esi+offset].
; ---------------------------------------------------------------------------
Stats_Reset PROC USES esi, pStats:PTR STATS
    mov  esi, pStats
    mov  [esi].STATS.validCount, 0
    mov  [esi].STATS.sumTemp,    0
    mov  [esi].STATS.minTemp,    7FFFFFFFh
    mov  [esi].STATS.maxTemp,    80000000h
    ret
Stats_Reset ENDP

; ---------------------------------------------------------------------------
;  TODO 1: Pkt_IsValid, ported from Lab 5. The frame is gone - USES ecx edx
;  saves the registers, pPkt replaces [ebp+8], and a plain RET is enough
;  (the assembler turns it into RET 4). The body is the SAME as Lab 5
;  (13 instructions + 2 labels); keep the RET already below your gap:
;      mov  edx, pPkt
;      cmp  BYTE PTR [edx], SYNC_BYTE
;      jne  iv_bad
;      xor  eax, eax
;      mov  ecx, PACKET_SIZE
;    iv_sum:
;      add  al, BYTE PTR [edx]
;      inc  edx
;      loop iv_sum
;      test al, al
;      jnz  iv_bad
;      mov  eax, 1
;      ret
;    iv_bad:
;      xor  eax, eax
; ---------------------------------------------------------------------------
Pkt_IsValid PROC USES ecx edx, pPkt:PTR BYTE
    ; >>> TODO 1: the Lab 5 body, using pPkt instead of [ebp+8] (see comment) <<<
    mov  edx, pPkt
    cmp  BYTE PTR [edx], SYNC_BYTE
    jne  iv_bad
    xor  eax, eax
    mov  ecx, PACKET_SIZE
iv_sum:
    add  al, BYTE PTR [edx]
    inc  edx
    loop iv_sum
    test al, al
    jnz  iv_bad
    mov  eax, 1
    ret
iv_bad:
    xor  eax, eax
    ret
Pkt_IsValid ENDP

; ---------------------------------------------------------------------------
;  Stats_Update(pStats, pPkt): if the packet is valid, fold its temperature
;  into the record. The validity check and the count/sum are given; you
;  write the min/max, using ANONYMOUS LABELS:
;      @@:   is a label with no name
;      @F    means "jump forward to the next @@"
; ---------------------------------------------------------------------------
Stats_Update PROC USES esi, pStats:PTR STATS, pPkt:PTR BYTE
    INVOKE Pkt_IsValid, pPkt      ; INVOKE = "push the args and CALL" for me
    test eax, eax
    jz   su_done                  ; invalid packet: nothing to record

    mov  esi, pStats
    inc  [esi].STATS.validCount
    INVOKE Pkt_GetTemp, pPkt      ; EAX = temperature
    add  [esi].STATS.sumTemp, eax

    ; -------------------------------------------------------------------
    ;  TODO 2: Lab 4's min/max, written with struct fields and @@ labels:
    ;      cmp  eax, [esi].STATS.minTemp
    ;      jge  @F
    ;      mov  [esi].STATS.minTemp, eax
    ;  @@: cmp  eax, [esi].STATS.maxTemp
    ;      jle  @F
    ;      mov  [esi].STATS.maxTemp, eax
    ;  @@:
    ; -------------------------------------------------------------------
    ; >>> TODO 2: update minTemp (JGE skips) and maxTemp (JLE skips) with @@ labels (7 lines) <<<
    cmp  eax, [esi].STATS.minTemp
    jge  @F
    mov  [esi].STATS.minTemp, eax
@@: cmp  eax, [esi].STATS.maxTemp
    jle  @F
    mov  [esi].STATS.maxTemp, eax
@@:
su_done:
    ret
Stats_Update ENDP

END
