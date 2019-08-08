; =============================================================================
; JZNOS Bootloader - Version 1.0
; x86 ASM
; 512 bytes (1 cluster/1 sector)
; =============================================================================
	BITS 16
	jmp 			short 		start		; Jump to start of os, past disk description
	nop										; Pad out before description
; =============================================================================
; Disk description:
  OEMLabel			db			"JZNOSBOOT"	; Disk label
  BytesPerSector	dw			512			; Bytes per sector
  SectorsPerCluster	db			1			; Sectors per cluster
  ReservedForBoot	dw			1			; Reserved sectors for boot record
  NumberOfFats		db			2			; Number of copies of the FAT
  RootDirEntries	dw			224			; Number of entries in root dir
  LogicalSectors	dw			2880		; Number of logical sectors
  MediumByte		db			0F0h		; Medium descriptor byte
  SectorsPerFat		dw			9			; Sectors per FAT
  SectorsPerTrack	dw			18			; Sectors per track (36/cylinder)
  Sides				dw			2			; Number of sides/heads
  HiddenSectors		dd			0			; Number of hidden sectors
  LargeSectors		dd			0			; Number of LBA sectors
  DriveNo			dw			0			; Drive No: 0
  Signature			db			41			; Drive signature: 41 for floppy
  VolumeID			dd			00000000h	; Volume ID: any number
  VolumeLabel		db			"JZNOS      "  ; Volume Label must be 11 char
  FileSystem		db			"FAT12   "     ; File system type
; =============================================================================
; Main program flow:
start:
	mov				ax, 		07C0h		; 4k stack space after bootloader
	add 			ax, 		544
	cli
	mov 			ss, 		ax
	mov 			sp, 		4096
	sti

	cmp 			dl, 		0
	je 				no_change
	mov 			[bootdev], 	dl
	mov 			ah, 		8
	int 			13h
	jc 				fatal_disk_error
	and 			cx, 		3Fh
	mov 			[SectorsPerTrack], cx
	movzx 			dx, 		dh
	add 			dx, 		1
	mov 			[Sides], 	dx

no_change:
	mov 			eax, 		0

disk_ok:
	mov 			ax, 		19
	call 			l2hts

	mov 			si, 		buffer
	mov 			bx, 		ds
	mov 			es, 		bx
	mov 			bx, 		si

	mov 			ah, 		2
	mov 			al, 		14

	pusha

read_root_dir:
	popa
	pusha

	stc
	int 			13h

	jnc 			search_dir
	call 			reset_floppy
	jnc 			read_root_dir

	jmp 			reboot

search_dir:
	popa

	mov 			ax, 		ds
	mov 			es, 		ax
	mov 			di, 		buffer

	mov 			cx, 		word [RootDirEntries]
	mov 			ax, 		0

next_root_entry:
	xchg 			cx, 		dx

	mov 			si, 		kern_filename
	mov 			cx, 		11
	rep 			cmpsb
	je 				found_file_to_load

	add 			ax, 		32

	mov 			di, 		buffer
	add 			di, 		ax

	xchg 			dx, 		cx
	loop 			next_root_entry

	mov 			si, 		file_not_found
	call			print_string
	jmp 			reboot

found_file_to_load:
	mov 			ax, 		word [es:di+0Fh]
	mov 			word [cluster], ax

	mov 			ax, 		1
	call 			l2hts

	mov 			di, 		buffer
	mov 			bx, 		di

	mov 			ah, 		2
	mov 			al, 		9

	pusha

read_fat:
	popa
	pusha

	stc
	int 			13h

	jnc 			read_fat_ok
	call 			reset_floppy
	jnc 			read_fat

fatal_disk_error:
	mov 			si, 		disk_error
	call 			print_string
	jmp 			reboot

read_fat_ok:
	popa

	mov 			ax, 		2000h
	mov 			es, 		ax
	mov 			bx, 		0

	mov 			ah, 		2
	mov 			al, 		1

	push 			ax

load_file_sector:
	mov 			ax, 		word [cluster]
	add 			ax, 		31

	call 			l2hts

	mov 			ax, 		2000h
	mov 			es, 		ax
	mov 			bx, 		word [pointer]

	pop 			ax
	push 			ax

	stc
	int 			13h

	jnc 			calculate_next_cluster

	call 			reset_floppy
	jmp 			load_file_sector


calculate_next_cluster:
	mov 			ax, 		[cluster]
	mov 			dx, 		0
	mov 			bx, 		3
	mul 			bx
	mov 			bx, 		2
	div 			bx
	mov 			si, 		buffer
	add 			si, 		ax
	mov 			ax, 		word [ds:si]

	or 				dx, 		dx

	jz 				even


odd:
	shr 			ax, 		4
	jmp 			short 		next_cluster_cont


even:
	and 			ax, 		0FFFh


next_cluster_cont:
	mov 			word [cluster], ax

	cmp 			ax, 		0FF8h
	jae 			end

	add 			word [pointer], 512
	jmp 			load_file_sector


end:
	pop 			ax
	mov 			dl, 		byte [bootdev]

	jmp 			2000h:0000h

; =============================================================================
; Subroutine: reboot
; In:     null  null
; Out:    null  null
; Effect:       Reboots the system
; =============================================================================

roboot:
	mov 			ax, 		0
	int 			16h
	mov 			ax,			0
	int 			19h

; =============================================================================
; Subroutine: print_string
; In:     SI    Null terminated string to print
; Out:    null  null
; Effect:       Prints the string provided in SI
; =============================================================================
print_string:
    pusha
    mov 			ah, 		0Eh
.repeat:
	lodsb									; Get char from string
	cmp 			al, 		0
	je 				.done					; if char = 0 then jump to .done
	int 			10h						; else print character to screen
	jmp 			.repeat
.done:
	ret

reset_floppy:
	push 			ax
	push 			dx
	mov 			ax, 		0
	mov 			dl, 		byte [bootdev]
	stc
	int 			13h
	pop 			dx
	pop 			ax
	ret


l2hts:
	push 			bx
	push 			ax

	mov 			bx, 		ax

	mov 			dx, 		0
	div 			word [SectorsPerTrack]
	add 			dl, 		01h
	mov 			cl, 		dl
	mov 			ax, 		bx

	mov 			dx, 		0
	div 			word [SectorsPerTrack]
	mov 			dx, 		0
	div 			word [Sides]
	mov 			dh, 		dl
	mov 			ch, 		al

	pop 			ax
	pop 			bx

	mov 			dl, 		byte [bootdev]

	ret

; =============================================================================
; Data definitions:
	kern_filename	db 'KERNEL BIN'

	disk_error 		db 'ERROR 1: Fatal disk error', 0
	file_not_found 	db 'ERROR 2: File not found', 0

	times 510-($-$$) db 0					;pad remainder of boot sector with 0s
	dw 0AA55h								;The standard pc boot signature

buffer:
; -----------------------------------------------------------------------------
; ----------------------------END OF BOOTLOADER--------------------------------
; -----------------------------------------------------------------------------
