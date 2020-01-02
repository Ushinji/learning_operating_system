%include "../include/define.s"
%include "../include/macro.s"

    ORG KERNEL_LOAD

[BITS 32]
; エントリポイント
kernel:
    ; 処理終了
    jmp $

; パディング
        times KERNEL_SIZE - ($ - $$) db 0

