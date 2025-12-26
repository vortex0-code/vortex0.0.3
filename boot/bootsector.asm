;
; boot/bootsector.asm
;
; 
; Copyright (C) 2025 Ілля
; завантажувальний сектор ядра vortex
; налаштування регістрів сегментів
; для роботи з відео памятю ram disk
; після bootsector
;
; 16 bit real mode обмежується адресацією в 1 мб
; али цього хватить для встановлення базового стеку
; і сегментів і регістрів цього достатньо щоб базова
; система стартувала до 32 bit mode 
;
;  код обмежується 512 байт али цього достатньо 
; для старту ядра али неможливо перевірити апаратне
; забезпечення це робиться в 2-3 етапі 
; 
;
; при редакції цього bootsector.asm 
; будьте обережні з кодом щоб не зламати систему 
; kernel vortex 
; основна документація тут!!! vortex0.1/Documentation/boot
;  документація поможе вам лутше працювати з bootsector.asm
; інші посібники які вам поможуть працювати з bootsector
; vortex0.1/Documentation/boot/cpu
; vortex0.1/Documentation/boot/mode16щ

bits 16
org 0x7C00 

start:
   cli
   xor al, al ; al = 0
   xor bh, bh ; bh = 0
   xor di, di ; di = 0
   xor si, si ; si = 0
   
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax ; ss = 0
   mov sp, 0x7C00 ;  стек біля boot sector
   sti 
   
disk:
  ; читання секторів ядра
   mov ah, 0x02 ; read bios
   mov al, 0x05 ; 5 sectors 
   mov ch, 0x00 
   mov cl, 0x02 ; другий після 1 boot
   mov dh, 0x00 
   mov dl, 0x80 ; disk (C)
   mov bx, 0x1000
   mov ax, 0x0000
   mov es, ax
   int 0x13 ; read
   jc disk_errors ; bit 1 error
   
   mov si, msg ; рядок тексту для виводу
   ; контролюєм cx рядок символів щоб не виводити
   ; артефакти 
   mov cx, 7 ; msg = символів = 7
   jmp loading
   
loading:
   xor al, al ; al = 0
   cld ; DF 0
   lodsb  ; ds/si = al
   cmp al, 0 ; кінець рядка?
   je dong
   mov ah, 0x0E ; bios text mode 
   int 0x10 ; video mode bios
   ; loop використовує cx si ds перед друкуваням тексту
   ; ми встановлюємо ці залежності для виводу тексту
   loop loading 

dong:
   xor al, al    
   ; фізична адреса ядра 0x1000
   jmp 0x1000:0x0000

disk_errors:
   ; пробуємо заново прочитати сектори
   xor al, al ; al = sector 0 следующий сектор 2 cl = 2
   jmp disk ; reset disk read
    
msg db "loading" , 0

times 510 - ($-$$) db 0 ; заповнення сектори до 512 байт
dw 0xAA55  ; сигнатура для boot sector
   
   
