;Credits MIKEOS http://http://mikeos.berlios.de
BITS 16
start:
	cli				; Clear interrupts
	mov ax, 0
	mov ss, ax			; Set stack segment and pointer
	mov sp, 0FFFFh
	sti				; Restore interrupts

	cld				; The default direction for string operations
					; will be 'up' - incrementing address in RAM

	mov ax, 2000h			; Set all segments to match where kernel is loaded
	mov ds, ax			; After this, we don't need to bother with
	mov es, ax			; segments ever again, as MikeOS and its programs
	mov fs, ax			; live entirely in 64K
	mov gs, ax

	call draw_background		;set up screen

	mov bl, 00001111b			; White block to draw keyboard on
	mov dh, 4
	mov dl, 5
	mov si, 69
	mov di, 21
	call os_draw_block

	mov bl, 11110000b			; White keys for keyboard
	mov dl, 23
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	add dl, 5
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	add dl, 5
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	add dl, 5
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	add dl, 5
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	add dl, 5
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	add dl, 5
	mov dh, 6
	mov si, 4
	mov di, 18
	call os_draw_block

	; And now for the black keys...

	mov bl, 00001111b

	mov dh, 6
	mov dl, 26
	mov si, 3
	mov di, 13
	call os_draw_block
	
	mov dh, 6
	mov dl, 31
	mov si, 3
	mov di, 13
	call os_draw_block
	
	mov dh, 6
	mov dl, 41
	mov si, 3
	mov di, 13
	call os_draw_block
	
	mov dh, 6
	mov dl, 46
	mov si, 3
	mov di, 13
	call os_draw_block
	
	mov dh, 6
	mov dl, 51
	mov si, 3
	mov di, 13
	call os_draw_block

	; And lastly, draw the labels on the keys indicating which
	; (computer!) keys to press to get notes

	mov bl, 11110000b
	mov ah, 0Eh

	mov dh, 17
	mov dl, 25
	call os_move_cursor

	mov al, 'Z'
	int 10h

	add dl, 4
	call os_move_cursor
	mov al, 'X'
	int 10h

	add dl, 5
	call os_move_cursor
	mov al, 'C'
	int 10h

	add dl, 5
	call os_move_cursor
	mov al, 'V'
	int 10h

	add dl, 5
	call os_move_cursor
	mov al, 'B'
	int 10h

	add dl, 5
	call os_move_cursor
	mov al, 'N'
	int 10h

	add dl, 5
	call os_move_cursor
	mov al, 'M'
	int 10h

	call os_hide_cursor

	
here:

	call os_wait_for_key

	cmp al, 'z'
	jne .x
	mov ax, 4000
	mov bx, 0
	call os_speaker_tone
	jmp here

.x:
	cmp al, 'x'
	jne .c
	mov ax, 3600
	mov bx, 0
	call os_speaker_tone
	jmp here

.c:
	cmp al, 'c'
	jne .v
	mov ax, 3200
	mov bx, 0
	call os_speaker_tone
	jmp here


.v:
	cmp al, 'v'
	jne .b
	mov ax, 3000
	mov bx, 0
	call os_speaker_tone
	jmp here

.b:
	cmp al, 'b'
	jne .n
	mov ax, 2700
	mov bx, 0
	call os_speaker_tone
	jmp here

.n:
	cmp al, 'n'
	jne .m
	mov ax, 2400
	mov bx, 0
	call os_speaker_tone
	jmp here

.m:
	cmp al, 'm'
	jne .comma
	mov ax, 2100
	mov bx, 0
	call os_speaker_tone
	jmp here

.comma:
	cmp al, ','
	jne .space
	mov ax, 2000
	mov bx, 0
	call os_speaker_tone
	jmp here

.space:
	cmp al, ' '
	jne .q
	call os_speaker_off
	jmp here

.q:
	cmp al, 'q'
	je .end
	cmp al, 'Q'
	je .end
	jmp here

.end:
	call os_speaker_off
	call os_clear_screen
	call os_show_cursor
	call reboot

	jmp here;

; ------------------------------------------------------------------
; ------------------------------------------------------------------
; os_wait_for_key -- Waits for keypress and returns key
; IN: Nothing; OUT: AX = key pressed, other regs preserved

os_wait_for_key:
	pusha

	mov ax, 0
	mov ah, 10h			; BIOS call to wait for key
	int 16h

	mov [tmp_buf], ax		; Store resulting keypress

	popa				; But restore all other regs
	mov ax, [tmp_buf]
	ret


	tmp_buf	dw 0


; ------------------------------------------------------------------
; draw_background - Uses os_draw_background to create a
; background
draw_background:
	mov ax, title_msg
	mov bx, footer_msg
	mov cx, 10011111b
	call os_draw_background
	ret

	title_msg		db 'Welcome to your New OS', 0
	footer_msg	db 'Press the Power Button on your system to shutdown', 0

; ------------------------------------------------------------------
;Reboot BIOS Call

reboot:
	mov ax, 0
	int 19h				; Reboot the system

; ==================================================================
; SCREEN HANDLING SYSTEM CALLS
; ==================================================================

; ------------------------------------------------------------------
; os_print_string -- Displays text
; IN: SI = message location (zero-terminated string)
; OUT: Nothing (registers preserved)

os_print_string:
	pusha

	mov ah, 0Eh			; int 10h teletype function

.repeat:
	lodsb				; Get char from string
	cmp al, 0
	je .done			; If char is zero, end of string

	int 10h				; Otherwise, print it
	jmp .repeat			; And move on to next char

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_clear_screen -- Clears the screen to background
; IN/OUT: Nothing (registers preserved)

os_clear_screen:
	pusha

	mov dx, 0			; Position cursor at top-left
	call os_move_cursor

	mov ah, 6			; Scroll full-screen
	mov al, 0			; Normal white on black
	mov bh, 7			;
	mov cx, 0			; Top-left
	mov dh, 24			; Bottom-right
	mov dl, 79
	int 10h

	popa
	ret


; ------------------------------------------------------------------
; os_move_cursor -- Moves cursor in text mode
; IN: DH, DL = row, column; OUT: Nothing (registers preserved)

os_move_cursor:
	pusha

	mov bh, 0
	mov ah, 2
	int 10h				; BIOS interrupt to move cursor

	popa
	ret


; ------------------------------------------------------------------
; os_get_cursor_pos -- Return position of text cursor
; OUT: DH, DL = row, column

os_get_cursor_pos:
	pusha

	mov bh, 0
	mov ah, 3
	int 10h				; BIOS interrupt to get cursor position

	mov [.tmp], dx
	popa
	mov dx, [.tmp]
	ret


	.tmp dw 0


; ------------------------------------------------------------------
; os_print_horiz_line -- Draw a horizontal line on the screen
; IN: AX = line type (1 for double (-), otherwise single (=))
; OUT: Nothing (registers preserved)

os_print_horiz_line:
	pusha

	mov cx, ax			; Store line type param
	mov al, 196			; Default is single-line code

	cmp cx, 1			; Was double-line specified in AX?
	jne .ready
	mov al, 205			; If so, here's the code

.ready:
	mov cx, 0			; Counter
	mov ah, 0Eh			; BIOS output char routine

.restart:
	int 10h
	inc cx
	cmp cx, 80			; Drawn 80 chars yet?
	je .done
	jmp .restart

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_show_cursor -- Turns on cursor in text mode
; IN/OUT: Nothing

os_show_cursor:
	pusha

	mov ch, 6
	mov cl, 7
	mov ah, 1
	mov al, 3
	int 10h

	popa
	ret


; ------------------------------------------------------------------
; os_hide_cursor -- Turns off cursor in text mode
; IN/OUT: Nothing

os_hide_cursor:
	pusha

	mov ch, 32
	mov ah, 1
	mov al, 3			; Must be video mode for buggy BIOSes!
	int 10h

	popa
	ret


; ------------------------------------------------------------------
; os_draw_block -- Render block of specified colour
; IN: BL/DL/DH/SI/DI = colour/start X pos/start Y pos/width/finish Y pos

os_draw_block:
	pusha

.more:
	call os_move_cursor		; Move to block starting position

	mov ah, 09h			; Draw colour section
	mov bh, 0
	mov cx, si
	mov al, ' '
	int 10h

	inc dh				; Get ready for next line

	mov ax, 0
	mov al, dh			; Get current Y position into DL
	cmp ax, di			; Reached finishing point (DI)?
	jne .more			; If not, keep drawing

	popa
	ret


; ------------------------------------------------------------------
; os_draw_background -- Clear screen with white top and bottom bars
; containing text, and a coloured middle section.
; IN: AX/BX = top/bottom string locations, CX = colour

os_draw_background:
	pusha

	push ax				; Store params to pop out later
	push bx
	push cx

	mov dl, 0
	mov dh, 0
	call os_move_cursor

	mov ah, 09h			; Draw white bar at top
	mov bh, 0
	mov cx, 80
	mov bl, 01110000b
	mov al, ' '
	int 10h

	mov dh, 1
	mov dl, 0
	call os_move_cursor

	mov ah, 09h			; Draw colour section
	mov cx, 1840
	pop bx				; Get colour param (originally in CX)
	mov bh, 0
	mov al, ' '
	int 10h

	mov dh, 24
	mov dl, 0
	call os_move_cursor

	mov ah, 09h			; Draw white bar at bottom
	mov bh, 0
	mov cx, 80
	mov bl, 01110000b
	mov al, ' '
	int 10h

	mov dh, 24
	mov dl, 1
	call os_move_cursor
	pop bx				; Get bottom string param
	mov si, bx
	call os_print_string

	mov dh, 0
	mov dl, 1
	call os_move_cursor
	pop ax				; Get top string param
	mov si, ax
	call os_print_string

	mov dh, 1			; Ready for app text
	mov dl, 0
	call os_move_cursor

	popa
	ret


; ------------------------------------------------------------------
; os_print_newline -- Reset cursor to start of next line
; IN/OUT: Nothing (registers preserved)

os_print_newline:
	pusha

	mov ah, 0Eh			; BIOS output char code

	mov al, 13
	int 10h
	mov al, 10
	int 10h

	popa
	ret


; ------------------------------------------------------------------
; os_dump_registers -- Displays register contents in hex on the screen
; IN/OUT: AX/BX/CX/DX = registers to show

os_dump_registers:
	pusha

	call os_print_newline

	push di
	push si
	push dx
	push cx
	push bx

	mov si, .ax_string
	call os_print_string
	call os_print_4hex

	pop ax
	mov si, .bx_string
	call os_print_string
	call os_print_4hex

	pop ax
	mov si, .cx_string
	call os_print_string
	call os_print_4hex

	pop ax
	mov si, .dx_string
	call os_print_string
	call os_print_4hex

	pop ax
	mov si, .si_string
	call os_print_string
	call os_print_4hex

	pop ax
	mov si, .di_string
	call os_print_string
	call os_print_4hex

	call os_print_newline

	popa
	ret


	.ax_string		db 'AX:', 0
	.bx_string		db ' BX:', 0
	.cx_string		db ' CX:', 0
	.dx_string		db ' DX:', 0
	.si_string		db ' SI:', 0
	.di_string		db ' DI:', 0


; ------------------------------------------------------------------
; os_input_dialog -- Get text string from user via a dialog box
; IN: AX = string location, BX = message to show; OUT: AX = string location

os_input_dialog:
	pusha

	push ax				; Save string location
	push bx				; Save message to show


	mov dh, 10			; First, draw red background box
	mov dl, 12

.redbox:				; Loop to draw all lines of box
	call os_move_cursor

	pusha
	mov ah, 09h
	mov bh, 0
	mov cx, 55
	mov bl, 01001111b		; White on red
	mov al, ' '
	int 10h
	popa

	inc dh
	cmp dh, 16
	je .boxdone
	jmp .redbox


.boxdone:
	mov dl, 14
	mov dh, 11
	call os_move_cursor


	pop bx				; Get message back and display it
	mov si, bx
	call os_print_string

	mov dl, 14
	mov dh, 13
	call os_move_cursor


	pop ax				; Get input string back
	call os_input_string

	popa
	ret


; ------------------------------------------------------------------
; os_dialog_box -- Print dialog box in middle of screen, with button(s)
; IN: AX, BX, CX = string locations (set registers to 0 for no display)
; IN: DX = 0 for single 'OK' dialog, 1 for two-button 'OK' and 'Cancel'
; OUT: If two-button mode, AX = 0 for OK and 1 for cancel
; NOTE: Each string is limited to 40 characters

os_dialog_box:
	pusha

	mov [.tmp], dx

	call os_hide_cursor

	mov dh, 9			; First, draw red background box
	mov dl, 19

.redbox:				; Loop to draw all lines of box
	call os_move_cursor

	pusha
	mov ah, 09h
	mov bh, 0
	mov cx, 42
	mov bl, 01001111b		; White on red
	mov al, ' '
	int 10h
	popa

	inc dh
	cmp dh, 16
	je .boxdone
	jmp .redbox


.boxdone:
	cmp ax, 0			; Skip string params if zero
	je .no_first_string
	mov dl, 20
	mov dh, 10
	call os_move_cursor

	mov si, ax			; First string
	call os_print_string

.no_first_string:
	cmp bx, 0
	je .no_second_string
	mov dl, 20
	mov dh, 11
	call os_move_cursor

	mov si, bx			; Second string
	call os_print_string

.no_second_string:
	cmp cx, 0
	je .no_third_string
	mov dl, 20
	mov dh, 12
	call os_move_cursor

	mov si, cx			; Third string
	call os_print_string

.no_third_string:
	mov dx, [.tmp]
	cmp dx, 0
	je .one_button
	cmp dx, 1
	je .two_button


.one_button:
	mov bl, 11110000b		; Black on white
	mov dh, 14
	mov dl, 35
	mov si, 8
	mov di, 15
	call os_draw_block

	mov dl, 38			; OK button, centred at bottom of box
	mov dh, 14
	call os_move_cursor
	mov si, .ok_button_string
	call os_print_string

	jmp .one_button_wait


.two_button:
	mov bl, 11110000b		; Black on white
	mov dh, 14
	mov dl, 27
	mov si, 8
	mov di, 15
	call os_draw_block

	mov dl, 30			; OK button
	mov dh, 14
	call os_move_cursor
	mov si, .ok_button_string
	call os_print_string

	mov dl, 44			; Cancel button
	mov dh, 14
	call os_move_cursor
	mov si, .cancel_button_string
	call os_print_string

	mov cx, 0			; Default button = 0
	jmp .two_button_wait



.one_button_wait:
	call os_wait_for_key
	cmp al, 13			; Wait for enter key (13) to be pressed
	jne .one_button_wait

	call os_show_cursor

	popa
	ret


.two_button_wait:
	call os_wait_for_key

	cmp ah, 75			; Left cursor key pressed?
	jne .noleft

	mov bl, 11110000b		; Black on white
	mov dh, 14
	mov dl, 27
	mov si, 8
	mov di, 15
	call os_draw_block

	mov dl, 30			; OK button
	mov dh, 14
	call os_move_cursor
	mov si, .ok_button_string
	call os_print_string

	mov bl, 01001111b		; White on red for cancel button
	mov dh, 14
	mov dl, 42
	mov si, 9
	mov di, 15
	call os_draw_block

	mov dl, 44			; Cancel button
	mov dh, 14
	call os_move_cursor
	mov si, .cancel_button_string
	call os_print_string

	mov cx, 0			; And update result we'll return
	jmp .two_button_wait


.noleft:
	cmp ah, 77			; Right cursor key pressed?
	jne .noright


	mov bl, 01001111b		; Black on white
	mov dh, 14
	mov dl, 27
	mov si, 8
	mov di, 15
	call os_draw_block

	mov dl, 30			; OK button
	mov dh, 14
	call os_move_cursor
	mov si, .ok_button_string
	call os_print_string

	mov bl, 11110000b		; White on red for cancel button
	mov dh, 14
	mov dl, 43
	mov si, 8
	mov di, 15
	call os_draw_block

	mov dl, 44			; Cancel button
	mov dh, 14
	call os_move_cursor
	mov si, .cancel_button_string
	call os_print_string

	mov cx, 1			; And update result we'll return
	jmp .two_button_wait


.noright:
	cmp al, 13			; Wait for enter key (13) to be pressed
	jne .two_button_wait

	call os_show_cursor

	mov [.tmp], cx			; Keep result after restoring all regs
	popa
	mov ax, [.tmp]

	ret


	.ok_button_string	db 'OK', 0
	.cancel_button_string	db 'Cancel', 0
	.ok_button_noselect	db '   OK   ', 0
	.cancel_button_noselect	db '   Cancel   ', 0

	.tmp dw 0


; ------------------------------------------------------------------
; os_print_space -- Print a space to the screen
; IN/OUT: Nothing

os_print_space:
	pusha

	mov ah, 0Eh			; BIOS teletype function
	mov al, 20h			; Space is character 20h
	int 10h

	popa
	ret


; ------------------------------------------------------------------
; os_dump_string -- Dump string as hex bytes and printable characters
; IN: SI = points to string to dump

os_dump_string:
	pusha

	mov bx, si			; Save for final print

.line:
	mov di, si			; Save current pointer
	mov cx, 0			; Byte counter

.more_hex:
	lodsb
	cmp al, 0
	je .chr_print

	call os_print_2hex
	call os_print_space		; Single space most bytes
	inc cx

	cmp cx, 8
	jne .q_next_line

	call os_print_space		; Double space centre of line
	jmp .more_hex

.q_next_line:
	cmp cx, 16
	jne .more_hex

.chr_print:
	call os_print_space
	mov ah, 0Eh			; BIOS teletype function
	mov al, '|'			; Break between hex and character
	int 10h
	call os_print_space

	mov si, di			; Go back to beginning of this line
	mov cx, 0

.more_chr:
	lodsb
	cmp al, 0
	je .done

	cmp al, ' '
	jae .tst_high

	jmp short .not_printable

.tst_high:
	cmp al, '~'
	jbe .output

.not_printable:
	mov al, '.'

