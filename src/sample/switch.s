; switch(ax) {
;    case 10:
;        bx = 1;
;        break;
;    case 15:
;        bx = 2;
;        break;
;    case 20:
;        bx = 3;
;        break;
;    default:
;        bx = 4;
;        break;
;}

Test:   cmp     ax, 10
        je      .C10
        cmp     ax, 15
        je      .C15
        cmp     ax, 20
        je      .C20
        jmp     .D

.C10    mov     bx, 1
        jmp     .E
.C15    mov     bx, 2
        jmp     .E
.C20    mov     bx, 3
        jmp     .E
.D      mov     bx, 4
        jmp     .E
.E:
