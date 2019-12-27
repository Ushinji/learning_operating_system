;if(ax < 3) {
;    bx = 2;
;} else {
;    bx = 1;
;}

Test:   cmp     ax, 3
        jae     .False
.True:  mov     bx, 2
        jmp     .End
.False: mov     bx, 1
.End:
