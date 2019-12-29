; %macro <マクロ名> <引数の数>
; 1-*: 1つ以上の引数が指定されることを示す
; .nolist: マクロのリスト出力を抑止
%macro  cdecl 1-*.nolist

    ; -------------------------------------------------
    ; 引数リストから、呼び出し関数の引数を末尾から順にpushする
    ; -------------------------------------------------
    ; %rep <number>: %rep -> %endrepの間を指定回数分ループする
    ; %0 - 1: 呼び出し関数への引数の数(%0は引数の数を表す。引数の数から、呼び出し関数そのものを数から引くと呼び出し関数への引数の数となる)
    %rep    %0 - 1
        ; 引数リストの末尾の値をpushする
        ; %{-1:-1}: 引数リストの末尾を表す
        push    %{-1:-1}

        ; %rotate: 引数リストを指定した数だけずらす
        ; 今回は末尾から引数をpushしたいので、負の数を指定し右方向へ動かす
        ; ※動作例
        ; [1, 2, 3, 4] -> (%rotate -1) -> [4, 1, 2, 3]
        %rotate -1
    %endrep

    ; 引数リストの順番を元に戻す
    %rotate - 1

    ; 関数呼び出し
    call    %1
    
    ; 引数が与えられている場合
    %if 1 < %0
        ; 呼び出し関数への引数分だけスタックの破棄(スタックポインタ(SP)の調整)
        ; __BITS__: ビットモード判定(実行環境に応じた値(16 or 32 or 64)が得られる)
        ; ビットモードを3ビット分右にシフト(1/8)すると、バイトサイズが得られる
        ; * 16ビットモード: 2バイト
        ; * 32ビットモード: 4バイト
        ; * 64ビットモード: 8バイト
        add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif

%endmacro

struc drive
    .no resw 1      ; ドライブ番号
    .cyln resw 1    ; シリンダ
    .head resw 1    ; ヘッド
    .sect resw 1    ; セクタ
endstruc
