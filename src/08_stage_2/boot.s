; **********************************************
; stage_2
; **********************************************

        BOOT_LOAD       equ     0x7C00
        ORG     BOOT_LOAD

%include "../include/macro.s"

entry:
        jmp     ipl
        times 90 - ($ - $$) db 0x90
ipl:
        cli                             ; BIOSからの割り込みを禁止
        mov     ax, 0x0000              ; Accumulate(蓄積) Register = 0x0000
        mov     ds, ax                  ; Data Segment  = 0x0000
        mov     es, ax                  ; Extra Segment = 0x0000
        mov     ss, ax                  ; Stack Segment = 0x0000
        mov     sp, BOOT_LOAD           ; Stack Point   = 0x7C00

        sti                             ; BIOSからの割り込みを許可

        mov     [BOOT.DRIVE], dl        ; ブートドライブを保存

        cdecl   puts, .s0

        mov     ah, 0x02                ; AH: 読み込み命令
        mov     al, 1                   ; AL: 読み込みセクタ数
        mov     cx, 0x0002              ; CX: シリンダ/セクタ
        mov     dh, 0x00                ; DH: ヘッド位置
        mov     dl, [BOOT.DRIVE]        ; DL: ドライブ番号
        mov     bx, 0x7C00 + 512        ; BX: オフセット
        int     0x13                    ; BIOS(0x13, 0x02): セクタ読み出し
.10Q:   jnc     .10E                    
.10T:   cdecl   puts, .e0               ; セクタ読み込みに失敗した場合は、再起動
        call    reboot
.10E:

        ; 次ステージへ移行
        jmp     stage_2

; データ定義
; 0x0A(LF.カーソル位置を一行下げる), 0x0D(CR.カーソル位置を左端に移動する)
.s0     db      "Booting....", 0x0A, 0x0D, 0
.s1     db      "--------", 0x0A, 0x0D, 0
.e0     db      "Error:sector read", 0x0A, 0x0D, 0

; ALIGNディレクティブ。データを2バイト境界で配置するように指示
ALIGN 2, db 0

; ブートドライブに関する情報
BOOT:
.DRIVE:         dw 0    ; ドライブ番号

; モジュール読み込み
%include        "../modules/real/puts.s"
%include        "../modules/real/reboot.s"

        ; プートフラグの定義
        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA

stage_2:
        cdecl   puts, .s0
        jmp     $

; データ定義
.s0     db      "2nd stage...", 0x0A, 0x0D, 0

        ; ブートプログラムを8Kバイトとして定義
        times (1024 * 8) - ($ - $$) db 0        ; 8Kバイト
