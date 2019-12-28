; // ****************
; // 1. 関数呼び出し前
; // ****************
;       | (<- SP)

; // ****************
; // 2. 関数呼び出し直後
; // ****************
;       | 引数2
;       | 引数1
;       | 戻り番地 (<- SP)

; // ****************
; // 3. 関数処理の途中
; // ****************
;   + 6 | 引数2
;   + 4 | 引数1
;   + 2 | 戻り番地
; BP+ 0 | BP
; ------|------------
;   - 2 | short i;
;   - 4 | short j = 0; (<- SP)

; // ****************
; // 4. SPレジスタの復帰
; // ****************
;   + 6 | 引数2
;   + 4 | 引数1
;   + 2 | 戻り番地
; BP+ 0 | BP  (<- SP. SP以下のローカル変数はポップされる(ことと同義))
; ------|------------
;   - 2 | short i;
;   - 4 | short j = 0;

; // ****************
; // 5. BPレジスタの復帰
; // ****************
;   + 6 | 引数2
;   + 4 | 引数1
;   + 2 | 戻り番地  (<- SP. POPして戻り番地へSPを移動)
; BP+ 0 | BP
; ------|------------
;   - 2 | short i;
;   - 4 | short j = 0;

; // ****************
; // 6. CALL命令終了時のスタック
; // ****************
;   + 6 | 引数2
;   + 4 | 引数1 (<- SP)
;   + 2 | 戻り番地 
; BP+ 0 | BP
; ------|------------
;   - 2 | short i;
;   - 4 | short j = 0;

; // ****************
; // 7. 引数スタックの破棄
; // ****************
;       | (<- SP)
;   + 6 | 引数2
;   + 4 | 引数1
;   + 2 | 戻り番地 
; BP+ 0 | BP
; ------|------------
;   - 2 | short i;
;   - 4 | short j = 0;

Test:
    ; 1. 関数呼び出し前
    push    0x0002      ;引数2
    push    0x0001      ;引数1

    ; 2. 関数呼び出し後
    call    func_16     ;func_16呼び出し。呼び出し関数側では引数の値を参照できるSPレジスタが使用できる

    ; 7. 引数スタックの破棄
    add     sp, 2 * 2   ;引数スタックの破棄。

func_16:
    ; 3. 関数処理の途中
    push    bp
    mov     bp, sp              ;BPレジスタに、SPレジスタのアドレスを保持
    sub     sp, 2               ;int i;(ローカル変数の宣言のみ(アドレスを2byte確保))
    push    1                   ;int j = 1;(ローカル変数の宣言、初期化)

    mov     [bp - 2], word 10   ;i = 10 (BPレジスタを基準にローカル変数へ代入)
    mov     [bp - 4], word 20   ;i = 20

    mov     ax, [bp + 4]        ;引数1をxに代入
    mov     [bp - 2], ax        ;i = x;
    
    mov     ax, 1               ;return 1; 戻り値はAXレジスタに設定する

    ; 4. SPレジスタの復帰
    mov     sp, bp;             ;SPレジスタの復帰(SPレジスタの値を、基準としていたBPレジスタの値に設定し直す)

    ; 5. BPレジスタの復帰
    pop     bp                  ;BPレジスタの復帰

    ; 6. CALL命令終了時
    ret                         ;関数終了。スタック上の戻り番地へ移動。



