; --------------------------------------
; void lba_chs(drive, drv_chs, lba);
; セクタ指定について、LBA方式からCHS方式へ変換する関数
;  - LBA: セクタ位置に通し番号をつけることで、位置を特定する方法
;  - CHS: シリンダ、ヘッド、セクタによって、位置を特定する方法
;
; @return         : 成功(0以外), 失敗(0)
; @param  drive   : Drive構造体のアドレス(Driveパラメタ)
; @param  drv_chs : Drive構造体のアドレス(変更後のシリンダ番号、ヘッド番号、セクタ番号を保存)
; @param  lba     : LBA
; --------------------------------------

; ****************
; レジスタ位置関係
; ***************
;   + 8 | lba
;   + 6 | drv_chs
;   + 4 | drive
;   + 2 | 戻り番地
; BP+ 0 | BP
; -----------------

lba_chs:
    ; スタックフレームの構築
    push bp
    mov bp, sp

    ; レジスタの保存
    push ax
    push bx
    push dx
    push si
    push di
    
    ; シリンダあたりのセクタ数を計算
    mov al, [si + drive.head]   ; AL: 最大ヘッド数
    mul byte, [si + drive.sect] ; AX: 最大ヘッド数(AL)×最大セクタ数
    mov bx, ax                  ; BX: シリンダあたりのセクタ数

    ; 指定されたLBAのシリンダ番号を計算
    mov dx, 0                   ; DX = LBA(上位2バイト)
    mov ax, [bp + 8]            ; AX = LBA(下位2バイト)
    div bx                      ; DX = DX~AX % BX(余り)
                                ; AX = DX~AX / BX(割り算結果) = シリンダ番号
    mov [di + drive.cyln], ax   ; シリンダ番号をdrive構造体へ保存

    ; セクタ番号とヘッド番号を計算
    mov ax, dx                  ; AX = BX(余り)
    div byte [si + drive.sect]  ; AH = AX % 最大セクタ数(余り) = セクタ番号 
                                ; AL = AX / 最大セクタ数(割り算結果) = ヘッド番号
    
    ; セクタ番号の保存
    movzx dx, ah                ; セクタ番号を2バイト拡張してDXへ保存
    inc dx                      ; セクタ番号は1始まりなので+1
    mov [di + drive.sect], dx

    ; ヘッド番号の保存
    mov ah, 0x00                ; AHを0指定し、AX(AH+AL)で2バイトのヘッド番号データとして扱う
    mov [di + drive.head], ax

    ; レジスタの復帰
    pop di
    pop si
    pop dx
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret
