:- module sdl2.
:- interface.
:- import_module io.

% 型定義
:- type window.
:- type renderer.
:- type texture.

% イベントの種類
:- type event_type
  ---> no_event
  ;    quit_event
  ;    mouse_down_event(mouse_button, int, int)
  ;    mouse_up_event(mouse_button, int, int)
  ;    mouse_move_event(int, int)
  ;    other_event.

% マウスのボタンの種類
:- type mouse_button
  ---> left_button
  ;    middle_button
  ;    right_button.

% SDLの初期化
:- pred init(io::di, io::uo) is det.

% SDLの終了
:- pred quit(io::di, io::uo) is det.

% ウインドウの作成
:- pred create_window(string::in, int::in, int::in,
  window::out, io::di, io::uo) is det.

% レンダラの作成
:- pred create_renderer(window::in, renderer::out,
  io::di, io::uo) is det.
  
% イメージをテクスチャとして読み込む
:- pred load_texture(renderer::in, string::in, texture::out,
  io::di, io::uo) is det.

% テクスチャをレンダラーにコピーする
:- pred render_copy(renderer::in, texture::in, int::in, int::in,
  io::di, io::uo) is det.

% レンダラーに書き込んだ内容を反映する
:- pred render_present(renderer::in, io::di, io::uo) is det.

% レンダーをクリア
:- pred render_clear(renderer::in, io::di, io::uo) is det.

% 遅延させる
:- pred delay(int::in, io::di, io::uo) is det.

% 描画色を指定する
:- pred render_draw_color(renderer::in, int::in, int::in, int::in, int::in,
  io::di, io::uo) is det.

% テクスチャを破棄する
:- pred destroy_texture(texture::in, io::di, io::uo) is det.

% レンダラーを破棄する
:- pred destroy_renderer(renderer::in, io::di, io::uo) is det.

% ウインドウを破棄する
:- pred destroy_window(window::in, io::di, io::uo) is det.

% イベントをpollする
:- pred poll(event_type::out, io::di, io::uo) is det.

% 線を描画する
:- pred render_draw_line(renderer::in, int::in, int::in, int::in, int::in,
  io::di, io::uo) is det.

% 点を描画する
:- pred render_draw_point(renderer::in, int::in, int::in,
  io::di, io::uo) is det.

% 長方形を描画する
:- pred render_draw_rect(renderer::in, int::in, int::in, int::in, int::in,
  io::di, io::uo) is det.

% 長方形を描画する
:- pred render_fill_rect(renderer::in, int::in, int::in, int::in, int::in,
  io::di, io::uo) is det.

% SDLが初期化されてからのミリ秒数
:- pred get_ticks(int::out, io::di, io::uo) is det.

:- implementation.
:- import_module exception.

:- type sdl2_exception ---> sdl2_exception(string).

:- pragma foreign_decl("C", "#include \"SDL2/SDL.h\"").
:- pragma foreign_decl("C", "#include \"SDL2/SDL_image.h\"").

%----------------------------------------
% 型
%----------------------------------------
:- pragma foreign_type("C", window, "SDL_Window *").
:- pragma foreign_type("C", renderer, "SDL_Renderer *").
:- pragma foreign_type("C", texture, "SDL_Texture *").

%----------------------------------------
% pred sdl2_throw
% SDL2例外を投げる
%----------------------------------------
:- pred sdl2_throw(string::in) is erroneous.
sdl2_throw(Mes) :-
  throw(sdl2_exception(Mes)).

:- pragma foreign_export("C",
  sdl2_throw(in), "mercury_sdl2_throw").

