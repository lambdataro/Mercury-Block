:- module main.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int, integer, float, math.
:- import_module bool, string.
:- import_module list, solutions.
:- import_module map, assoc_list, pair.
:- import_module store, lexer, require.
:- import_module sdl, geometry.

%----------------------------------------
% パラメータ
%----------------------------------------
:- func win_w = float. win_w = 640.0.
:- func win_h = float. win_h = 480.0.
:- func speed = int. speed = 16.

:- func font_name = string. font_name = "mplus-1p-heavy.ttf".

:- func title_color = color. title_color = rgb(0, 0, 64).
:- func start_color = color. start_color = rgb(128, 0, 0).
:- func title_bg_color = color. title_bg_color = rgb(192, 192, 192).
:- func game_bg_color = color. game_bg_color = rgb(192, 192, 192).
:- func clear_color = color. clear_color = rgb(128, 0, 0).
:- func gameover_color = color. gameover_color = rgb(128, 0, 0).
:- func header_color = color. header_color = rgb(255, 255, 255).

:- func frame_color1 = color. frame_color1 = rgb(64, 64, 64).
:- func frame_color2 = color. frame_color2 = rgb(128, 128, 128).
:- func frame_color3 = color. frame_color3 = rgb(32, 32, 32).
:- func ball_color1 = color. ball_color1 = rgb(255, 255, 255).
:- func ball_color2 = color. ball_color2 = rgb(0, 0, 0).

:- func blue1 = color. blue1 = rgb(128, 128, 255).
:- func blue2 = color. blue2 = rgb(192, 192, 255).
:- func blue3 = color. blue3 = rgb(0, 0, 255).
:- func red1 = color. red1 = rgb(255, 128, 128).
:- func red2 = color. red2 = rgb(255, 192, 192).
:- func red3 = color. red3 = rgb(255, 0, 0).
:- func green1 = color. green1 = rgb(128, 255, 128).
:- func green2 = color. green2 = rgb(192, 255, 192).
:- func green3 = color. green3 = rgb(0, 255, 0).

:- func frame_size1 = float. frame_size1 = 32.0.
:- func frame_size2 = float. frame_size2 = 48.0.
:- func block_w = float. block_w = 64.0.
:- func block_h = float. block_h = 32.0.
:- func bar_init_w = float. bar_init_w = 64.0.
:- func bar_y = float. bar_y = frame_size2 + block_h * 12.0.
:- func bar_h = float. bar_h = 10.0.
:- func ball_init_sp = float. ball_init_sp = 5.0.
:- func ball_eps = float. ball_eps = 0.1.
:- func ball_r = float. ball_r = 5.0.
:- func ball_draw_r = float. ball_draw_r = ball_r - 1.0.
:- func init_life = int. init_life = 3.
:- func num_stage = int. num_stage = 3.

%----------------------------------------
% エントリーポイント
%----------------------------------------
main(!IO) :-
  sdl.init(int(win_w), int(win_h), Scr, !IO),
  init_gs(Scr, Gs, !IO),
  loop(Gs, !IO).

%----------------------------------------
% グローバル状態(GS)
%----------------------------------------
:- type gs
  ---> gs(
    scr :: surface,
    next :: io_mutvar(int),
    scene :: io_mutvar(handler),
    res :: resource,
    score :: int,
    life :: io_mutvar(int),
    life_val_surf :: io_mutvar(surface),
    buffer :: surface
  ).

%----------------------------------------
% グローバル状態の初期化
%----------------------------------------
:- pred init_gs(surface::in, gs::out, io::di, io::uo) is det.
init_gs(Scr, Gs, !IO) :-
  sdl.get_ticks(Ticks, !IO),
  sdl.window_title("Mercury BLOCK", !IO),
  new_mutvar(Ticks, TicksVar, !IO),
  init_title_scene(Ts),
  new_mutvar('new handler'(Ts), SceneVar, !IO),
  init_resource(Res, !IO),
  new_mutvar(init_life, LifeVar, !IO),
  sdl.render_string(Res^font2,
    format("%02d", [i(init_life)]), header_color, LifeVarSurf, !IO),
  new_mutvar(LifeVarSurf, LifeVarSurfVar, !IO),
  sdl.create_surface(int(win_w), int(win_h), Buffer, !IO),
  Gs = gs(
    Scr, TicksVar, SceneVar, Res,
    0, LifeVar, LifeVarSurfVar, Buffer
  ).

