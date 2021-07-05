[org 0x7c00]
;buffer es -> 0xx4f3e



;mov si, STR ;move string to register
;call print
mov al, 1 ;here
mov cl, 2 ; and here
;literally the same, but can make changes before read
call readDisk
jmp test ; test second sector
;sector doesnt exist for qemu - fixed second sector
mov si, STR_TEST
call print
 
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

readDisk:
 pusha
 mov ah, 0x02
 mov dl, 0X80 ;0  or 0X80 hard disk is 80 (not flash drive emulated floppy)
 mov ch, 0 ;cylinder 0 of drive
 mov dh, 0 ;head 0
;not reading sectors commented out
 ;mov al, 1 ;start at first sector BOOTSECTOR sectors want to read
 ;mov cl, 2 ;read second sector

 ;where do we want this disk info in memory?
 ;loaded at 0x7c00 atm 
 ;need to load in meory 512 bytes after
 ; segment register to 0 , no offsets 
 ; bx register where we at

 push bx
 mov bx, 0 ;will only jmp to sector 2, if set to 0 (where there is nothing)
 mov es, bx ; because the hard disk hasnt read that 
 pop bx
 mov bx, 0x7c00 + 512 ;next location of memory

 int 0x13
 ;has carry flag been flipped?
 jc disk_err
 popa ;no errors
 ret

;if disk error
disk_err:
 mov si, DISK_ERR_MSG
 call print
 jmp $ 
 
;INT 13h AH=2h: READ SECTORS FROM DRIVE
;AH 02H
;AL SECTORS TO READ COUNT
;CH CYLINDER
;CL SECTOR
;DH HEAD
;DL DRIVE
;ES:BX BUFFER ADDRESS POINTER


;Debugging
;cf set on error, clear if no error
;ah return code
;al actual sectors read count

;STR: db "LOADED INTO 16-BIT REAL MODE TO MEMORY LOCATION", 0, 10 ;end of our string when 0
STR_TEST: db 'Loaded disk, second sector. Test boot complete..',0x0a, 0x0d, 0
DISK_ERR_MSG: db 'Error loading Disk', 0x0a, 0x0d, 0

;loaded into memory at 0x7c00 boot sector
;need to specify where to jump from
times 510-($-$$) db 0
dw 0xaa55
;move this label, sectors later
test:
;jmp to this part of memory
mov si, STR_TEST
call print

times 512 db 0 ; second sector
