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

    ; 処理終了
    jmp $

; パディング
        times KERNEL_SIZE - ($ - $$) db 0

