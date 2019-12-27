; cx = 0;
; while(cx < 5) {
;    cx = cx + 1;
;}

    mov     cx, 0
Test:
.L:
    cmp     cx, 5
    jae     .E
    ADD     cx, 1
    loop    .L
.E