; =============================================================================
; JZNOS Kernel - Version 1.0
; x86 ASM
; =============================================================================
   BITS 16

   %DEFINE JZNOS_VER '1.0'
   %DEFINE JZNOS_APT_VER 16

os_call_vectors:
    jmp os_main             ;0000h
    jmp os_print_string     ;0003h

os_main:
    cli
    mov ax, 0
    mov ss, ax
    mov sp, 0FFFFh
    sti

    mov si, kernel_message
    call os_print_string
    jmp $

; =============================================================================
; Data definitions:

    kernel_message db "Hello, world!",0

    %INCLUDE "lib/graphic.asm"

; -----------------------------------------------------------------------------
; ------------------------------END OF KERNEL----------------------------------
; -----------------------------------------------------------------------------
