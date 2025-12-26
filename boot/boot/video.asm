;
; boot/video.asm
;
;
; Copyright (C) 2025 Ілля
;
; налаштування адаптерів відео карти
; тут ми налаштовуємо відео память так щоб
; відео пам'ять могла коректно функціювати 
; коли ядро буде використовувати vga
; тому ми максимально адаптуємо vga
; скоро інші адаптери vga
;
; stosw хороший варіант перевіряти відео память
; али в драйверах vortex kernel частково не буде stosw 
;
;
;

bits 16

video_start:
    xor ah, ah
    xor al, al
    xor ax, ax
    xor si, si
    xor bh ,bh ; нульова сторінка яку очікує bios
    xor cx, cx
    call clear_video
        
    ; cursor 80*25 = початок di 0
cursor_setur:   
    ; курсор
    xor di, di
    mov di, 0  ; cursor 
    xor al, al ; 0
    mov si, video_mt
    mov cx, 14
    call video_text
    
    jmp load_setur
 
clear_video:
    ; очищення екрану 80*25
    mov ax, 0xb800
    mov es, ax
    mov al, 0x20 ; пробіл
    xor di, di
    mov ah, 0x0F ; колір/атрибут
    mov bh, 0x00 ; 0
    mov cx, 2000 ; 80*25 = 2000 символів
loop_st:
   stosw ; video memory
   loop loop_st
   ret
   
video_text:
    cld ; df 0 в рухаємся в перед
    lodsb 
    cmp al, 0
    je load_setur
    mov ah, 0x0E
    int 0x10 
    mov bh, 0x00    
    loop video_text
    ret
     
load_setur:
   call clear_video
   
   jmp $
      
video_mt db "video setur ok" , 0
times 426 db 0