.output:
	mov ah, 0Eh
	int 10h

	inc cx
	cmp cx, 16
	jl .more_chr

	call os_print_newline		; Go to next line
	jmp .line

.done:
	call os_print_newline		; Go to next line

	popa
	ret


; ------------------------------------------------------------------
; os_print_digit -- Displays contents of AX as a single digit
; Works up to base 37, ie digits 0-Z
; IN: AX = "digit" to format and print

os_print_digit:
	pusha

	cmp ax, 9			; There is a break in ASCII table between 9 and A
	jle .digit_format

	add ax, 'A'-'9'-1		; Correct for the skipped punctuation

.digit_format:
	add ax, '0'			; 0 will display as '0', etc.	

	mov ah, 0Eh			; May modify other registers
	int 10h

	popa
	ret


; ------------------------------------------------------------------
; os_print_1hex -- Displays low nibble of AL in hex format
; IN: AL = number to format and print

os_print_1hex:
	pusha

	and ax, 0Fh			; Mask off data to display
	call os_print_digit

	popa
	ret


; ------------------------------------------------------------------
; os_print_2hex -- Displays AL in hex format
; IN: AL = number to format and print

os_print_2hex:
	pusha

	push ax				; Output high nibble
	shr ax, 4
	call os_print_1hex

	pop ax				; Output low nibble
	call os_print_1hex

	popa
	ret


; ------------------------------------------------------------------
; os_print_4hex -- Displays AX in hex format
; IN: AX = number to format and print

os_print_4hex:
	pusha

	push ax				; Output high byte
	mov al, ah
	call os_print_2hex

	pop ax				; Output low byte
	call os_print_2hex

	popa
	ret


; ------------------------------------------------------------------
; os_input_string -- Take string from keyboard entry
; IN/OUT: AX = location of string, other regs preserved
; (Location will contain up to 255 characters, zero-terminated)

os_input_string:
	pusha

	mov di, ax			; DI is where we'll store input (buffer)
	mov cx, 0			; Character received counter for backspace


.more:					; Now onto string getting
	call os_wait_for_key

	cmp al, 13			; If Enter key pressed, finish
	je .done

	cmp al, 8			; Backspace pressed?
	je .backspace			; If not, skip following checks

	cmp al, ' '			; In ASCII range (32 - 126)?
	jb .more			; Ignore most non-printing characters

	cmp al, '~'
	ja .more

	jmp .nobackspace


.backspace:
	cmp cx, 0			; Backspace at start of string?
	je .more			; Ignore it if so

	call os_get_cursor_pos		; Backspace at start of screen line?
	cmp dl, 0
	je .backspace_linestart

	pusha
	mov ah, 0Eh			; If not, write space and move cursor back
	mov al, 8
	int 10h				; Backspace twice, to clear space
	mov al, 32
	int 10h
	mov al, 8
	int 10h
	popa

	dec di				; Character position will be overwritten by new
					; character or terminator at end

	dec cx				; Step back counter

	jmp .more


.backspace_linestart:
	dec dh				; Jump back to end of previous line
	mov dl, 79
	call os_move_cursor

	mov al, ' '			; Print space there
	mov ah, 0Eh
	int 10h

	mov dl, 79			; And jump back before the space
	call os_move_cursor

	dec di				; Step back position in string
	dec cx				; Step back counter

	jmp .more


.nobackspace:
	pusha
	mov ah, 0Eh			; Output entered, printable character
	int 10h
	popa

	stosb				; Store character in designated buffer
	inc cx				; Characters processed += 1
	cmp cx, 254			; Make sure we don't exhaust buffer
	jae near .done

	jmp near .more			; Still room for more


.done:
	mov ax, 0
	stosb

	popa
	ret


; ==================================================================


; ==================================================================
; PC SPEAKER SOUND ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; os_speaker_tone -- Generate PC speaker tone (call os_speaker_off to turn off)
; IN: AX = note frequency; OUT: Nothing (registers preserved)

os_speaker_tone:
	pusha

	mov cx, ax			; Store note value for now

	mov al, 182
	out 43h, al
	mov ax, cx			; Set up frequency
	out 42h, al
	mov al, ah
	out 42h, al

	in al, 61h			; Switch PC speaker on
	or al, 03h
	out 61h, al

	popa
	ret


; ------------------------------------------------------------------
; os_speaker_off -- Turn off PC speaker
; IN/OUT: Nothing (registers preserved)

os_speaker_off:
	pusha

	in al, 61h
	and al, 0FCh
	out 61h, al

	popa
	ret


; ==================================================================; ==================================================================
; END OF KERNEL
; ==================================================================
