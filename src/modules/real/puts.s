; ******************************
; void puts(str);
; -----------------
; str: 文字列のアドレス
; -----------------
; ******************************

; // ****************
; // レジスタ位置関係
; // ****************
;   + 4 | str
;   + 2 | 戻り番地
; BP+ 0 | BP

puts:
    ; スタックフレームの構築
    push    bp
    mov     bp, sp

    ; レジスタの保存
    push    ax              ;AX: Accumulate Register
    push    bx              ;BX: Base Register
    push    si              ;SI: Source Register。ストリーム操作コマンド（たとえば MOV命令）でのソース（入力元）へのポインタとして使用

    ; 引数取得
    mov     si, [bp + 4]

    ; 処理開始
    mov     ah, 0x0E        ; AH(AXの上位(Hight)8bit)に、テレタイプ式1文字出力を設定
    mov     bx, 0x0000      ; ページ番号と文字色を0に設定
    cld                     ; Clear Direction Flag. DF=0で+方向に設定
.10L:
    ; LODSB命令: SIレジスタに指定されたアドレスから1バイト分のデータをALレジスタに読み込む。
    ; そして、SIレジスタの値を1加算(or減算)を行う。今回はDF=0のため加算される)
    lodsb
    
    ; ALレジスタを比較し0x00(終端文字)の場合は処理終了
    ; 終端文字ではない場合は、該当文字の文字を出力し、処理を繰り返す
    cmp     al, 0
    je      .10E
    int     0x10            ; ビデオBIOSコール(INT10)
    jmp     .10L
.10E:

    ; レジスタの復帰
    pop si
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ; 呼び出し元へ戻る
    ret
