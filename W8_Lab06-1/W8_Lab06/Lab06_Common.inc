; =============================================================================
;  Lab06_Common.inc - shared contracts for the Telemetry Library
;  Included by BOTH Lab06_TelemetryLib.asm and Lab06_Main.asm.
;  One file, one truth: if the STRUCT or a PROTO changes, both modules see it.
; =============================================================================
IFNDEF LAB06_COMMON_INC
LAB06_COMMON_INC EQU 1

NUM_PACKETS  EQU 8
PACKET_SIZE  EQU 8
SYNC_BYTE    EQU 0A5h

; ---- one record of statistics --------------------------------------------
STATS STRUCT
    validCount  DWORD  ?          ; offset 0
    sumTemp     SDWORD ?          ; offset 4
    minTemp     SDWORD ?          ; offset 8
    maxTemp     SDWORD ?          ; offset 12
STATS ENDS

; ---- procedure contracts (stdcall) ----------------------------------------
Pkt_IsValid   PROTO pPkt:PTR BYTE                 ; EAX = 1 valid / 0 invalid
Pkt_GetTemp   PROTO pPkt:PTR BYTE                 ; EAX = signed temp, tenths
Stats_Reset   PROTO pStats:PTR STATS              ; zero the record, set min/max
Stats_Update  PROTO pStats:PTR STATS, pPkt:PTR BYTE   ; fold one packet in

ENDIF
