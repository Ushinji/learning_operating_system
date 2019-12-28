; **********************************************
; put_c
; 文字を出力する
; **********************************************

        ; equ: C言語の#defineと同じ。アセンブル時に、指定の定数を指定した値に置き換えてくれる
        ; equ = Equal(だと思われる)
        BOOT_LOAD       equ     0x7C00  ;ブートプログラムのロード位置

        ; ロードアドレスをアセンブラに指示.ORG=origin.
        ; ORGディレクティブにより、アセンブラが出力するアドレスにはBOOT_LOADの値が加算されるため、BPBへの意図しない書き込みを防ぐ。
        ORG     BOOT_LOAD

entry:
        jmp     ipl
        times 90 - ($ - $$) db 0x90
ipl:
        ; BIOSからの割り込みを禁止
        cli

        ; 割り込み禁止中に行う初期化処理
        mov     ax, 0x0000      ; Accumulate(蓄積) Register = 0x0000
        ; セグメントレジスタに対して直接に値を代入することはできないので、AXレジスタ経由で行う
        mov     ds, ax          ; Data Segment  = 0x0000
        mov     es, ax          ; Extra Segment = 0x0000
        mov     ss, ax          ; Stack Segment = 0x0000
        mov     sp, BOOT_LOAD   ; Stack Point   = 0x7C00

        ; 割り込み許可
        sti

        ;ブートドライブを保存
        mov     [BOOT.DRIVE], dl

        mov     al, 'A'         ; AL(AXの下位(Low)8bit)に'A'を代入
        mov     ah, 0x0E        ; AHレジスタに、テレタイプ式1文字出力を設定
        mov     bx, 0x0000      ; ページ番号と文字色を0に設定
        int     0x10            ; ビデオBIOSコール(INT10)

        jmp     $

; ALIGNディレクティブ。データを2バイト境界で配置するように指示
ALIGN 2, db 0

; ブートドライブに関する情報
BOOT:
.DRIVE:         dw 0    ; ドライブ番号

        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA
