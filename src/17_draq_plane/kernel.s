%include "../include/define.s"
%include "../include/macro.s"

    ORG KERNEL_LOAD

[BITS 32]
; エントリポイント
kernel:
    ; フォントアドレスの取得
    mov esi, BOOT_LOAD + SECT_SIZE
    movzx eax, word [esi + 0]
    movzx ebx, word [esi + 2]
    shl eax, 4
    add eax, ebx
    mov [FONT_ADR], eax

    ; オフセット計算
    shl edi, 8  ; EDI *= 256
    lea edi, [edi * 4 + edi + 0xA_0000] ; EDI = 0xA_0000[EDI * 4 + EDI]; // VRAMアドレス

    ; 水色で表示する場合
    mov ah, 0x04    ; AH = 書き込みプレーンを指定
    mov al, 0x02    ; AL = マップマスクレジスタ(書き込みプレーンを指定)
    mov dx, 0x03C4  ; 0x03C4
    out dx, ax      ; // ポート出力(プレーンの選択)

    mov [0x00A_0000], byte 0x00
    mov ah, 0x0B    ; 書き込みプレーンを指定
    out dx, ax      ; ポート出力(プレーン選択)

    mov [0x000A_0000], byte 0x80 ; ビットパターンの書き込み
    
    ; 処理終了
    jmp $

; パディング
        times KERNEL_SIZE - ($ - $$) db 0

