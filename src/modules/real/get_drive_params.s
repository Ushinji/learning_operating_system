; --------------------------------------
; int get_drive_params(drive, no);
; @params drive :drive構造体のアドレス
; @params no    :対象となるドライブ番号
; @return       :成功(0以外) or 失敗(0)
; --------------------------------------

; ****************
; レジスタ位置関係
; ***************
;   + 6 | no
;   + 4 | drive
;   + 2 | 戻り番地
; BP+ 0 | BP
; -----------------

get_drive_params:
        ; スタックフレームの構築
        push    bp
        mov     bp, sp

        ; レジスタの保存
        push    bx
        push    cx
        push    es
        push    si
        push    di

        ; 処理の開始
        mov     si, [bp + 4]        ; drive: drive構造体のアドレス
        mov     ax, 0
        mov     es, ax              ; ES=0
        mov     di, ax              ; DI=0

        ; ドライブパラメタを読み込む: BIOS(0x13, 0x08)
        ;  - 0x13: Disk Services           : FDD、HDD、ROMディスク、RFDディスクなどにアクセスする
        ;  - 0x08: Read Drive Parameters   : ドライブパラメータを読み込み
        ;    (Ref: http://softwaretechnique.jp/OS_Development/Tips/Bios_Services/disk_services.html)
        ;  - 取得したドライブパラメタは、CH, CL, DH, DLレジスタに設定される。
        mov     ah, 8
        mov     dl, [si + drive.no] ; DL = ドライブ番号
        int     0x13                ; BIOS(0x13, AH=0x08)
.10Q:   jc      .10F
.10T:
        ; セクタ数(AX)を取得
        ; - セクタ数はCLの下位6ビットに割り当てられている(上位2ビットはシリンダ数が割り当てられている)
        ; - ALはAXの下位８ビットであるため、ALに代入してもAXで使用できる
        ; - セクタ数の取得は、ALと0x3FのAND演算による下位6ビット抽出によって行う
        mov     al, cl
        and     ax, 0x3F

        ; シリンダ数の取得
        ; - 読み込んだシリンダはCHとCLの上位2ビットに割り当てられている(以下の括弧で囲われているビットが対象)
        ;   CH                           CL
        ;   [(7),(6),(5),(4),(3),(2),(1)][(*7),(*6),5,4,3,2,1]
        ;
        ; - シリンダ取得では、上のCH,CL内のデータを以下の並びにする
        ;   [(*7),(*6),(7),(6),(5),(4),(3),(2),(1)]
        shr     cl, 6               ; CLを6ビット分の右シフト
        ror     cx, 8               ; CX(CH+CL)を8ビット分の右回転
        inc     cx                  ; シリンダ数は0始まりであるため、1加算する

        ; ヘッド数の取得
        ; - ヘッド数は、DHに割り当てられている
        movzx   bx, dh              ; movzx命令で上位1バイト追加して取得する
        inc     bx                  ; ヘッド数は0始まりであるため、1加算する

        ; 取得したドライブパラメタを、引数のdrive構造体に設定
        mov [si + drive.cyln], cx
        mov [si + drive.head], bx
        mov [si + drive.sect], ax

        jmp .10E
.10F:
        ; 読み込み失敗した場合、戻り値を0(=失敗)に設定
        mov     ax, 0
.10E:
        ; レジスタの復帰
        pop di
        pop si
        pop es
        pop cx
        pop bx

        ; スタックフレームの破棄
        mov sp, bp
        pop bp

        ret
