; =============================================================================
; JZNOS System Calls - Time - Version 1.0
; x86 ASM
; =============================================================================

; =============================================================================
; Subroutine: os_pause
; In:     AX    Number of multiples of 100 milliseconds to wait
; Out:    null  null
; Effect:       Wait for the speecified number of milliseconds
; =============================================================================
os_pause:
    pusha
    cmp         ax,         0
    je          .os_pause_time_up

    mov         cx,         0
    mov         [.os_pause_counter_var], cx
    mov         bx,         ax
    mov         ax,         0
    mov         al,         2
    mul         bx
    mov         [.os_pause_orig_req_delay], ax

    mov         ah,         0
    int         1Ah

    mov         [.os_pause_prev_tick_count], dx

.os_pause_checkloop:
    mov ah,     0
    int         1Ah
    cmp [.os_pause_prev_tick_count], dx
    jne         .os_pause_update
    jmp         .os_pause_checkloop

.os_pause_time_up:
    popa
    ret

.os_pause_update:
    mov         ax,         [.os_pause_counter_var]
    inc         ax
    mov         [.os_pause_counter_var], ax
    cmp         ax,         [.os_pause_orig_req_delay]
    jge         .os_pause_time_up
    mov         [.os_pause_prev_tick_count], dx
    jmp         os_pause_checkloop

    .os_pause_orig_req_delay    dw 0
    .os_pause_counter_var       dw 0
    .os_pause_prev_tick_count   dw 0
