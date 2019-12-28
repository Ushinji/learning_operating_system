; ------
; IPLへJMP命令
; ------
; BPB   (BIOS Parameter Block)
; ------
; IPL   (Initial Program Loader)
; ------

entry:
        jmp     ipl
        
        ; BPB領域の初期化
        ; 90バイト分、NOP(CPUの無操作命令: 0x90)で埋める
        times 90 - ($ - $$) db 0x90
ipl:
        jmp     $

        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA
