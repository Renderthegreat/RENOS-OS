org 0x7c00      ; Set the origin to 0x7C00

bits 16         ; Set 16-bit mode

start:
    mov ax, 0x0000  ; Set up the segments
    mov ds, ax
    mov es, ax

    mov bx, 0x7c00  ; Set the stack
    mov ss, bx
    mov sp, 0x1000

    mov bx, buffer  ; Load the file to memory
    mov dh, 0x02    ; Drive number
    mov dl, 0x00    ; First sector number
    mov ch, 0x00    ; Cylinder number
    mov cl, 0x02    ; Sector number
    mov ah, 0x02    ; Read sector function
    int 0x13        ; BIOS interrupt

    jmp buffer:0x0000  ; Jump to the loaded code

buffer:
    times 0x7c00-($-$$) db 0  ; Fill up to 0x7C00 with zeros
    main_bin:
              db 0b01010110  ; Binary content of main.bin
              db 0b10101100
              db 0b11110000
              ; Add more binary data as needed


dw 0xAA55                ; Boot signature