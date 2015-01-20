:- module geometry.
:- interface.

% 点
:- type pt ---> pt(x::float, y::float).

% 線分
:- type seg ---> seg(pt1::pt, pt2::pt).

% 直線
:- type line
  ---> line(float, float)
  ;    hline(float)
  ;    vline(float).

% 水平線分
:- type hseg ---> hseg(pt, float).

% 垂直線分
:- type vseg ---> vseg(pt, float).

% 円
:- type circle ---> circle(pt, float).

% 長方形
:- type rect ---> rect(pt, pt).

% 2次元ベクトル
:- type vec2 ---> vec2(vx::float, vy::float).

% 2点間の距離
:- func distance(pt, pt) = float.

% 2点を通る直線
:- pred to_line(pt::in, pt::in, line::out) is det.

% 浮動小数点数を整数に変換
:- func int(float) = int.

% 範囲内に含まれているかどうか
:- pred range(float::in, float::in, float::in) is semidet.

% 値を範囲内にクリップ
:- func clip(float, float, float) = float.

% 直線上の座標(Y)
:- pred calc_y(line::in, float::in, float::out) is semidet.

% 直線上の座標(X)
:- pred calc_x(line::in, float::out, float::in) is semidet.

% 線分と線分(水平)の交点計算
:- pred cross_hseg(seg::in, hseg::in, float::out) is semidet.

% 線分と線分(垂直)の交点計算
:- pred cross_vseg(seg::in, vseg::in, float::out) is semidet.

% 2次方程式を解く
:- pred equation(float::in, float::in, float::in, float::out) is nondet.

% 線分と円の交点計算
:- pred cross_circle(seg::in, circle::in, pt::out) is semidet.

% 長方形に円が突入するときの交点と反射用の法線
:- pred cross_rect(seg::in, rect::in, float::in, pt::out, vec2::out) is semidet.

:- implementation.
:- import_module float, math.
:- import_module list, solutions.

%----------------------------------------
% 2点間の距離
%----------------------------------------
distance(Pt1, Pt2) = Result :-
  Result =
    sqrt(pow(Pt2^x - Pt1^x, 2) +
    pow(Pt2^y - Pt1^y, 2)).

%----------------------------------------
% 浮動小数点数を整数に変換
%----------------------------------------
int(F) = floor_to_int(F).

%----------------------------------------
% 2点を通る直線
%----------------------------------------
to_line(Pt1, Pt2, Line) :-
  if Pt1^x = Pt2^x then
    Line = vline(Pt1^x)
  else if Pt1^y = Pt2^y then
    Line = hline(Pt1^y)
  else
    A = (Pt2^y - Pt1^y) / (Pt2^x - Pt1^x),
    B = Pt1^y - A * Pt1^x,
    Line = line(A, B).
    
%----------------------------------------
% 範囲内に含まれているかどうか
%----------------------------------------
range(X, Y, V) :-
  min(X, Y) =< V,
  max(X, Y) >= V.

%----------------------------------------
% 値を範囲内にクリップ
%----------------------------------------
clip(V1, V2, V) = R :-
  if min(V1, V2) > V then
    R = min(V1, V2)
  else if max(V1, V2) < V then
    R = max(V1, V2)
  else
    R = V.

%----------------------------------------
% 直線上の座標(Y)
%----------------------------------------
calc_y(line(A, B), X, Y) :-
  Y = A * X + B.
calc_y(hline(Y), _, Y).
calc_y(vline(X), X, 0.0).

%----------------------------------------
% 直線上の座標(X)
%----------------------------------------
calc_x(line(A, B), X, Y) :-
  X = (Y - B) / A.
calc_x(hline(Y), 0.0, Y).
calc_x(vline(X), X, _).

%----------------------------------------
% 線分と線分(水平)の交点計算
%----------------------------------------
cross_hseg(seg(Pt1, Pt2), hseg(Pt3, X4), X) :-
  to_line(Pt1, Pt2, Line),
  (
    Line = vline(X),
    range(Pt3^x, X4, X),
    range(Pt1^y, Pt2^y, Pt3^y)
  ;
    Line = hline(Pt3^y),
    (
      if range(Pt3^x, X4, Pt1^x) then
        X = Pt1^x
      else
        (
          range(Pt3^x, X4, Pt2^x)
        ;
          min(Pt3^x, X4) >= min(Pt1^x, Pt2^x),
          min(Pt3^x, X4) =< max(Pt1^x, Pt2^x)
        ),
        (
          if Pt1^x < Pt2^x then
            X = min(Pt3^x, X4)
          else
            X = max(Pt3^x, X4)
        )
    )
  ;
    Line = line(_, _),
    calc_x(Line, X, Pt3^y),
    range(Pt3^x, X4, X),
    range(Pt1^y, Pt2^y, Pt3^y)
  ).

%----------------------------------------
% 線分と線分(垂直)の交点計算
%----------------------------------------
cross_vseg(seg(Pt1, Pt2), vseg(Pt3, Y4), Y) :-
  to_line(Pt1, Pt2, Line),
  (
    Line = vline(Pt3^x),
    (
      if range(Pt3^y, Y4, Pt1^y) then
        Y = Pt1^y
      else
        (
          range(Pt3^y, Y4, Pt2^y)
        ;
          min(Pt3^y, Y4) >= min(Pt1^y, Pt2^y),
          max(Pt3^y, Y4) =< max(Pt1^y, Pt2^y)
        ),
        (
          if Pt1^y < Pt2^y then
            Y = min(Pt3^y, Y4)
          else
            Y = max(Pt3^y, Y4)
        )
    )
  ;
    Line = hline(Y),
    range(Pt3^y, Y4, Y),
    range(Pt1^x, Pt2^x, Pt3^x)
  ;
    Line = line(_, _),
    calc_y(Line, Pt3^x, Y),
    range(Pt3^y, Y4, Y),
    range(Pt1^x, Pt2^x, Pt3^x)
  ).

