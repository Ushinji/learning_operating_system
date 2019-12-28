; ******************************
; short memcmp(src0, src1, size);
; -----------------
; 戻り値: 一致(0), 不一致(0以外)
; src0 : アドレス0
; src1 : アドレス1
; size : 比較サイズ
; -----------------
; ******************************

; // ****************
; // レジスタ位置関係
; // ****************
;   + 8 | size
;   + 6 | src1
;   + 4 | src0
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
    push    bx              ; BX: Base Register
    push    cx              ; CX: Count Register
    push    dx              ; DX: Data Register
    push    si              ; SI: Source Index
    push    di              ; DI: Destination Index

    ; 引数取得
    cld                     ; Clear Direction Flag. DF=0で+方向に設定
    mov     si, [bp + 4]    ; アドレス0
    mov     di, [bp + 6]    ; アドレス1
    mov     cx, [bp + 8]    ; バイト数

    ; バイト単位での比較。結果はAXレジスタ(アキュムレータ)へ保存
    repe cmpsb
    jnz     .10F
    mov     ax, 0
    jmp     .10E
.10F:
    mov     ax, -1

.10E
    ; レジスタの復帰
    pop di
    pop si
    pop dx
    pop cx
    pop bx

    ; スタックフレームの破棄
    mov sp bp
    pop bp

    ; 呼び出し元へ戻る
    ret
