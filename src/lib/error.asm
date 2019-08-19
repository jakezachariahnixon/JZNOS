; =============================================================================
; JZNOS System Calls - Error - Version 1.0
; x86 ASM
; =============================================================================

; =============================================================================
; Subroutine: os_fatal_error
; In:     null  null
; Out:    null  null
; Effect:       Throws a fatal OS error
; =============================================================================
os_fatal_error:
    mov         bx,         ax
    mov         dh,         0
    mov         dl,         0
    call        os_move_cursor

    pusha
    mov         ah,         09h
    mov         bh,         0
    mov         cx,         240
    mov         bl,         01001111b
    mov         al,         ' '
    int         10h
    popa

    mov         dh,         0
    mov         dl,         0
    call        os_move_cursor

    mov         si,         .os_fatal_error_message
    call        os_print_string

    mov         si,         bx
    call        os_print_string

    jmp $

    .os_fatal_error_message db  "---FATAL OS ERROR---", 13, 10, 0
