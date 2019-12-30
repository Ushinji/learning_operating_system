; --------------------------------------
; int get_font_adr(adr);
; @params adr   : フォントアドレスの格納位置
; @return       : なし
; --------------------------------------

; ****************
; レジスタ位置関係
; ***************
;   + 4 | adr
;   + 2 | 戻り番地
; BP+ 0 | BP
; -----------------

get_font_adr:
        ; スタックフレームの構築
        push bp
        mov bp, sp

        ; レジスタの保存
        push ax
        push bx
        push si
        push es
        push bp

        ; 引数を取得
        mov si, [bp + 4]

        ; フォントアドレスの取得
        ; - AXとBHに指定の値を設定することで、フォントアドレスが取得できる
        ;   Ref: http://hp.vector.co.jp/authors/VA003720/lpproj/int10h/i101130.htm
        mov ax, 0x1130  ; 0x1130:フォントアドレス取得
        mov bh, 0x06    ; 0x06  :8x16ドットサイズ 
        int 10h

        ; フォントアドレスを保存
        mov [si + 0], es    ; セグメント
        mov [si + 2], bp    ; オフセット

        ; レジスタの復帰
        pop bp
        pop es
        pop si
        pop bx
        pop ax

        ; スタックフレームの破棄
        mov sp, bp
        pop bp

        ret
