; =============================================================================
; JZNOS Bootloader - Version 1.0
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
    mov ah, 0Eh
; -----------------------------------------------------------------------------
.repeat:
	lodsb                               ; Get char from string
	cmp al, 0
	je .done                            ; if char = 0 then jump to .done
	int 10h                             ; else print character to screen
	jmp .repeat
; -----------------------------------------------------------------------------
.done:
	ret
