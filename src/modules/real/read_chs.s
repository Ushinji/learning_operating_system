; int read_chs(drive, sect, dst);
; @params drive :drive構造体のアドレス
; @params sect  :読み出しセクタ数
; @params dst   :読み出し先アドレス 
; @return       :読み込んだセクタ数


; // ****************
; // レジスタ位置関係
; // ****************
;   + 8 | dst
;   + 6 | sect
;   + 4 | drive
;   + 2 | 戻り番地
; BP+ 0 | BP
; -----------------
;   - 2 | retry = 3(読み込みリトライ回数)
;   - 4 | sect  = 0(読み込みセクタ数)

read_chs:
    ; スタックフレームの構築
    push    bp
    mov     bp, sp
    push    3
    push    0       

    ; レジスタの保存
    push    bx
    push    cx
    push    dx
    push    es
    push    si

    ; 処理の開始
    mov     si, [bp + 4]                ; drive構造体のアドレスを取得
    
    ; CXレジスタの設定
    mov     ch, [si + drive.cyln + 0]   ; CH = シリンダ番号(下位バイト)
    mov     cl, [si + drive.cyln + 1]   ; CL = シリンダ番号(上位バイト)
    shl     cl, 6                       ; CL <<= 6; 上位2ビットにシフト 0x11 -> 0x110000
    or      cl, [si + drive.sect]       ; CL |= セクタ番号(0x110000 | 0x1 = 0x110001)

    ; セクタ読み込み
    mov     dh, [si + drive.head]       ; DH = ヘッド取得
    mov     dl, [si + 0]                ; DL = ドライブ番号
    mov     ax, 0x0000                  ; AX = 0x0000
    mov     es, ax                      ; ES = セグメント
    mov     bx, [bp + 8]                ; BX = コピー先(dst)
.10L:
    mov     ah, 0x02                    ; AH = セクタ読み込み命令
    mov     al, [bp + 6]                ; AL = 読み込みセクタ数(sect)

    int     0x13                        ; セクタ読み込み実行: BIOS(0x13, 0x02): セクタ読み出し
    jnc     .11E                        ; 
    mov     al, 0
    jmp     .10E
.11E:
    cmp     al, 0                       ; 読み込みセクタ数を0
    jne     .10E

    mov     ax, 0
    dec     word [bp - 2]               ; リトライ回数をデクリメント
    jnz     .10L                        ; 一行前のデクリメント結果が0でない場合、ループする
.10E:
    mov     ah, 0                       ; ステータス情報を破棄

    ; レジスタの復帰
    pop     si
    pop     es
    pop     dx
    pop     cx
    pop     bx

    ; スタックフレームの破棄
    mov     sp, bp
    pop     bp

    ret