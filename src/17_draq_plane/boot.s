; **********************************************
; カーネルを読み込む
; **********************************************
%include "../include/macro.s"
%include "../include/define.s"

        ORG     BOOT_LOAD

entry:
        jmp     ipl
        times 90 - ($ - $$) db 0x90
ipl:
        cli                                     ; BIOSからの割り込みを禁止
        mov     ax, 0x0000                      ; Accumulate(蓄積) Register = 0x0000
        mov     ds, ax                          ; Data Segment  = 0x0000
        mov     es, ax                          ; Extra Segment = 0x0000
        mov     ss, ax                          ; Stack Segment = 0x0000
        mov     sp, BOOT_LOAD                   ; Stack Point   = 0x7C00

        sti                                     ; BIOSからの割り込みを許可

        mov     [BOOT + drive.no], dl           ; ブートドライブを保存

        cdecl   puts, .s0

        ; 残りのセクタをすべて読み込む
        mov     bx, BOOT_SECT - 1               ; BX=残りのブートセクタ数
        mov     cx, BOOT_LOAD + SECT_SIZE       ; CX=次のロードアドレス

        cdecl   read_chs, BOOT, bx, cx          ; セクタ読み込み実行

        cmp     ax, bx                          ; 戻り値(AX) != 残りのセクタ数(bx) -> 再起動する
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        ; 次ステージへ移行
        jmp     stage_2

; データ定義
; 0x0A(LF.カーソル位置を一行下げる), 0x0D(CR.カーソル位置を左端に移動する)
.s0     db      "Booting....", 0x0A, 0x0D, 0
.s1     db      "--------", 0x0A, 0x0D, 0
.e0     db      "Error:sector read", 0x0A, 0x0D, 0

; ブートドライブに関する情報
ALIGN 2, db 0                                   ; ALIGNディレクティブ。データを2バイト境界で配置するように指示
BOOT:
        istruc drive
             at drive.no,       dw  0           ; ドライブ番号
             at drive.cyln,     dw  0           ; C: シリンダ
             at drive.head,     dw  0           ; H: ヘッド
             at drive.sect,     dw  2           ; S: セクタ
        iend
        
; モジュール読み込み
%include        "../modules/real/puts.s"
%include        "../modules/real/reboot.s"
%include        "../modules/real/read_chs.s"

        ; プートフラグの定義
        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA

; リアルモード時に取得した情報
FONT:
.seg: dw 0
.off: dw 0
ACPI_DATA:
.adr: dd 0
.len: dd 0

; モジュール(先頭512バイト以降に配置)
%include        "../modules/real/itoa.s"
%include        "../modules/real/get_drive_params.s"
%include        "../modules/real/get_font_adr.s"
%include        "../modules/real/get_mem_info.s"
%include        "../modules/real/put_mem_info.s"
%include        "../modules/real/kbc.s"
%include        "../modules/real/lba_chs.s"
%include        "../modules/real/read_lba.s"

stage_2:
        cdecl   puts, .s0

        ; ドライブ情報を取得
        cdecl   get_drive_params, BOOT
        cmp     ax, 0
.10Q:   jne     .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        ; ドライブ情報を表示
        ; 以下が表示される
        ; Drive:0x80, C:0x0014, H:0x02, D:0x10
        ; ドライブ番号:128, シリンダ数:20, ヘッド数:2, セクタ数:16
        mov     ax, [BOOT + drive.no]
        cdecl   itoa, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]
        cdecl   itoa, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]
        cdecl   itoa, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]
        cdecl   itoa, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1

        ; 処理の終了
        jmp     stage_3rd

; データ定義
.s0     db      "2nd stage...", 0x0A, 0x0D, 0

.s1     db      " Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive parameter. ", 0

stage_3rd:
        cdecl   puts, .s0

        ; フォントアドレスを取得(BIOSが利用するフォント)
        cdecl   get_font_adr, FONT

        ; フォントアドレス表示
        cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ; メモリ情報の取得と表示
        cdecl   get_mem_info, ACPI_DATA

        mov     eax, [ACPI_DATA.adr]
        cmp     eax, 0
        je      .10E

        cdecl   itoa, ax, .p4, 4, 16, 0b0100
        shr     eax, 16
        cdecl   itoa, ax, .p3, 4, 16, 0b0100
        cdecl   puts, .s2
.10E:
        jmp     stage_4rd

; ローカルラベル
.s0:    db "3nd stage...", 0x0A, 0x0D, 0
.s1:    db " Font Adress="
.p1:    db "ZZZZ:"
.p2:    db "ZZZZ", 0x0A, 0x0D, 0
        db 0x0A, 0x0D, 0

.s2:    db " ACPI data="
.p3:    db "ZZZZ:"
.p4:    db "ZZZZ", 0x0A, 0x0D, 0

stage_4rd:
        cdecl   puts, .s0
        ; ----------------
        ; A20ゲートの有効化
        ; ----------------
        ; A20ゲート有効化途中の割り込み、キーボードの無効化
        cli
        cdecl KBC_cmd_write, 0xAD

        ; 出力ポート取得
        cdecl KBC_cmd_write, 0xD0  ; 読み込みコマンド実行
        cdecl KBC_data_read, .key ; データ読み込み実行

        ; 出力ポートに対して、A20ゲートを有効化(BL |= 0x02)
        mov bl, [.key]
        or bl, 0x02

        ; 変更後の出力ポートを書き込み
        cdecl KBC_cmd_write, 0xD1 ; 書き込みコマンド実行
        cdecl KBC_data_read, bx  ; データ書き込み実行

        ; 割り込み、キーボード無効化を解除
        cdecl KBC_cmd_write, 0xAE
        sti

        ; 終了メッセージ表示
        cdecl puts, .s1

        ; --------------------
        ; キーボードLEDのテスト
        ; --------------------
        cdecl puts, .s2

        mov bx, 0 ; bx: LEDの初期値

