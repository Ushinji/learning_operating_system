; --------------------------------------
; void get_mem_info();
; @return       : なし
; --------------------------------------

; ****************
; レジスタ位置関係
; ***************
;   + 2 | 戻り番地
; BP+ 0 | BP
; -----------------

get_mem_info:
        ; レジスタ保存
        ; eax: 32bit(ax: 16bit, rax: 64bit)
        push eax
        push ebx
        push ecx
        push edx
        push si
        push di
        push bp

ALIGN 4, db 0
.b0:    times E820_RECORD_SIZE db 0
        cdecl puts, .s0
        
        ; メモリ情報取得開始
        mov bp, 0
        mov ebx, 0
.10L:
        ; メモリ情報を取得するBIOSコール
        mov eax, 0x0000E820         ; EAX   = 0xE820(要求コマンド)
                                    ; EBX   = インデックス(0)
        mov ecx, E820_RECORD_SIZE   ; ECX   = 要求バイト数
        mov edx, 'PAMS'             ; EDX   = SMAP
        mov di, .b0                 ; ES:DI = バッファ
        int 0x15                    ; BIOS(0x15, 0xE820)

        ; メモリ情報取得が未対応のBIOSの場合(EAXにSMAPが設定されないはず)
        cmp eax, 'PAMS'
        je  .12E
        jmp .10E
.12E:
        ; BIOSコールに失敗した場合(エラー時はCFで判断可能)
        jnc .14E
        jmp .10E
.14E:
        ; 1コード分のメモリ情報を表示
        cdecl put_mem_info, di

        ; ACPI dataのアドレスを取得
        mov eax, [di + 16]          ; EAX: レコードタイプ
        cmp eax, 3                  ; EAX = 3(ACPI data)の場合
        jne .15E

        mov eax, [di + 0]           ; メモリ領域のBASEアドレスの保存
        mov [ACPI_DATA.adr], eax

        mov eax, [di + 8]           ; メモリ領域のサイズの保存
        mov [ACPI_DATA.len], eax
.15E:
        cmp ebx, 0
        jz  .16E
        
        inc bp
        and bp, 0x07
        jnz .16E
        
        cdecl puts, .s2

        mov ah, 0x10
        int 0x16
        
        cdecl puts, .s3
.16E:
        cmp ebx, 0
        jne .10L
.10E:
        cdecl puts, .s1
        
; レジスタ復帰
        pop bp
        pop di
        pop si
        pop edx
        pop ecx
        pop ebx
        pop eax

        ret

; データ定義
.s0:	db " E820 Memory Map:", 0x0A, 0x0D
	db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:    db " <more...>", 0
.s3:    db 0x0D, "          ", 0x0D, 0
