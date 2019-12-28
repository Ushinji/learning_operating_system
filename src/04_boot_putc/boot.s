; **********************************************
; put_c
; put_c関数を呼び出して、文字出力を行う
; **********************************************

        BOOT_LOAD       equ     0x7C00
        ORG     BOOT_LOAD

; マクロ読み込み
%include "../include/macro.s"

entry:
        jmp     ipl
        times 90 - ($ - $$) db 0x90
ipl:
        cli
        mov     ax, 0x0000      ; Accumulate(蓄積) Register = 0x0000
        mov     ds, ax          ; Data Segment  = 0x0000
        mov     es, ax          ; Extra Segment = 0x0000
        mov     ss, ax          ; Stack Segment = 0x0000
        mov     sp, BOOT_LOAD   ; Stack Point   = 0x7C00

        sti

        mov     [BOOT.DRIVE], dl

        cdecl   putc, word 'X'
        cdecl   putc, word 'Y'
        cdecl   putc, word 'Z'

        jmp     $

; ALIGNディレクティブ。データを2バイト境界で配置するように指示
ALIGN 2, db 0

; ブートドライブに関する情報
BOOT:
.DRIVE:         dw 0    ; ドライブ番号

; モジュール読み込み
%include        "../modules/real/putc.s"

        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA
