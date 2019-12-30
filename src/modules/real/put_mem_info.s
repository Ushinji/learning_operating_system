; --------------------------------------
; int put_mem_info(adr);
; @params adr   :バッファアドレス
; @return       :成功(0以外) or 失敗(0)
; --------------------------------------

; ****************
; レジスタ位置関係
; ***************
;   + 4 | adr
;   + 2 | 戻り番地
; BP+ 0 | BP
; -----------------

put_mem_info:
    ; スタックフレームの構築
    push bp
    mov  bp, sp

    ; レジスタの保存
    push bx
    push si

    ; 引数の取得
    mov si, [bp + 4]

    ; Baseアドレス(64bit)
    cdecl itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

    ; データ長(64bit)
    cdecl itoa, word [si + 14], .p4 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl itoa, word [si + 10], .p5 + 0, 4, 16, 0b0100
    cdecl itoa, word [si +  8], .p5 + 4, 4, 16, 0b0100

    ; Type(32bit)
    cdecl itoa, word [si + 18], .p6 + 0, 4, 16, 0b0100
    cdecl itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100

    cdecl puts, .s1

    ; Typeを文字列として表示
    mov bx, [si + 16]
    and bx, 0x07            ; 0010 & 0111 = 0010
    shl bx, 1               ; 0010 -> 0100(=4)
    add bx, .t0             ; レコード情報テーブルの先頭アドレスを加算 -> 指定レコードの情報が取得できる
    cdecl puts, word [bx]

    ; レジスタの復帰
    pop si
    pop bx

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret

; 定数定義
.s1:    db " "
.p2:    db "ZZZZZZZZ_"
.p3:    db "ZZZZZZZZ "
.p4:    db "ZZZZZZZZ_"
.p5:    db "ZZZZZZZZ "
.p6:    db "ZZZZZZZZ", 0

.s4:    db "(Unknown)", 0x0A, 0x0D, 0
.s5:    db "(usable)", 0x0A, 0x0D, 0
.s6:    db "(reserved)", 0x0A, 0x0D, 0
.s7:    db "(ACPI data)", 0x0A, 0x0D, 0
.s8:    db "(ACPI NVS)", 0x0A, 0x0D, 0
.s9:    db "(bad memory)", 0x0A, 0x0D, 0

        ; dw(data double byte): 2バイトデータとして定義する
        ; 要素間のアドレス差は2byteなので、+2すると次要素になる
.t0:    dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4
