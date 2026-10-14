1 { in(R,C,N) : N = 1..9 } 1 :- R = 1..9, C = 1..9.
:- in(R1,C1,N), in(R2,C2,N), (R1,C1) != (R2,C2), grp(R1,C1,G), grp(R2,C2,G).
grp(R,C, (row,R; col,C; box,(R-1)/3,(C-1)/3)) :- R = 1..9, C = 1..9.

