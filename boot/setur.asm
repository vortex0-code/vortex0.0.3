;
; boot/setur.asm
;
;
; Copyright (C) 2025 Ілля

; другий етап 
; тепер ми не обмежуємося 510 - 512 байтами 
; тепер можна перевірити апаратне забезпечення 
;
; код обробляє апаратне забезпечення 
; video ram disk vga 
;
; посібники для роботи з setur.asm
; vortex0.1/Documentation/boot/api/
; vortex0.1/Documentation/boot/mode16

; в коді перевіряється int 0x12 це старий варіант перевірки 
; нижньої оперативної пам'яті 640кб
; це варіант зара майже не актуальний для ядер і деяких
; bios 
; али цей код буде містити перевірку нижньої оперативної пам'яті 
; 
; зауваження! 
; цей варіант скоро буде видалено із ядра vortex

; посібники для роботи з int 0x12 
; vortex0.1/Documentation/boot/mm/

; в коді перевіряється vga адаптер
; в 16 біт ми обмежені самою адресацією
; тому ми використовуєм 0xb800 32 bit = 0xb8000

; базове налаштування для роботи з апаратним забезпеченням
; було зроблено в файлі bootsector.asm
; 
; тому ми можемо повноціно без зайвих налаштувань
; регістрів і стеком
; 

bits 16 
org 0x1000 ; cs після boot jmp 0x1000 ip після boot 0x0000

setur_main:
   mov ax, cs ; jmp cs
   mov ds, ax 
   
   ; зануляєм es 
   mov ax, 0x0000
   mov es, ax 
   
   mov ss, ax
   mov sp, 0x9FFF ; стек ставим високо щоб не перезаписати 
   ; компоненти ядра
   
ram_init:
  ; перевірка і оброблення нижньої оперативної пам'яті 
   int 0x12   
   
   xor cx, cx ; cx = 0
   xor al, al ; al = 0
   
   ; перевірка результату int 0x12 в ax
   mov cx, 640 
   cmp ax, cx ; cx = ax ?
   je ram_no ; no 
   
   
disk_of_format:
   mov ah, 0x00 ; FDC reset   
   int 0x13 
   
video_init:
   ; перевірка vga адаптера 
   ; на екрані може не показуватись символ B
   ; по мітка kernel_start йього перезаписує скоро 
   ; я це виправлю
   xor ax, ax
   xor al, al
   xor di, di
   cld ; DF = 0 тому ми рухаємо в перед (100-101) рядкок
   ; перевірка vga через простий запис у відео память
   mov ax, 0xb800 ; video mode 
   mov al, 'B'
   xor di, di ; початок курсора
   mov ah, 0x0F ; атрибут
   mov bh, 0x00 ; біос очікує відео сторінку 0
   ; тому ви ставим 0 щоб не було помилок
   ; в виводі символів
   stosw ; записуємо напряму в відео память 
   ; перевірка чи існує vga адаптер відсутня 
   ; тому ми не робимо інших переходів 
   ; перевірити чи є vga адаптер просто 
   ; глянути на монітор чи є символ 
   ; stosw нам не каже чи сталась помилка 
   ; тому ми не робим перевірку чи успішно 
   ; пройшла перевірка
   ; stosw збільшує di на 2 
   ; ah+al = +2
   xor al, al ; 0
   xor si, si ; 0
   xor cx, cx ; 0
   mov si, loading ; рядок
   mov cx, 10
   
kernel_start:
   cld ; df 0
   lodsb ; ds/si = al
   cmp al, 0 ; (128-129-130) кінець рядка?
   je main
   mov ah, 0x0E ; text bios mode
   inc di  ; збільшуєм di
   int 0x10 ; video mode
   loop kernel_start
   
main:
   call video_start
     
ram_no:
  xor cx, cx ; 0
  mov cx, 512 ; 512 кілобайт
  cmp ax, cx ; cx = ax?
  je mem_no ; no
   
mem_no:
   xor cx, cx ; 0
   mov cx, 256 ; 256?
  cmp ax, cx ; cx = ax?
  ; еслі ram дуже мало ми зберігаєм і потім виводим на екран
  ; кількість ram 
  xor ax, ax ; bit 1 no ram 640 bit = 0 = ok
  je disk_of_format   

loading db "vortex 0.1", 13, 10, 0
   
times 401 db  0
