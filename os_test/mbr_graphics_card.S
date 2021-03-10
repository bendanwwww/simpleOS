;主引导程序 
; 编译命令 nasm -o mbr_graphics_card.bin mbr_graphics_card.S
; 写入磁盘 dd if=/your_path/mbr.bin of=/your_path/bochs/hd60M.img bs=512 count=1 conv=notrunc
;
;LOADER_BASE_ADDR equ 0xA000
;LOADER_START_SECTOR equ 0x2 
;------------------------------------------------------------ 
SECTION MBR vstart=0x7c00  ; 起始编译地址
   mov ax,cs               ; 初始化 ax ds es ss fs 寄存器
   mov ds,ax
   mov es,ax
   mov ss,ax
   mov fs,ax
   mov sp,0x7c00           ; 初始化栈指针
   mov ax,0xb800           ; 初始化 gs 段基址
   mov gs,ax
; 清屏
; 利用0x06号功能，上卷全部行，则可清屏
; -----------------------------------------------------------
; INT 0x10 功能号:0x06 功能描述:上卷窗口 
; ------------------------------------------------------ 
; 输入:
; AH 功能号= 0x06
; AL = 上卷的行数(如果为 0，表示全部)
; BH = 上卷行属性
;(CL,CH) = 窗口左上角的(X,Y)位置
; (DL,DH) = 窗口右下角的(X,Y)位置
; 无返回值:
mov ax, 0600h     ; 上卷功能号+上卷行数 06 + 00
mov bx, 0700h     ; 上卷行属性 07
mov cx, 0         ; 左上角: (0, 0)
mov dx, 184fh     ; 右下角: (80,25),
                  ; VGA 文本模式中，一行只能容纳 80 个字符，共 25 行 
                  ; 下标从 0 开始，所以 0x18=24，0x4f=79
int 10h           ; int 10h 执行上卷窗口

; 输出背景色绿色，前景色红色，并且跳动的字符串"1 MBR"
mov byte [gs:0x00], '1'  ; 段基址gs 偏移量0x00处写入 ‘1’ byte关键字指明操作数宽度 1字节
mov byte [gs:0x01], 0xA4 ; A表示绿色背景闪烁，4表示前景色为红色

mov byte [gs:0x02], ' '
mov byte [gs:0x03], 0xA4

mov byte [gs:0x04], 'M'
mov byte [gs:0x05], 0xA4

mov byte [gs:0x06], 'B'
mov byte [gs:0x07], 0xA4

mov byte [gs:0x08], 'R'
mov byte [gs:0x09], 0xA4

jmp $   ; 通过死循环使程序悬停在此

times 510-($-$$) db 0   ; 用0填充512-2字节的剩余内容
db 0x55,0xaa            ; mbr最后两个字节为固定内容 填充