; =============================================================================
; JZNOS System Calls - Keyboard - Version 1.0
; x86 ASM
; =============================================================================

; =============================================================================
; Subroutine: os_wait_for_key
; In:           Null
; Out:    AX    Key code pressed
; Effect:       Waits until a key is pressed and stores the keycode
; =============================================================================
os_wait_for_key:
    pusha

	mov                ax,             0
	mov                ah,             10h     ; BIOS call
	int                16h

	mov                [.os_wait_for_key_tmp_buf],     ax

	popa
	mov                ax,             [.os_wait_for_key_tmp_buf]
	ret

    .os_wait_for_key_tmp_buf	dw 0
