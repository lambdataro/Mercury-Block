:- module title_scene.
:- interface.
:- import_module io.
:- import_module gs.

:- type title_scene ---> title_scene.
:- instance scene(title_scene).

:- pred init_title_scene(title_scene::out) is det.
:- pred update_title(title_scene::in, gs::in, io::di, io::uo) is det.
:- pred draw_title(title_scene::in, gs::in, io::di, io::uo) is det.
:- pred mouse_move_title(title_scene::in, int::in, int::in, gs::in, io::di, io::uo) is det.
:- pred mouse_down_title(title_scene::in, int::in, int::in, gs::in, io::di, io::uo) is det.

:- implementation.
:- import_module sdl2.

%----------------------------------------
% タイトルシーン
%----------------------------------------
init_title_scene(title_scene).

%----------------------------------------
% インスタンス宣言
%----------------------------------------
:- instance scene(title_scene) where [
  pred(update/4) is update_title,
  pred(draw/4) is draw_title,
  pred(mouse_move/6) is mouse_move_title,
  pred(mouse_down/6) is mouse_down_title
].

%----------------------------------------
% タイトルの登録
%----------------------------------------
:- pred register_title(io::di, io::uo) is det.
register_title(!IO) :-
  init_title_scene(Ts),
  register_scene("title", 'new scene'(Ts), !IO).

:- initialize register_title/2.

%----------------------------------------
% タイトルの更新
%----------------------------------------
update_title(_Ts, _Gs, !IO).

%----------------------------------------
% タイトルの描画
%----------------------------------------
draw_title(_Ts, Gs, !IO) :-
  render_draw_color(Gs^ren, 255, 255, 255, 255, !IO),
  render_clear(Gs^ren, !IO).

%----------------------------------------
% タイトルでのマウスムーブ
%----------------------------------------
mouse_move_title(_Ts, _X, _Y, _Gs, !IO).

%----------------------------------------
% タイトルでのマウスダウン
%----------------------------------------
mouse_down_title(_Ts, _X, _Y, _Gs, !IO).

