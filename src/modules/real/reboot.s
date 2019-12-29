reboot:
    ; 再起動の説明を出力
    cdecl   puts, .s0

.10L:
    ; キー入力待ち
    mov     ah, 0x10
    int     0x16

    ; キー入力が空白文字ではない場合、再度キー入力待ちへ戻る
    cmp     al, ' '
    jne     .10L

    ; 改行出力
    cdecl   puts, .s1

    ; 再起動
    int     0x19


    ; 文字列データ
.s0     db 0x0A, 0x0D, "Push SPACE Key to reboot...", 0
.s1     db 0x0A, 0x0D, 0x0A, 0x0D, 0

