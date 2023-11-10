org 0x7c00 ; Set the origin to 0x7C00

mov ax, 0x07c0  ; Set up the segments
mov ds, ax
mov es, ax

mov dh, 0x00    ; Drive number
mov dl, 0x80    ; First sector number
mov ch, 0x00    ; Cylinder number
mov cl, 0x02    ; Sector number
mov ah, 0x02    ; Read sector function
mov bx, 0x8000  ; Load the bootloader at 0x8000
mov al, 0x01    ; Number of sectors to read
int 0x13        ; BIOS interrupt

jmp 0x8000      ; Jump to the loaded bootloader