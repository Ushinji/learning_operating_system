; **********************************************
; itoa
; 数値を表示する
; **********************************************

        BOOT_LOAD       equ     0x7C00
        ORG     BOOT_LOAD

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

        cdecl   puts, .s0

        cdecl   itoa, 8086, .s1, 8, 10, 0b0001
        cdecl   puts, .s1
        cdecl   itoa, 8086, .s1, 8, 10, 0b0011
        cdecl   puts, .s1
        cdecl   itoa, -8086, .s1, 8, 10, 0b0001
        cdecl   puts, .s1
        cdecl   itoa, -1, .s1, 8, 10, 0b0001
        cdecl   puts, .s1
        cdecl   itoa, -1, .s1, 8, 10, 0b0000
        cdecl   puts, .s1
        cdecl   itoa, -1, .s1, 8, 16, 0b0000
        cdecl   puts, .s1
        cdecl   itoa, 12, .s1, 8, 2, 0b0100
        cdecl   puts, .s1

        jmp     $

;データ定義
; 0x0A(LF.カーソル位置を一行下げる), 0x0D(CR.カーソル位置を左端に移動する)
.s0     db      "Booting....", 0x0A, 0x0D, 0
.s1     db      "--------", 0x0A, 0x0D, 0

; ALIGNディレクティブ。データを2バイト境界で配置するように指示
ALIGN 2, db 0

; ブートドライブに関する情報
BOOT:
.DRIVE:         dw 0    ; ドライブ番号

; モジュール読み込み
%include        "../modules/real/puts.s"
%include        "../modules/real/itoa.s"

        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA
