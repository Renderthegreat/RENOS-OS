section .data

section .text
    global _start

_start:
    mov ah, 0x0e  ; Function number for teletype output
    mov al, 'X'   ; ASCII code for 'X'
    int 0x10      ; Call BIOS interrupt

    ; Infinite loop to prevent the program from exiting
    jmp _start