%----------------------------------------
% pred init
% SDLの初期化
%----------------------------------------
:- pragma foreign_proc("C",
  init(S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  if (SDL_Init(SDL_INIT_VIDEO) != 0)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred quit
% SDLの終了
%----------------------------------------
:- pragma foreign_proc("C",
  quit(S0::di, S1::uo),
  [promise_pure, will_not_call_mercury],
  "
  SDL_Quit();
  S1 = S0;
  ").

%----------------------------------------
% pred create_window
% ウインドウの作成
%----------------------------------------
:- pragma foreign_proc("C",
  create_window(Title::in, W::in, H::in, Window::out, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  Window = SDL_CreateWindow(Title,
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOWPOS_UNDEFINED,
    W, H, 0);
  if (!Window)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred create_renderer
% レンダラの作成
%----------------------------------------
:- pragma foreign_proc("C",
  create_renderer(Window::in, Renderer::out, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  Renderer = SDL_CreateRenderer(Window, -1,
    SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
  if (!Renderer)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred load_image
% イメージをテクスチャとして読み込む
%----------------------------------------
:- pragma foreign_proc("C",
  load_texture(Renderer::in, FilePath::in, Texture::out, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  Texture = IMG_LoadTexture(Renderer, FilePath);
  if (!Texture)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred render_copy
% テクスチャをレンダーにコピーする
%----------------------------------------
:- pragma foreign_proc("C",
  render_copy(Renderer::in, Texture::in, X::in, Y::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  int r;
  SDL_Rect dst;
  SDL_QueryTexture(Texture, NULL, NULL, &dst.w, &dst.h);
  dst.x = X;
  dst.y = Y;
  r = SDL_RenderCopy(Renderer, Texture, NULL, &dst);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred render_present
% レンダラーに書き込んだ内容を反映する
%----------------------------------------
:- pragma foreign_proc("C",
  render_present(Renderer::in, S0::di, S1::uo),
  [promise_pure, will_not_call_mercury],
  "
  SDL_RenderPresent(Renderer);
  S1 = S0;
  ").

%----------------------------------------
% pred delay
% 遅延させる
%----------------------------------------
:- pragma foreign_proc("C",
  delay(Ms::in, S0::di, S1::uo),
  [promise_pure, will_not_call_mercury],
  "
  SDL_Delay(Ms);
  S1 = S0;
  ").

%----------------------------------------
% pred render_clear
% レンダーをクリア
%----------------------------------------
:- pragma foreign_proc("C",
  render_clear(Renderer::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  int r = SDL_RenderClear(Renderer);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred render_draw_color
% 描画色を指定する
%----------------------------------------
:- pragma foreign_proc("C",
  render_draw_color(Renderer::in, R::in, G::in, B::in, A::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  int r = SDL_SetRenderDrawColor(Renderer, R, G, B, A);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred destroy_texture
% テクスチャを破棄する
%----------------------------------------
:- pragma foreign_proc("C",
    destroy_texture(Texture::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_DestroyTexture(Texture);
    S1 = S0;
    ").

%----------------------------------------
% pred destroy_renderer
% レンダラーを破棄する
%----------------------------------------
:- pragma foreign_proc("C",
    destroy_renderer(Renderer::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_DestroyRenderer(Renderer);
    S1 = S0;
    ").

%----------------------------------------
% pred destroy_window
% ウインドウを破棄する
%----------------------------------------
:- pragma foreign_proc("C",
    destroy_window(Window::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_DestroyWindow(Window);
    S1 = S0;
    ").

%----------------------------------------
% pred poll
% イベントをpollする
%----------------------------------------
:- pragma foreign_decl("C", "static SDL_Event glb_event;").

:- pred poll_and_assign(int::out, io::di, io::uo) is det.

:- pragma foreign_proc("C",
  poll_and_assign(Out::out, S0::di, S1::uo),
  [promise_pure, will_not_call_mercury],
  "
  int r = SDL_PollEvent(&glb_event);
  if (r == 0) Out = 0;
  else {
    switch (glb_event.type) {
    case SDL_QUIT:
      Out = 1;
      break;
    case SDL_MOUSEBUTTONDOWN:
      Out = 2;
      break;
    case SDL_MOUSEBUTTONUP:
      Out = 3;
      break;
    case SDL_MOUSEMOTION:
      Out = 4;
      break;
    default:
      Out = 100;
      break;
    }
  }
  S1 = S0;
  ").

:- pred get_button_event(mouse_button::out, int::out, int::out,
  io::di, io::uo) is det.

:- pragma foreign_proc("C",
  get_button_event(Btn::out, X::out, Y::out, S0::di, S1::uo),
  [promise_pure, will_not_call_mercury],
  "
  Btn = glb_event.button.button;
  X = glb_event.button.x;
  Y = glb_event.button.y;
  S1 = S0;
  ").

:- pred get_motion_event(int::out, int::out, io::di, io::uo) is det.

:- pragma foreign_proc("C",
  get_motion_event(X::out, Y::out, S0::di, S1::uo),
  [promise_pure, will_not_call_mercury],
  "
  X = glb_event.motion.x;
  Y = glb_event.motion.y;
  S1 = S0;
  ").    

:- pragma foreign_enum("C", mouse_button/0,
  [
    left_button - "SDL_BUTTON_LEFT",
    middle_button - "SDL_BUTTON_MIDDLE",
    right_button - "SDL_BUTTON_RIGHT"
  ]).

poll(Type, !IO) :-
  poll_and_assign(Id, !IO),
  (
    Id = 0 ->
    Type = no_event
  ;
    Id = 1 ->
    Type = quit_event
  ;
    Id = 2 ->
    get_button_event(Btn, X, Y, !IO),
    Type = mouse_down_event(Btn, X, Y)
  ;
    Id = 3 ->
    get_button_event(Btn, X, Y, !IO),
    Type = mouse_up_event(Btn, X, Y)
  ;
    Id = 4 ->
    get_motion_event(X, Y, !IO),
    Type = mouse_move_event(X, Y)
  ;
    Type = other_event
  ).

%----------------------------------------
% pred render_draw_line
% 線を描画する
%----------------------------------------
:- pragma foreign_proc("C",
  render_draw_line(Renderer::in, X1::in, Y1::in, X2::in, Y2::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  int r = SDL_RenderDrawLine(Renderer, X1, Y1, X2, Y2);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred render_draw_point
% 線を描画する
%----------------------------------------
:- pragma foreign_proc("C",
  render_draw_point(Renderer::in, X::in, Y::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  int r = SDL_RenderDrawPoint(Renderer, X, Y);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred render_draw_rect
% 長方形を描画する
%----------------------------------------
:- pragma foreign_proc("C",
  render_draw_rect(Renderer::in, X::in, Y::in, W::in, H::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  SDL_Rect rect;
  rect.x = X;
  rect.y = Y;
  rect.w = W;
  rect.h = H;
  int r = SDL_RenderDrawRect(Renderer, &rect);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred render_fill_rect
% 長方形を描画する
%----------------------------------------
:- pragma foreign_proc("C",
  render_fill_rect(Renderer::in, X::in, Y::in, W::in, H::in, S0::di, S1::uo),
  [promise_pure, may_call_mercury],
  "
  SDL_Rect rect;
  rect.x = X;
  rect.y = Y;
  rect.w = W;
  rect.h = H;
  int r = SDL_RenderFillRect(Renderer, &rect);
  if (r)
    mercury_sdl2_throw((MR_String)SDL_GetError());
  S1 = S0;
  ").

%----------------------------------------
% pred get_ticks
% SDLが初期化されてからのミリ秒数
%----------------------------------------
:- pragma foreign_proc("C",
    get_ticks(Ticks::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    Ticks = SDL_GetTicks();
    S1 = S0;
    ").

