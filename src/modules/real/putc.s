; ******************************
; void putc(ch);
; -----------------
; ch: 文字コード
; -----------------
; ******************************

; // ****************
; // レジスタ位置関係
; // ****************
;   + 4 | ch
;   + 2 | 戻り番地
; BP+ 0 | BP

putc:
    ; スタックフレームの構築
    push    bp
    mov     bp, sp

    ; レジスタの保存
    push    ax              ;AX: Accumulate Register
    push    bx              ;BX: Base Register

    mov     al, [bp + 4]    ; AL(AXの下位(Low)8bit)に引数のchを代入
    mov     ah, 0x0E        ; AH(AXの上位(Hight)8bit)に、テレタイプ式1文字出力を設定
    mov     bx, 0x0000      ; ページ番号と文字色を0に設定
    int     0x10            ; ビデオBIOSコール(INT10)

    ; レジスタの復帰
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ; 呼び出し元へ戻る
    ret
