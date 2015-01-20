:- module gs.
:- interface.
:- import_module io, store.
:- import_module sdl2.

%----------------------------------------
% グローバル状態
%----------------------------------------
:- type gs
  ---> gs(
    win :: window,
    ren :: renderer,
    scene :: io_mutvar(scene),
    next :: io_mutvar(int)
  ).

%----------------------------------------
% ゲームシーン
%----------------------------------------
:- typeclass scene(T) where [
  pred update(T::in, gs::in, io::di, io::uo) is det,
  pred draw(T::in, gs::in, io::di, io::uo) is det,
  pred mouse_move(T::in, int::in, int::in, gs::in, io::di, io::uo) is det,
  pred mouse_down(T::in, int::in, int::in, gs::in, io::di, io::uo) is det
].

:- type scene --->
  some [T] scene(T) => scene(T).

:- pred register_scene(string::in, scene::in, io::di, io::uo) is det.
:- pred switch_scene(string::in, gs::in, io::di, io::uo) is det.

:- implementation.
:- import_module string, map, require.

:- mutable(scene_map, map(string, scene), map.init, ground, [untrailed, attach_to_io_state]).

%----------------------------------------
% シーンの登録
%----------------------------------------
register_scene(Id, Scene, !IO) :-
  get_scene_map(Map, !IO),
  set_scene_map(map.set(Map, Id, Scene), !IO).

%----------------------------------------
% シーンの切り替え
%----------------------------------------
switch_scene(Id, Gs, !IO) :-
  get_scene_map(Map, !IO),
  (
    if Scene = Map^elem(Id) then
      set_mutvar(Gs^scene, Scene, !IO)
    else
      error("scene " ++ Id ++ " is not registered")
  ).

