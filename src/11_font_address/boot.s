; **********************************************
; font_address
; **********************************************
%include "../include/macro.s"
%include "../include/define.s"

        ORG     BOOT_LOAD

entry:
        jmp     ipl
        times 90 - ($ - $$) db 0x90
ipl:
        cli                                     ; BIOSからの割り込みを禁止
        mov     ax, 0x0000                      ; Accumulate(蓄積) Register = 0x0000
        mov     ds, ax                          ; Data Segment  = 0x0000
        mov     es, ax                          ; Extra Segment = 0x0000
        mov     ss, ax                          ; Stack Segment = 0x0000
        mov     sp, BOOT_LOAD                   ; Stack Point   = 0x7C00

        sti                                     ; BIOSからの割り込みを許可

        mov     [BOOT + drive.no], dl           ; ブートドライブを保存

        cdecl   puts, .s0

        ; 残りのセクタをすべて読み込む
        mov     bx, BOOT_SECT - 1               ; BX=残りのブートセクタ数
        mov     cx, BOOT_LOAD + SECT_SIZE       ; CX=次のロードアドレス

        cdecl   read_chs, BOOT, bx, cx          ; セクタ読み込み実行

        cmp     ax, bx                          ; 戻り値(AX) != 残りのセクタ数(bx) -> 再起動する
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        ; 次ステージへ移行
        jmp     stage_2

; データ定義
; 0x0A(LF.カーソル位置を一行下げる), 0x0D(CR.カーソル位置を左端に移動する)
.s0     db      "Booting....", 0x0A, 0x0D, 0
.s1     db      "--------", 0x0A, 0x0D, 0
.e0     db      "Error:sector read", 0x0A, 0x0D, 0

; ブートドライブに関する情報
ALIGN 2, db 0                                   ; ALIGNディレクティブ。データを2バイト境界で配置するように指示
BOOT:
        istruc drive
             at drive.no,       dw  0           ; ドライブ番号
             at drive.cyln,     dw  0           ; C: シリンダ
             at drive.head,     dw  0           ; H: ヘッド
             at drive.sect,     dw  2           ; S: セクタ
        iend
        
; モジュール読み込み
%include        "../modules/real/puts.s"
%include        "../modules/real/reboot.s"
%include        "../modules/real/read_chs.s"

        ; プートフラグの定義
        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA

; リアルモード時に取得した情報
FONT:
.seg: dw 0
.off: dw 0

; モジュール(先頭512バイト以降に配置)
%include        "../modules/real/itoa.s"
%include        "../modules/real/get_drive_params.s"
%include        "../modules/real/get_font_adr.s"

stage_2:
        cdecl   puts, .s0

        ; ドライブ情報を取得
        cdecl   get_drive_params, BOOT
        cmp     ax, 0
.10Q:   jne     .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        ; ドライブ情報を表示
        ; 以下が表示される
        ; Drive:0x80, C:0x0014, H:0x02, D:0x10
        ; ドライブ番号:128, シリンダ数:20, ヘッド数:2, セクタ数:16
        mov     ax, [BOOT + drive.no]
        cdecl   itoa, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]
        cdecl   itoa, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]
        cdecl   itoa, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]
        cdecl   itoa, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1

        ; 処理の終了
        jmp     stage_3rd

; データ定義
.s0     db      "2nd stage...", 0x0A, 0x0D, 0

.s1     db      " Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive parameter. ", 0

stage_3rd:
        cdecl   puts, .s0

        ; フォントアドレスを取得(BIOSが利用するフォント)
        cdecl   get_font_adr, FONT

        ; フォントアドレス表示
        cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ; 処理終了
        jmp     $

; データ
.s0     db "3nd stage...", 0x0A, 0x0D, 0
.s1:    db " Font Adress="
.p1:    db "ZZZZ:"
.p2:    db "ZZZZ", 0x0A, 0x0D, 0
        db 0x0A, 0x0D, 0

        ; ブートプログラムを8Kバイトとして定義
        times BOOT_SIZE - ($ - $$) db 0        ; 8Kバイト