%----------------------------------------
% イベントハンドラ
%----------------------------------------
:- typeclass handler(T) where [
  pred update(T::in, gs::in, io::di, io::uo) is det,
  pred draw(T::in, gs::in, io::di, io::uo) is det,
  pred mouse_move(T::in, int::in, int::in, gs::in, io::di, io::uo) is det,
  pred mouse_down(T::in, int::in, int::in, gs::in, io::di, io::uo) is det
].

:- type handler --->
  some [T] handler(T) => handler(T).

%----------------------------------------
% イベントループ
%----------------------------------------
:- pred loop(gs::in, io::di, io::uo) is det.
loop(Gs, !IO) :-
  sdl.poll(Event, !IO),
  (
    if Event = quit_event then
      true
    else if Event = mouse_down_event(left_button, X, Y) then
      get_mutvar(Gs^scene, handler(V), !IO),
      mouse_down(V, X, Y, Gs, !IO),
      loop(Gs, !IO)
    else if Event = mouse_move_event(X, Y) then
      get_mutvar(Gs^scene, handler(V), !IO),
      mouse_move(V, X, Y, Gs, !IO),
      loop(Gs, !IO)
    else
      sdl.get_ticks(Ticks, !IO),
      get_mutvar(Gs^next, Next, !IO),
      (
        if Ticks > Next then
          set_mutvar(Gs^next, Next + speed, !IO),
          get_mutvar(Gs^scene, handler(V), !IO),
          update(V, Gs, !IO),
          draw(V, Gs, !IO),
          loop(Gs, !IO)
        else
          delay(1, !IO),
          loop(Gs, !IO)
      )
  ).

%----------------------------------------
% リソース
%----------------------------------------
:- type resource
  ---> resource(
    font1 :: font,
    font2 :: font,
    title_surf :: surface,
    title_width :: int,
    title_height :: int,
    start_surf :: surface,
    start_width :: int,
    start_height :: int,
    clear_surf :: surface,
    clear_width :: int,
    clear_height :: int,
    gameover_surf :: surface,
    gameover_width :: int,
    gameover_height :: int,
    score_surf :: surface,
    score_width :: int,
    score_height :: int,
    stage_surf :: surface,
    stage_width :: int,
    stage_height :: int,
    life_surf :: surface,
    life_width :: int,
    life_height :: int
  ).

%----------------------------------------
% リソースの初期化
%----------------------------------------
:- pred init_resource(resource::out, io::di, io::uo) is det.
init_resource(Res, !IO) :-
  % フォント
  sdl.load_font(font_name, 64, Font1, !IO),
  sdl.load_font(font_name, 32, Font2, !IO),
  % タイトル文字
  sdl.render_string(Font1, "Mercury BLOCK", title_color, TitleSurf, !IO),
  sdl.render_string_size(Font1, "Mercury BLOCK", TitleW, TitleH, !IO),
  sdl.render_string(Font2, "Click to start.", start_color, StartSurf, !IO),
  sdl.render_string_size(Font2, "Click to start.", StartW, StartH, !IO),
  % メッセージ
  sdl.render_string(Font1, "Congraturations!", clear_color, CongSurf, !IO),
  sdl.render_string_size(Font1, "Congraturations!", CongW, CongH, !IO),
  sdl.render_string(Font1, "GAME OVER", gameover_color, GameoverSurf, !IO),
  sdl.render_string_size(Font1, "GAME OVER", GameoverW, GameoverH, !IO),
  % スコア
  sdl.render_string(Font2, "SCORE:", header_color, ScoreSurf, !IO),
  sdl.render_string_size(Font2, "SCORE:", ScoreW, ScoreH, !IO),
  % ステージ
  sdl.render_string(Font2, "STAGE:", header_color, StageSurf, !IO),
  sdl.render_string_size(Font2, "STAGE:", StageW, StageH, !IO),
  % ライフ
  sdl.render_string(Font2, "LIFE:", header_color, LifeSurf, !IO),
  sdl.render_string_size(Font2, "LIFE:", LifeW, LifeH, !IO),
  %
  Res = resource(
    Font1, Font2,
    TitleSurf, TitleW, TitleH,
    StartSurf, StartW, StartH,
    CongSurf, CongW, CongH,
    GameoverSurf, GameoverW, GameoverH,
    ScoreSurf, ScoreW, ScoreH,
    StageSurf, StageW, StageH,
    LifeSurf, LifeW, LifeH
  ).

%----------------------------------------
% 立体的な四角形の描画
%----------------------------------------
:- pred draw_box(surface::in, pt::in, pt::in,
  color::in, color::in, color::in, io::di, io::uo) is det.
