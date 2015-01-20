:- module block.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module int, float, math.
:- import_module store.
:- import_module geometry, gs, title_scene, sdl2.

%----------------------------------------
% パラメータ
%----------------------------------------
:- func title = string. title = "Mercury BLOCK".
:- func win_w = float. win_w = 640.0.
:- func win_h = float. win_h = 480.0.
:- func speed = int. speed = 16.

%----------------------------------------
% エントリーポイント
%----------------------------------------
main(!IO) :-
  init_game(Gs, !IO),
  event_loop(Gs, !IO),
  quit_game(Gs, !IO).

%----------------------------------------
% 初期化処理
%----------------------------------------
:- pred init_game(gs::out, io::di, io::uo) is det.
init_game(Gs, !IO) :-
  sdl2.init(!IO),
  create_window(title, int(win_w), int(win_h), Win, !IO),
  create_renderer(Win, Ren, !IO),
  %
  init_title_scene(Ts),
  new_mutvar('new scene'(Ts), SceneVar, !IO),
  %
  get_ticks(Ticks, !IO),
  new_mutvar(Ticks, TicksVar, !IO),
  % 
  Gs = gs(
    Win, Ren, SceneVar, TicksVar
  ).

%----------------------------------------
% 解放処理
%----------------------------------------
:- pred quit_game(gs::in, io::di, io::uo) is det.
quit_game(Gs, !IO) :-
  destroy_renderer(Gs^ren, !IO),
  destroy_window(Gs^win, !IO),
  sdl2.quit(!IO).

%----------------------------------------
% イベントループ
%----------------------------------------
:- pred event_loop(gs::in, io::di, io::uo) is det.
event_loop(Gs, !IO) :-
  poll(Event, !IO),
  (
    if Event = quit_event then
      true
    else if Event = mouse_down_event(left_button, X, Y) then
      get_mutvar(Gs^scene, scene(V), !IO),
      mouse_down(V, X, Y, Gs, !IO),
      event_loop(Gs, !IO)
    else if Event = mouse_move_event(X, Y) then
      get_mutvar(Gs^scene, scene(V), !IO),
      mouse_move(V, X, Y, Gs, !IO),
      event_loop(Gs, !IO)
    else
      get_ticks(Ticks, !IO),
      get_mutvar(Gs^next, Next, !IO),
      (
        if Ticks > Next then
          set_mutvar(Gs^next, Next + speed, !IO),
          get_mutvar(Gs^scene, scene(V), !IO),
          update(V, Gs, !IO),
          draw(V, Gs, !IO),
          render_present(Gs^ren, !IO),
          event_loop(Gs, !IO)
        else
          event_loop(Gs, !IO)
      )
  ).

