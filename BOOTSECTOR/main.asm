mov si, STR ;move string to register
call print
[org 0x7c00] ;load this code at boot sector

;BOOT
jmp $

print:
 pusha ;push everything to the stack
 STRloop:
   mov al, [si] ;move the memory address, first character into register H, of hellow
   cmp al, 0 ; is al 0?
   jne print_char ;if its not, skip if equal to each other by pop stack, then ret
   popa ; pop everything from stack 
   ret ;return back to print function
 print_char:
   mov ah, 0x0e
   int 0x10 ;bios interrupt 
   add si, 1 ; look at the next character, move memory location e != 0
   jmp STRloop

STR: db "Hello world", 0 ;end of our string when 0


;loaded into memory at 0x7c00 boot sector
;need to specify where to jump from
times 510-($-$$) db 0
dw 0xaa55