draw_box(Scr, Pt1, Pt2, C1, C2, C3, !IO) :-
   X1 = int(Pt1^x), Y1 = int(Pt1^y),
   X2 = int(Pt2^x), Y2 = int(Pt2^y),
   sdl.draw_filled_rect(Scr, xy(X1, Y1), xy(X2, Y2), C1, !IO),
   sdl.draw_line(Scr, xy(X1, Y1), xy(X2, Y1), C2, !IO),
   sdl.draw_line(Scr, xy(X1, Y1), xy(X1, Y2), C2, !IO),
   sdl.draw_line(Scr, xy(X2, Y1), xy(X2, Y2), C3, !IO),
   sdl.draw_line(Scr, xy(X1, Y2), xy(X2, Y2), C3, !IO).

%========================================
% タイトル画面
%========================================

:- type title_scene
  ---> title_scene.

%----------------------------------------
% タイトル画面の初期化
%----------------------------------------
:- pred init_title_scene(title_scene::out) is det.
init_title_scene(Ts) :-
  Ts = title_scene.

%----------------------------------------
% タイトル画面のインスタンス宣言
%----------------------------------------
:- instance handler(title_scene) where [
  pred(update/4) is update_title,
  pred(draw/4) is draw_title,
  pred(mouse_move/6) is mouse_move_title,
  pred(mouse_down/6) is mouse_down_title
].

%----------------------------------------
% タイトル画面の更新処理
%----------------------------------------
:- pred update_title(title_scene::in, gs::in, io::di, io::uo) is det.
update_title(_, _, !IO).

%----------------------------------------
% タイトル画面の描画
%----------------------------------------
:- pred draw_title(title_scene::in, gs::in, io::di, io::uo) is det.
draw_title(_, Gs, !IO) :-
  sdl.fill(Gs^scr, title_bg_color, !IO),
  Tx = (int(win_w) - Gs^res^title_width) / 2,
  sdl.blit(Gs^res^title_surf, Gs^scr, xy(Tx, 100), !IO),
  Sx = (int(win_w) - Gs^res^start_width) / 2,
  sdl.blit(Gs^res^start_surf, Gs^scr, xy(Sx, 300), !IO),
  sdl.flip(Gs^scr, !IO).

