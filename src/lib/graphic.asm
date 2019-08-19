; =============================================================================
; JZNOS System Calls - Graphic - Version 1.0
; x86 ASM
; =============================================================================

; =============================================================================
; Subroutine: os_print_string
; In:           Null terminated string to print
; Out:    null  null
; Effect:       Prints the string provided
; =============================================================================
os_print_string:
    pusha
    mov             ah,             0Eh
; -----------------------------------------------------------------------------
.os_print_string_repeat:
	lodsb                                  ; Get char from string
	cmp            al,             0
	je             .os_print_string_done   ; if char = 0 then jump to .done
	int            10h                     ; else print character to screen
	jmp            .os_print_string_repeat
; -----------------------------------------------------------------------------
.os_print_string_done:
	ret

; =============================================================================
; Subroutine: os_move_cursor
; In:     dh    row number
;         dl    col number
; Out:    null  null
; Effect:       Move cursor to row, col
; =============================================================================
os_move_cursor:
    pusha

    mov             bh,             0
    mov             ah,             3
    int             10h

    mov             [.os_move_cursor_tmp], dx
    popa
    mov             dx, [.os_move_cursor_tmp]
    ret

    .os_move_cursor_tmp dw 0