% 2次方程式を解く
equation(A, B, C, X) :-
  D = B * B - 4.0 * A * C,
  (
    if D > 0.0 then
      ( 
        X = (-B + sqrt(D)) / (2.0 * A)
      ;
        X = (-B - sqrt(D)) / (2.0 * A)
      )
    else
      D = 0.0,
      X = -B / (2.0 * A)
  ).

%----------------------------------------
% 線分と円の交点計算
%----------------------------------------
cross_circle(seg(Pt1, Pt2), circle(Pt3, R), pt(X, Y)) :-
  to_line(Pt1, Pt2, Line),
  (
    Line = vline(Pt1^x),
    X = Pt1^x,
    CA = 1.0,
    CB = -2.0 * Pt3^y,
    CC = pow(Pt3^y, 2) + pow(X - Pt3^x, 2) - pow(R, 2),
    solutions((pred(YY::out) is nondet :-
      equation(CA, CB, CC, YY),
      range(Pt1^y, Pt2^y, YY)), Ys),
    (
      if Ys = [Y1, Y2] then
        (
          if distance(Pt1, pt(X, Y1)) <
             distance(Pt1, pt(X, Y2)) then
            Y = Y1
          else
            Y = Y2
        )
      else
        Ys = [Y]
    )   
  ;
    (
      Line = line(A, B)
    ;
      Line = hline(YY),
      A = 0.0, B = YY
    ),
    CA = A * A + 1.0,
    CB = 2.0 * (A * B - A * Pt3^y - Pt3^x),
    CC = pow(Pt3^x, 2) + pow(B - Pt3^y, 2) - pow(R, 2),
    solutions((pred({XX,YY}::out) is nondet :-
      equation(CA, CB, CC, XX),
      range(Pt1^x, Pt2^x, XX),
      calc_y(Line, XX, YY),
      range(Pt1^y, Pt2^y, YY)), Pts),
    (
      if Pts = [{X1,Y1}, {X2,Y2}] then
        (
          if distance(Pt1, pt(X1,Y1)) <
             distance(Pt1, pt(X2,Y2)) then
            X = X1, Y = Y1
          else 
            X = X2, Y = Y2
        )
      else
        Pts = [{X, Y}]
    )
  ).

%----------------------------------------
% 長方形に円が突入するときの交点と反射用の法線
%----------------------------------------
:- pred cross_rect_sub(seg::in, rect::in, float::in, {pt,vec2}::out) is nondet.
cross_rect_sub(Seg, rect(Pt1, Pt2), R, {pt(X, Y), vec2(Nx, Ny)}) :-
(
    cross_hseg(Seg,
      hseg(pt(Pt1^x, Pt1^y - R), Pt2^x), X),
    Y = Pt1^y - R, Nx = 0.0, Ny = -1.0
  ;
    cross_hseg(Seg,
      hseg(pt(Pt1^x, Pt2^y + R), Pt2^x), X),
    Y = Pt2^y + R, Nx = 0.0, Ny = 1.0
  ;
    cross_vseg(Seg,
      vseg(pt(Pt1^x - R, Pt1^y), Pt2^y), Y),
    X = Pt1^x - R, Nx = -1.0, Ny = 0.0
  ;
    cross_vseg(Seg,
      vseg(pt(Pt2^x + R, Pt1^y), Pt2^y), Y),
    X = Pt2^x + R, Nx = 1.0, Ny = 0.0
  ;
    cross_circle(Seg,
      circle(pt(Pt1^x, Pt1^y), R), pt(X, Y)),
    Rad = atan2(Y - Pt1^y, X - Pt1^x),
    Nx = cos(Rad), Ny = sin(Rad)
  ;
    cross_circle(Seg,
      circle(pt(Pt2^x, Pt1^y), R), pt(X, Y)),
    Rad = atan2(Y - Pt1^y, X - Pt2^x),
    Nx = cos(Rad), Ny = sin(Rad)
  ;
    cross_circle(Seg,
      circle(pt(Pt1^x, Pt2^y), R), pt(X, Y)),
    Rad = atan2(Y - Pt2^y, X - Pt1^x),
    Nx = cos(Rad), Ny = sin(Rad)
  ;
    cross_circle(Seg,
      circle(pt(Pt2^x, Pt2^y), R), pt(X, Y)),
    Rad = atan2(Y - Pt2^y, X - Pt2^x),
    Nx = cos(Rad), Ny = sin(Rad)
  ).

cross_rect(Seg @ seg(Pt3, _), Rect, R, pt(X, Y), vec2(Nx, Ny)) :-
  solutions(cross_rect_sub(Seg, Rect, R), List),
  foldl((pred({Pt,N}::in,
              {Len0,Pt0,N0}::in,
              {LenOut,PtOut,NOut}::out) is det :-
      Len = distance(Pt3, Pt),
      (
        if Len < Len0 then
          LenOut = Len, PtOut = Pt, NOut = N
        else
          LenOut = Len0, PtOut = Pt0, NOut = N0
      )
    ),
    List,
    {float.max, pt(0.0, 0.0), vec2(0.0, 0.0)},
    {L, pt(X, Y), vec2(Nx, Ny)}),
  L \= float.max.