%----------------------------------------
% タイトル画面でのマウス移動
%----------------------------------------
:- pred mouse_move_title(title_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_move_title(_, _, _, _, !IO).

%----------------------------------------
% タイトル画面でのマウスクリック
%----------------------------------------
:- pred mouse_down_title(title_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_down_title(_, _, _, Gs, !IO) :-
  init_game_scene(1, Gs, Game, !IO),
  set_mutvar(Gs^scene, 'new handler'(Game), !IO).

%========================================
% ゲーム画面
%========================================
:- type game_scene
  ---> game_scene(
    count :: io_mutvar(int),
    bar_x :: io_mutvar(float),
    bar_w :: io_mutvar(float),
    balls :: io_mutvar(map(ball_id, ball)),
    blocks :: io_mutvar(map(block_id, block)),
    stage :: int,
    stage_val_surf :: surface
  ).

%----------------------------------------
% ボール
%----------------------------------------
:- type ball_id == int.

:- type ball
  ---> ball(
    ball_x :: float,
    ball_y :: float,
    ball_dx :: float,
    ball_dy :: float,
    ball_sp :: float
  ).

%----------------------------------------
% ブロック
%----------------------------------------
:- type block_id == {int, int}.

:- type block
  ---> block(
    bx1 :: float,
    by1 :: float,
    bx2 :: float,
    by2 :: float,
    bcol :: block_color
  ).

:- type block_color
  ---> bc_blue
  ;    bc_red
  ;    bc_green.

%----------------------------------------
% ゲーム状態の参照用の型
%----------------------------------------
:- type ro_game_scene 
  ---> ro_game_scene(
    ro_bar_x :: float,
    ro_bar_w :: float,
    ro_blocks :: map(block_id, block)
  ).

%----------------------------------------
% ゲーム状態の参照用の値を作る
%----------------------------------------
:- pred make_ro_game_scene(
   game_scene::in, ro_game_scene::out, io::di, io::uo) is det.
make_ro_game_scene(Game, Scene, !IO) :-
  get_mutvar(Game^bar_x, BarX, !IO),
  get_mutvar(Game^bar_w, BarW, !IO),
  get_mutvar(Game^blocks, Blocks, !IO),
  Scene = ro_game_scene(
    BarX, BarW, Blocks
  ).

%----------------------------------------
% ゲーム画面の初期化
%----------------------------------------
:- pred init_game_scene(int::in, gs::in, game_scene::out, io::di, io::uo) is det.
init_game_scene(Stage, Gs, Game, !IO) :-
  new_mutvar(0, CountVar, !IO),
  new_mutvar(win_w / 2.0, BarXVar, !IO),
  new_mutvar(bar_init_w, BarWVar, !IO),
  new_mutvar(map.init, BallsVar, !IO),
  load_block_data(Stage, Map, !IO),
  new_mutvar(Map, BlocksVar, !IO),
  sdl.render_string(Gs^res^font2, format("%02d", [i(Stage)]),
    header_color, StageValSurf, !IO),
  Game = game_scene(
    CountVar,
    BarXVar, BarWVar, BallsVar, BlocksVar,
    Stage, StageValSurf
  ).

%----------------------------------------
% ブロック配置データの読み込み
%----------------------------------------
:- pred load_block_data(int::in,
  map(block_id, block)::out, io::di, io::uo) is det.
load_block_data(Stage, Map, !IO) :-
  FileName = "stage" ++ string(Stage) ++ ".data",
  io.see(FileName, Result, !IO),
  (
    Result = ok,
    load_block_loop1(0, init, Map, !IO),
    io.seen(!IO)
  ;
    Result = error(Err),
    error(error_message(Err))
  ).

:- pred load_block_loop1(int::in, 
  map(block_id, block)::in, map(block_id, block)::out,
  io::di, io::uo) is det.
load_block_loop1(N, !Map, !IO) :-
  if N = 11 then
    true
  else
    get_token_list(List, !IO),
    load_block_loop2(N, 0, List, !Map),
    load_block_loop1(N + 1, !Map, !IO).

:- pred load_block_loop2(int::in, int::in, token_list::in,
  map(block_id, block)::in, map(block_id, block)::out) is det.
load_block_loop2(_, _, token_nil, !Map).
load_block_loop2(N, M, token_cons(Tkn, _, Rest), !Map) :-
  if Tkn = integer(_, V, _, _) then
    (
      if V \= zero then
        B = block(
          float(M) * block_w + frame_size1,
          float(N) * block_h + frame_size2,
          float(M) * block_w + frame_size1 + block_w - 1.0,
          float(N) * block_h + frame_size2 + block_h - 1.0,
          int_to_bc(det_to_int(V))),
        !:Map = det_insert(!.Map, {N, M}, B),
        load_block_loop2(N, M + 1, Rest, !Map)
      else
        load_block_loop2(N, M + 1, Rest, !Map)
    )
  else
    load_block_loop2(N, M, Rest, !Map).

:- func int_to_bc(int) = block_color.
int_to_bc(N) = BC :-
  if N = 1 then BC = bc_blue
  else if N = 2 then BC = bc_red
  else  BC = bc_green.

%----------------------------------------
% ゲーム画面のインスタンス宣言
%----------------------------------------
:- instance handler(game_scene) where [
  pred(update/4) is update_game,
  pred(draw/4) is draw_game,
  pred(mouse_move/6) is mouse_move_game,
  pred(mouse_down/6) is mouse_down_game
].

%----------------------------------------
% ゲーム画面の更新処理
%----------------------------------------
:- pred update_game(game_scene::in, gs::in, io::di, io::uo) is det.
update_game(Game, Gs, !IO) :-
  get_mutvar(Game^balls, Balls0, !IO),
  map_foldl(update_ball1(Game), Balls0, Balls1, !IO),
  foldl(update_ball2(Gs), Balls1, init, Balls),
  set_mutvar(Game^balls, Balls, !IO),
  % クリア判定
  get_mutvar(Game^blocks, Blocks, !IO),
  (
    if is_empty(Blocks) then
      (
        if Game^stage = num_stage then
          init_clear_scene(Cs),
          set_mutvar(Gs^scene, 'new handler'(Cs), !IO),
          draw_game(Game, Gs, !IO),
          sdl.blit(Gs^scr, Gs^buffer, xy(0,0), !IO)
        else
          init_game_scene(Game^stage + 1, Gs, Game2, !IO),
          set_mutvar(Gs^scene, 'new handler'(Game2), !IO),
          get_mutvar(Gs^life, L0, !IO),
          L = L0 + count(Balls),
          set_mutvar(Gs^life, L, !IO),
          sdl.render_string(Gs^res^font2,
            format("%02d", [i(L)]), header_color, NewSurf, !IO),
          get_mutvar(Gs^life_val_surf, OldSurf, !IO),
          free_surface(OldSurf, !IO),
          set_mutvar(Gs^life_val_surf, NewSurf, !IO)
      )
    else
      true
  ),
  % ゲームオーバー判定
  get_mutvar(Gs^life, Life, !IO),
  (
    if is_empty(Balls), Life =< 0 then
      init_gameover_scene(GameOver),
      set_mutvar(Gs^scene, 'new handler'(GameOver), !IO),
      draw_game(Game, Gs, !IO),
      sdl.blit(Gs^scr, Gs^buffer, xy(0,0), !IO)
    else
      true
  ).

%----------------------------------------
% ボールの移動処理
%----------------------------------------
:- pred update_ball1(game_scene::in, 
  ball_id::in, ball::in, ball::out, io::di, io::uo) is det.
update_ball1(Game, _Id, Ball0, Ball, !IO) :-
  make_ro_game_scene(Game, RoGame, !IO),
  ray_cast(RoGame,
    pt(Ball0^ball_x, Ball0^ball_y),
    vec2(Ball0^ball_dx, Ball0^ball_dy),
    Ball0^ball_sp,
    pt(NewX, NewY), vec2(NewDx, NewDy),
    DelList, !IO),
  Ball = ball(NewX, NewY, NewDx, NewDy, Ball0^ball_sp),
  get_mutvar(Game^blocks, Blocks, !IO),
  set_mutvar(Game^blocks, delete_list(Blocks, DelList), !IO).

%----------------------------------------
% 範囲外のボールを削除する処理
%----------------------------------------
:- pred update_ball2(gs::in, ball_id::in, ball::in,
  map(ball_id, ball)::in, map(ball_id, ball)::out) is det.
update_ball2(_, Id, Ball, Map0, Map) :-
  if Ball^ball_y > win_h then
    Map = Map0
  else
    Map = det_insert(Map0, Id, Ball).

%----------------------------------------
% ゲーム画面の描画
%----------------------------------------
:- pred draw_game(game_scene::in, gs::in, io::di, io::uo) is det.
draw_game(Game, Gs, !IO) :-
  sdl.fill(Gs^scr, game_bg_color, !IO),
  draw_frame(Game, Gs, !IO),
  draw_header(Game, Gs, !IO),
  draw_blocks(Game, Gs, !IO),
  draw_bar(Game, Gs, !IO),
  draw_balls(Game, Gs, !IO),
  sdl.flip(Gs^scr, !IO).

%----------------------------------------
% 枠の描画
%----------------------------------------
:- pred draw_frame(game_scene::in, gs::in, io::di, io::uo) is det.
draw_frame(_Game, Gs, !IO) :-
  draw_box(Gs^scr,
    pt(0.0, 0.0),
    pt(frame_size1 - 1.0, win_h - 1.0),
    frame_color1, frame_color2, frame_color3, !IO),
  draw_box(Gs^scr,
    pt(win_w - frame_size1, 0.0),
    pt(win_w - 1.0, win_h - 1.0),
    frame_color1, frame_color2, frame_color3, !IO),
  draw_box(Gs^scr,
    pt(0.0, 0.0),
    pt(win_w - 1.0, frame_size2 - 1.0),
    frame_color1, frame_color2, frame_color3, !IO).

%----------------------------------------
% ヘッダの描画
%----------------------------------------
:- pred draw_header(game_scene::in, gs::in, io::di, io::uo) is det.
draw_header(Game, Gs, !IO) :-
  sdl.blit(Gs^res^stage_surf, Gs^scr, xy(150, 0), !IO),
  X1 = 150 + Gs^res^stage_width + 10,
  sdl.blit(Game^stage_val_surf, Gs^scr, xy(X1, 0), !IO),
  X2 = X1 + 70,
  sdl.blit(Gs^res^life_surf, Gs^scr, xy(X2, 0), !IO),
  X3 = X2 + Gs^res^life_width + 15,
  get_mutvar(Gs^life_val_surf, LifeVarSurf, !IO),
  sdl.blit(LifeVarSurf, Gs^scr, xy(X3, 0), !IO).
  % sdl.blit(Gs^res^score_surf, Gs^scr, xy(360, 0), !IO).

%----------------------------------------
% ブロックの描画
%----------------------------------------
:- pred draw_blocks(game_scene::in, gs::in, io::di, io::uo) is det.
draw_blocks(Game, Gs, !IO) :-
  get_mutvar(Game^blocks, Blocks, !IO),
  map.foldl_values((pred(B::in, IO0::di, IO::uo) is det :-
    (
      B^bcol = bc_blue,
      C1 = blue1, C2 = blue2, C3 = blue3
    ;
      B^bcol = bc_red,
      C1 = red1, C2 = red2, C3 = red3
    ;
      B^bcol = bc_green,
      C1 = green1, C2 = green2, C3 = green3
    ),
    draw_box(Gs^scr,
      pt(B^bx1, B^by1), pt(B^bx2, B^by2),
      C1, C2, C3, IO0, IO)), Blocks, !IO).

%----------------------------------------
% バーの描画
%----------------------------------------
:- pred draw_bar(game_scene::in, gs::in, io::di, io::uo) is det.
draw_bar(Game, Gs, !IO) :-
  get_mutvar(Game^bar_x, BarX, !IO),
  get_mutvar(Game^bar_w, BarW, !IO),
  draw_box(Gs^scr,
    pt(BarX - BarW / 2.0, bar_y),
    pt(BarX + BarW / 2.0, bar_y + bar_h - 1.0),
    frame_color1, frame_color2, frame_color3, !IO).

%----------------------------------------
% ボールの描画
%----------------------------------------
:- pred draw_balls(game_scene::in, gs::in, io::di, io::uo) is det.
draw_balls(Game, Gs, !IO) :-
  get_mutvar(Game^balls, Balls, !IO),
  foldl_values((pred(Ball::in, IO0::di, IO::uo) is det :-
    draw_filled_circle(Gs^scr,
      xy(int(Ball^ball_x), int(Ball^ball_y)), int(ball_draw_r),
      ball_color1, IO0, IO1),    
    draw_circle(Gs^scr,
      xy(int(Ball^ball_x), int(Ball^ball_y)), int(ball_draw_r),
      ball_color2, IO1, IO)), Balls, !IO).

%----------------------------------------
% ゲーム画面でのマウス移動
%----------------------------------------
:- pred mouse_move_game(game_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_move_game(Game, X, _, _, !IO) :-
  get_mutvar(Game^bar_w, BarW, !IO),
  Fx = clip(
    frame_size1 + BarW / 2.0,
    win_w - frame_size1 - BarW / 2.0 - 1.0, float(X)),
  set_mutvar(Game^bar_x, Fx, !IO).

%----------------------------------------
% ゲーム画面でのマウスクリック
%----------------------------------------
:- pred mouse_down_game(game_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_down_game(Game, _, _, Gs, !IO) :-
  get_mutvar(Gs^life, Life0, !IO),
  (
    if Life0 > 0 then
      % カウンタの処理
      get_mutvar(Game^count, Id, !IO),
      set_mutvar(Game^count, Id + 1, !IO),
      % ボールを出す
      get_mutvar(Game^bar_x, BarX, !IO),
      get_mutvar(Game^balls, Balls, !IO),
      Ball = ball(BarX, bar_y - ball_r, 0.0, -1.0, ball_init_sp),
      Balls2 = det_insert(Balls, Id, Ball),
      set_mutvar(Game^balls, Balls2, !IO),
      % Lifeの処理
      Life = Life0 - 1,
      set_mutvar(Gs^life, Life, !IO),
      sdl.render_string(Gs^res^font2,
        format("%02d", [i(Life)]), header_color, NewSurf, !IO),
      get_mutvar(Gs^life_val_surf, OldSurf, !IO),
      free_surface(OldSurf, !IO),
      set_mutvar(Gs^life_val_surf, NewSurf, !IO)
    else
      true
  ).

%----------------------------------------
% どのオブジェクトと衝突したか
%----------------------------------------
:- type hit_object
  ---> none
  ;    hit_wall
  ;    hit_block({int,int})
  ;    hit_bar.

%----------------------------------------
% ボールの軌道計算
%----------------------------------------
:- pred ray_cast(ro_game_scene::in, pt::in, vec2::in, float::in,
  pt::out, vec2::out,
  list({int,int})::out, io::di, io::uo) is det.
ray_cast(St, pt(X0, Y0), vec2(Dx, Dy), Len,
  pt(NewX, NewY), vec2(NewDx, NewDy), DelList, !IO) :-
  (
    if Len > 0.0 then
      X = X0,
      Y = Y0,
      X2 = X + Dx * Len,
      Y2 = Y + Dy * Len,
      Seg = seg(pt(X, Y), pt(X2, Y2)),
      promise_equivalent_solutions [LenSeg, Obj, HitX, HitY, N]
        hit_test(St, Seg, {LenSeg, Obj, pt(HitX, HitY), N}),
      (
        if Obj = none then
          NewX = X2, NewY = Y2,
          NewDx = Dx, NewDy = Dy,
          DelList = []
        else
          (
            if Obj = hit_bar then
              D = (1.0 - (HitX - St^ro_bar_x + 
                (St^ro_bar_w / 2.0)) / St^ro_bar_w) * 140.0 + 20.0,
              Dx2 = cos(D * pi / 180.0),
              Dy2 = -sin(D * pi / 180.0)
            else
              Dp = -2.0 * (N^vx * Dx + N^vy * Dy),    
              Dx2 = N^vx * Dp + Dx,
              Dy2 = N^vy * Dp + Dy
          ),
          HitX2 = HitX + Dx2 * ball_eps,
          HitY2 = HitY + Dy2 * ball_eps,
          Len2 = Len - LenSeg - ball_eps, 
          ray_cast(St, pt(HitX2, HitY2), vec2(Dx2, Dy2), Len2,
            pt(NewX, NewY), vec2(NewDx, NewDy), DelList0, !IO),
          (
            if Obj = hit_block(Id) then
              DelList = [Id | DelList0]
            else
              DelList = DelList0
          )
      )
  else
     NewX = X0, NewY = Y0,
     NewDx = Dx, NewDy = Dy,
     DelList = []
  ).

%----------------------------------------
% 衝突判定
%----------------------------------------
:- pred hit_test_sub(ro_game_scene::in,
  seg::in, {float, hit_object, pt, vec2}::out) is nondet.
  
% 上壁
hit_test_sub(_, Seg @ seg(Pt1, _), {Dist, hit_wall, Pt, N}) :-
  Y = frame_size2 + ball_r,
  cross_hseg(Seg,
    hseg(pt(frame_size1, Y), win_w - frame_size1), X),
  Pt = pt(X, Y),
  Dist = distance(Pt1, Pt),
  N = vec2(0.0, 1.0).

% 左壁
hit_test_sub(_, Seg @ seg(Pt1, _), {Dist, hit_wall, Pt, N}) :-
  X = frame_size1 + ball_r,
  cross_vseg(Seg,
    vseg(pt(X, frame_size2), win_w - frame_size2), Y),
  Pt = pt(X, Y),
  Dist = distance(Pt1, Pt),
  N = vec2(1.0, 0.0).

% 右壁
hit_test_sub(_, Seg @ seg(Pt1, _), {Dist, hit_wall, Pt, N}) :-
  X = win_w - frame_size1 - ball_r,
  cross_vseg(Seg,
    vseg(pt(X, frame_size2), win_w - frame_size2), Y),
  Pt = pt(X, Y),
  Dist = distance(Pt1, Pt),
  N = vec2(-1.0, 0.0).

% ブロック
hit_test_sub(St, Seg @ seg(Pt1, _), {Dist, hit_block(Id), Pt, N}) :-
  member(St^ro_blocks, Id, block(X1, Y1, X2, Y2, _)),
  cross_rect(Seg, rect(pt(X1,Y1), pt(X2,Y2)), ball_r, Pt, N),
  Dist = distance(Pt1, Pt).

% バー
hit_test_sub(St, Seg @ seg(Pt1, _), {Dist, hit_bar, Pt, N}) :-
  cross_rect(Seg,
    rect(pt(St^ro_bar_x - St^ro_bar_w / 2.0, bar_y),
         pt(St^ro_bar_x + St^ro_bar_w / 2.0, bar_y)),
    ball_r, Pt, _),
  Dist = distance(Pt1, Pt),
  N = vec2(0.0, -1.0).

%----------------------------------------
% 衝突した物体のうち、最も距離の短いものを選ぶ
%----------------------------------------
:- pred hit_test(ro_game_scene::in, seg::in,
  {float, hit_object, pt, vec2}::out) is cc_multi.
hit_test(Gs, Seg, {LenOut, ObjOut, PtOut, NOut}) :-
  P = (pred({Len, Obj, Pt, N}::in,
    {Len0, Obj0, Pt0, N0}::in,
    {Len1, Obj1, Pt1, N1}::out) is det :-
    (
      if Len < Len0 then
        Len1 = Len, Obj1 = Obj, Pt1 = Pt, N1 = N
      else
        Len1 = Len0, Obj1 = Obj0, Pt1 = Pt0, N1 = N0
    )),
  unsorted_aggregate(hit_test_sub(Gs, Seg), P,
    {float.max, none, pt(0.0, 0.0), vec2(0.0, 1.0)},
    {LenOut, ObjOut, PtOut, NOut}).

%========================================
% クリア画面
%========================================

:- type clear_scene
  ---> clear_scene.

%----------------------------------------
% クリア画面の初期化
%----------------------------------------
:- pred init_clear_scene(clear_scene::out) is det.
init_clear_scene(Cs) :-
  Cs = clear_scene.

%----------------------------------------
% クリア画面のインスタンス宣言
%----------------------------------------
:- instance handler(clear_scene) where [
  pred(update/4) is update_clear,
  pred(draw/4) is draw_clear,
  pred(mouse_move/6) is mouse_move_clear,
  pred(mouse_down/6) is mouse_down_clear
].

%----------------------------------------
% クリア画面の更新処理
%----------------------------------------
:- pred update_clear(clear_scene::in, gs::in, io::di, io::uo) is det.
update_clear(_, _, !IO).

%----------------------------------------
% クリア画面の描画
%----------------------------------------
:- pred draw_clear(clear_scene::in, gs::in, io::di, io::uo) is det.
draw_clear(_, Gs, !IO) :-
  sdl.blit(Gs^buffer, Gs^scr, xy(0,0), !IO),
  Tx = (int(win_w) - Gs^res^clear_width) / 2,
  Ty = (int(win_h) - Gs^res^clear_height) / 2,
  sdl.blit(Gs^res^clear_surf, Gs^scr, xy(Tx, Ty), !IO),
  sdl.flip(Gs^scr, !IO).

%----------------------------------------
% クリア画面でのマウス移動
%----------------------------------------
:- pred mouse_move_clear(clear_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_move_clear(_, _, _, _, !IO).

%----------------------------------------
% クリア画面でのマウスクリック
%----------------------------------------
:- pred mouse_down_clear(clear_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_down_clear(_, _, _, Gs, !IO) :-
  init_title_scene(Ts),
  set_mutvar(Gs^life, init_life, !IO),
  set_mutvar(Gs^scene, 'new handler'(Ts), !IO).

%========================================
% ゲームオーバー画面
%========================================

:- type gameover_scene
  ---> gameover_scene.

%----------------------------------------
% ゲームオーバー画面の初期化
%----------------------------------------
:- pred init_gameover_scene(gameover_scene::out) is det.
init_gameover_scene(Cs) :-
  Cs = gameover_scene.

%----------------------------------------
% ゲームオーバー画面のインスタンス宣言
%----------------------------------------
:- instance handler(gameover_scene) where [
  pred(update/4) is update_gameover,
  pred(draw/4) is draw_gameover,
  pred(mouse_move/6) is mouse_move_gameover,
  pred(mouse_down/6) is mouse_down_gameover
].

%----------------------------------------
% ゲームオーバー画面の更新処理
%----------------------------------------
:- pred update_gameover(gameover_scene::in, gs::in, io::di, io::uo) is det.
update_gameover(_, _, !IO).

%----------------------------------------
% ゲームオーバー画面の描画
%----------------------------------------
:- pred draw_gameover(gameover_scene::in, gs::in, io::di, io::uo) is det.
draw_gameover(_, Gs, !IO) :-
  sdl.blit(Gs^buffer, Gs^scr, xy(0,0), !IO),
  Tx = (int(win_w) - Gs^res^gameover_width) / 2,
  Ty = (int(win_h) - Gs^res^gameover_height) / 2,
  sdl.blit(Gs^res^gameover_surf, Gs^scr, xy(Tx, Ty), !IO),
  sdl.flip(Gs^scr, !IO).

%----------------------------------------
% ゲームオーバー画面でのマウス移動
%----------------------------------------
:- pred mouse_move_gameover(gameover_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_move_gameover(_, _, _, _, !IO).

%----------------------------------------
% ゲームオーバー画面でのマウスクリック
%----------------------------------------
:- pred mouse_down_gameover(gameover_scene::in,
  int::in, int::in, gs::in, io::di, io::uo) is det.
mouse_down_gameover(_, _, _, Gs, !IO) :-
  init_title_scene(Ts),
  set_mutvar(Gs^life, init_life, !IO),
  set_mutvar(Gs^scene, 'new handler'(Ts), !IO).

