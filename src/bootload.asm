; =============================================================================
; JZNOS Bootloader - Version 1.0
; x86 ASM
; 512 bytes (1 cluster/1 sector)
; =============================================================================
	BITS 16
	jmp short start 			              ; Jump to start of os, past disk description
	nop                                 ; Pad out before description
; =============================================================================
; Disk description:
  OEMLabel		      db "JZNOSBOOT"    ; Disk label
  BytesPerSector		dw 512		        ; Bytes per sector
  SectorsPerCluster	db 1		          ; Sectors per cluster
  ReservedForBoot		dw 1		          ; Reserved sectors for boot record
  NumberOfFats		  db 2		          ; Number of copies of the FAT
  RootDirEntries	  dw 224		        ; Number of entries in root dir
  LogicalSectors	  dw 2880		        ; Number of logical sectors
  MediumByte		    db 0F0h			      ; Medium descriptor byte
  SectorsPerFat		  dw 9		          ; Sectors per FAT
  SectorsPerTrack	  dw 18		          ; Sectors per track (36/cylinder)
  Sides			        dw 2			        ; Number of sides/heads
  HiddenSectors	    dd 0		          ; Number of hidden sectors
  LargeSectors	    dd 0		          ; Number of LBA sectors
  DriveNo			      dw 0			        ; Drive No: 0
  Signature		      db 41			        ; Drive signature: 41 for floppy
  VolumeID		      dd 00000000h	    ; Volume ID: any number
  VolumeLabel		    db "JESUSOS    "  ; Volume Label must be 11 char
  FileSystem		    db "FAT12   "     ; File system type
; =============================================================================

os_call_vectors:
	jmp start			; 0000h
	jmp os_print_string	; 0003h

; Main program flow:
start:
	mov ax, 07C0h                       ; 4k stack space after bootloader
	add ax, 288                         ; 4096 + 512 devided by 16 bytes per paragraph
	cli
	mov ss, ax
	mov sp, 4096
	sti
	mov ax, 07C0h                       ; Set data segment to where we are loaded
	mov ds, ax
	mov si, text_string                 ; SI <-- null terminated string to print
	call os_print_string
	jmp $                               ; Infinite loop to keep text on screen
; =============================================================================

; Include:
	%INCLUDE "lib/graphic.asm"

; Data definitions:
	text_string db 'Welcome to JZNOS Bootloader 1.0', 0
	times 510-($-$$) db 0               ;pad remainder of boot sector with 0s
	dw 0AA55h                           ;The standard pc boot signature
; -----------------------------------------------------------------------------
; ----------------------------END OF BOOTLOADER--------------------------------
; -----------------------------------------------------------------------------
