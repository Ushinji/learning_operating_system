; --------------------------------------
; void read_lba(drive, lba, sect, dst);
; LBAでのセクタ読み出しを行う。内部的には、LBA->CHS方式へ変換している
;  - LBA: セクタ位置に通し番号をつけることで、位置を特定する方法
;  - CHS: シリンダ、ヘッド、セクタによって、位置を特定する方法
;
; @return         : 読み込んだセクタ数
; @param  drive   : drive構造体アドレス(ドライブパラメタ)
; @param  lba     : LBA
; @param  sect    : 読み出しセクタ数
; @param  dst     : 読み出し先アドレス
; --------------------------------------

; ****************
; レジスタ位置関係
; ***************
;   + 10 | dst
;   + 8  | sect
;   + 6  | lba
;   + 4  | drive
;   + 2  | 戻り番地
; BP+ 0  | BP
; -----------------

read_lba:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push si
    
    ; LBA -> CHS変換
    mov si, [bp + 4] ; ドライブ情報
    mov ax, [bp + 6] ; LBA
    cdecl lba_chs, si, .chs, ax

    ; ドライブ番号コピー
    mov al, [si + drive.no]
    mov [.chs + drive.no], al

    ; セクタ読み出し
    ; AX = read_chs(.chs, セクタ数, 読み出し先アドレス)
    cdecl read_chs, .chs, word[bp + 8], word[bp + 10]

    ; レジスタの復帰
    pop si

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret

ALIGN 2
.chs: times drive_size db 0