.10L:
        mov ah, 0x00
        int 0x16

        cmp al, '1'
        jb .10E

        cmp al, '3'
        ja .10E

        mov cl, al
        dec cl
        and cl, 0x03
        mov ax, 0x0001
        shl ax, cl
        xor bx, ax

        ; --------------------
        ; LEDコマンドの送信
        ; --------------------

        ; 割り込み、キーボードを無効化
        cli
        cdecl KBC_cmd_write, 0xAD

        ; LEDコマンド実行、応答受信
        cdecl KBC_data_write, 0xED
        cdecl KBC_data_read, .key

        ; キーボードが正常に応答できた場合(0xFA: ACK(Acknowledge))
        cmp [.key], byte 0xFA
        jne .11F

        cdecl KBC_data_write, bx
        jmp .11E
.11F:
        cdecl itoa, word [.key], .e1, 2, 16, 0b0100
        cdecl puts, .e0
.11E:
        ; 割り込み、キーボード有効化
        cdecl KBC_cmd_write, 0xAE
        sti

        jmp .10L
.10E:
        ; 文字列表示
        cdecl puts, .s3

        jmp stage_5rd

.s0:    db "4nd stage...", 0x0A, 0x0D, 0
.s1:    db " A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:    db " keyboard LED test...", 0
.s3:    db "(Done)", 0x0A, 0x0D, 0
.e0:    db "["
.e1:    db "ZZ]", 0

; KBC出力ポートの保存バッファ
.key:   dw 0

stage_5rd:
        ; 5rd 処理開始
        cdecl   puts, .s0

        ; カーネル読み込み
        ; AX(読み込んだセクタ数) = read_lba(drive, lba, sect, dst)
        cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
        cmp ax, KERNEL_SECT
.10Q:
        jz .10E
.10T:   
        cdecl puts, .e0
        call reboot
.10E:
        jmp stage_6rd

.s0:    db "5nd stage...", 0x0A, 0x0D, 0
.e0:    db " Faliure load kernel...", 0x0A, 0x0D, 0


stage_6rd:
        ; 6rd 処理開始
        cdecl   puts, .s0

        ; ユーザーからの入力待ち
.10L:
        mov ah, 0x00
        int 0x16
        cmp al, ' '
        jne .10L
        
        ; ビデオモードの設定
        mov ax, 0x0012  ; VGA 640×480
        int 0x10

        ; 処理終了
        jmp     stage_7rd

.s0:    db "6nd stage...", 0x0A, 0x0D, 0x0A, 0x0D
        db "[Push SPACE Key to protect mode...]", 0x0A, 0x0D, 0


; --------------------------------
; セグメントディスクリプターの配列
; --------------------------------
ALIGN 4, db 0
GDT:    dq 0x00_0_0_0_0_000000_0000     ; NULL
.cs:    dq 0x00_C_F_9_A_000000_FFFF     ; CODE 4G(実行/Read可)
.ds:    dq 0x00_C_F_9_2_000000_FFFF     ; DATA 4G(Read/Write可)
.gdt_end:

; --------------------------------
; セレクタ
; --------------------------------
SEL_CODE equ GDT.cs - GDT               ; コード用セレクタ
SEL_DATA equ GDT.ds - GDT               ; データ用セレクタ

; --------------------------------
; GDTR(Global Discripter Table Registor)
; --------------------------------
GDTR: dw GDT.gdt_end - GDT - 1          ; ディスクリプタテーブルのリミット
      dd GDT                            ; ディスクリプタテーブルのアドレス

; --------------------------------
; IDT(擬似: 割り込み禁止にするためだけ)
; --------------------------------
IDTR: dw 0                              ; IDTリミット
      dd 0                              ; IDTアドレス

stage_7rd:
        ; 割り込み禁止
        cli

        ; ディスクリプタテーブルの読み込み
        lgdt [GDTR]     ; GDTRをロード
        lidt [IDTR]     ; 割り込み用のディスクリプタテーブルを読み込み

        ; プロテクトモードへ移行
        mov eax, cr0    
        or  ax, 1
        mov cr0, eax

        ; リアルモードで読み込んだコードをCPU内部からクリアする
        jmp $ + 2

        ; セグメント間ジャンプ
[BITS 32]
        ; オペランドサイズオーバーライドプレフィックスを設定し、32ビット値を正しく読み込めるようにする
        DB 0x66
        jmp SEL_CODE:CODE_32


; --------------------------------
; 32ビットコード開始
; --------------------------------
CODE_32:
        ; セレクタ初期化。各セグメントレジスタに対して、データ用のセグメントディスクリプタ(へのオフセット)を設定。
        mov ax, SEL_DATA
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax

        ; カーネル部をコピー
        mov ecx, (KERNEL_SIZE) / 4      ; ECX = 4バイト単位でコピー
        mov esi, BOOT_END               ; ESI = カーネル部の先頭アドレス
        mov edi, KERNEL_LOAD            ; EDI = カーネルのロード先
        cld                             ; DFクリア(+方向にコピー)
        rep movsd                       ; while(ECX++) { *EDI++ = *ESI++; }

        ; カーネル処理に移行
        jmp     KERNEL_LOAD

; -------------
; パディング
; -------------
        times BOOT_SIZE - ($ - $$) db 0        ; 8Kバイト
