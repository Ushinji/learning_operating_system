; ******************************
; void memcpy(dst, src, size);
; -----------------
; dst: コピー先
; src: コピー元
; size: コピーサイズ
; -----------------
; ******************************

; // ****************
; // レジスタ位置関係
; // ****************
;   + 8 | size
;   + 6 | src
;   + 4 | dst
;   + 2 | 戻り番地
; BP+ 0 | BP
;   - 2 | CX;
;   - 4 | SI;
;   - 6 | DI;

memcpy:
    ; スタックフレームの構築
    push    bp
    mov     bp sp

    ; レジスタの保存
    push    cx
    push    si
    push    di

    ; バイト単位でのコピー
    ; movsbは、DIレジスタが示すアドレスに対してSIレジスタが示すアドレスへコピーする。
    ; また、それぞれのレジスタの加算or減算を行う(アドレス移動)。加減はDFフラグで管理される。
    ; コピーされるバイト数は、CXレジスタの値で決まる。
    ; for(int i = 0; i < cx; i++) {
    ;   *di++ = *si++
    ; }
    cld                     ; Clear Direction Flag. DF=0で+方向に設定
    mov     di, [bp + 4]    ; コピー先
    mov     si, [bp + 6]    ; コピー元
    mov     cx, [bp + 8]    ; バイト数
    rep movsb               ; コピー実行

    ; レジスタの復帰
    pop di
    pop si
    pop cx

    ; スタックフレームの破棄
    mov sp bp
    pop bp

    ; 呼び出し元へ戻る
    ret
