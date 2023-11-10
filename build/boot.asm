section .text
    global _start

_start:
    ; Set up registers for BIOS interrupt
    mov ah, 0x0E        ; BIOS interrupt: teletype output

    ; Print 'R'
    mov al, 'R'
    int 0x10

    ; Print 'E'
    mov al, 'E'
    int 0x10

    ; Print 'N'
    mov al, 'N'
    int 0x10

    ; Print 'O'
    mov al, 'O'
    int 0x10

    ; Print 'S'
    mov al, 'S'
    int 0x10

    ; Move cursor to the beginning of the next line
    mov ah, 0x0A
    int 0x10

    ; Infinite loop to prevent the program from exiting
    jmp $

    ; Padding to reach the boot sector size of 512 bytes
    times 510 - ($ - $$) db 0
    dw 0xAA55           ; Boot signature
