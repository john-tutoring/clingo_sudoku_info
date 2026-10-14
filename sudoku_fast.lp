#const n = 9.
#const sqrtn = 3.
v(1..n).
box(X, Y, (X-1)/sqrtn*sqrtn + (Y-1)/sqrtn) :- v(X), v(Y).

% One number per cell (givens arrive as in(X,Y,N) facts and fix their cell)
{ in(X, Y, N) : v(N) } = 1 :- v(X), v(Y).

% Each number once per row, column and box: one aggregate per group, not pairwise
:- v(X), v(N), #count{ Y : in(X, Y, N) } != 1.
:- v(Y), v(N), #count{ X : in(X, Y, N) } != 1.
:- box(_, _, B), v(N), #count{ X, Y : in(X, Y, N), box(X, Y, B) } != 1.
