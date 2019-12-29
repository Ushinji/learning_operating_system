; ******************************
; void itos(num, buff, size, radix, flag);
; (Int TO Ascii)
; -----------------
; num   : 変換対象の数値
; buff  : 保存先のバッファアドレス
; size  : 保存先のバッファサイズ
; radix : 基数(2, 8, 10, 16のいずれか)
; flag  : ビット定義フラグ
;         B2: 空白を'0'で埋める
;         B1: '+/-'符号を追加
;         B0: 値を符号付変数として扱う
; -----------------
; ******************************

; // ****************
; // レジスタ位置関係
; // ****************
;   + 12 | flag
;   + 10 | radix
;   + 8  | size
;   + 6  | buff
;   + 4  | num
;   + 2  | 戻り番地
; BP+ 0  | BP

itoa:
        ; スタックフレームの構築
        push    bp
        mov     bp, sp

        ; レジスタの保存
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        ; 引数取得
        mov     ax, [bp + 4]        ; num:  変換対象の数値
        mov     si, [bp + 6]        ; buff: 変換先のバッファアドレス
        mov     cx, [bp + 8]        ; size: バッファサイズ

        mov     di, si              ; バッファの末尾を取得: di = buff[size - 1]
        add     di, cx              ; di = buff + size
        dec     di                  ; di = di - 1
        
        mov     bx, word [bp + 12]  ; flag: 変換オプション


        ; ------------------
        ; 符号付き判定
        ; ------------------
        test    bx, 0b0001  ; test <1>, <2>: 与えられた２つの値の論理積を行い、結果が0であればゼロフラグ(ZF)を立てる
.10Q:   je      .10E        ; je: ゼロフラグ(ZF)をチェックして、フラグが立っていれば指定ラベルへ移動する
        cmp     ax, 0       ; 対象データ(ax=val)が負の値の場合、符号出力を行うフラグ(bx)をオンにする
        jge     .12E
        or      bx, 0b0010  ;  bx |= 2. OR演算のためB2位置が1となる(0x0000 | 0x0010 = 0x0010)
.12E:
.10E:

        ; ------------------
        ; 符号出力判定
        ; ------------------
        test    bx, 0b0010      ; if(flag == 0x0010) {
.20Q:   je      .20E            ; 
        cmp     ax, 0           ;   if(num < 0) {
        jge     .22F            ;

        ; 負の値の場合            ;
        neg     ax              ; NEG(2の補数)命令によって、符号を反転: num *= -1
        mov     [si], byte '-'  ; 変換先のバッファアドレス(si)の先頭に'-'を付与: *buff += '-'
        jmp     .22E            ;

        ; 正の値の場合
.22F:   mov     [si], byte '+'  ; 変換先のバッファアドレス(si)の先頭に'+'を付与: *buff += '-'
        jmp     .22E
.22E:   dec     cx              ; 符号を付与した分、残りのバッファサイズ(cx=size)を減算
.20E:

        ; ------------------
        ; Ascii変換
        ; ------------------
        mov     bx, [bp + 10]           ; BX = 基数を取得
.30L:
        mov     dx, 0                   ; 割り算の余りはdxに代入される。なので、事前に0初期化している。
        div     bx                      ; 基数(bx)で割り算(div)を行う

        mov     si, dx
        mov     dl, byte [.ascii + si]  ; 割り算の余りから、Asciiテーブルを参照

        mov     [di], dl                ; di(変換後のバッファアドレスの末尾)にAscii文字を設定
        dec     di                      ; 末尾の１つ前が次のAscii文字設定先であるため、減算(dec)する

        ; 割り算対象の値は暗黙的にax(変換対象の数値)が使用される
        ; loopnz命令により、残りのバッファサイズ(cx)か変換対象(az)が0になるまで、ループを繰り返す
        cmp     ax, 0
        loopnz  .30L
.30E:

        ; ------------------
        ; 空欄を埋める
        ; ------------------
        cmp     cx, 0                   ; バッファサイズ(cx)が残っている場合に、空欄埋めを行う
.40Q:   je      .40E
        mov     al, ' '
        cmp     [bp + 12], word 0b0100
.42Q:   jne     .42E
        mov     al, '0'
.42E:
        std                             ; DF=0をセット
        rep stosb                       ; rep命令を置くことで、cxレジスタが0になるまで、後続のstosb命令を繰り返す。その際、stosb命令実行後にcxレジスタの減算を行う。
.40E:

    ; レジスタの復帰
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ; スタックフレームの破棄
    mov sp, bp
    pop bp

    ret

.ascii  db      "0123456789ABCDEF" ;変換デーブル