:- module sdl.

:- interface.
:- import_module io.

:- type surface.
:- type font.

% init(Width, Height, Surface, !IO)
% SDLを初期化して幅Width, 高さHeightのウインドウを作りそのサーフェイスを返す．
:- pred init(int::in, int::in, surface::out, io::di, io::uo) is det.

% window_title(Title, !IO)
% ウインドウタイトルを設定する．
:- pred window_title(string::in, io::di, io::uo) is det.

% delay(Milliseconds, !IO)
% Millisecondsで指定した時間(ミリ秒)だけ待機する．
:- pred delay(int::in, io::di, io::uo) is det.

% flip(Surface, !IO)
% バッファを交換する
:- pred flip(surface::in, io::di, io::uo) is det.

% blit(Src, Dst, Point, !IO)
% blit(Src, Rect, Dst, Point, !IO)
% サーフェイスSrcをサーフェイスDstに転送する．
:- pred blit(surface::in, surface::in, point::in, io::di, io::uo) is det.
:- pred blit(surface::in, rect::in, surface::in, point::in, io::di, io::uo) is det.

% fill(Color, !IO)
% サーフェイスを単色で塗りつぶす．
:- pred fill(surface::in, color::in, io::di, io::uo) is det.
:- pred fill(surface::in, color::in, rect::in, io::di, io::uo) is det.

% poll(Event, !IO)
% イベントキューから保留中のイベントを取り出す．
% 保留中のイベントがない場合はno_eventを返す．
:- pred poll(event_type::out, io::di, io::uo) is det.

% get_ticks(Ms, !IO)
% SDLが初期化されてからの時間(ミリ秒)を返す．
:- pred get_ticks(int::out, io::di, io::uo) is det.

% get_surface(Surface, !IO).
% 現在の画面のサーフェイスを取得．
:- pred get_surface(surface::out, io::di, io::uo) is det.

% create_surface(Width, Height, Surface, !IO)
% 幅Width，高さHeightのサーフェイスを作る
:- pred create_surface(int::in, int::in, surface::out, io::di, io::uo) is det.

% save_surface(Surface, FileName, !IO)
% サーフェイスをBMPファイルとして保存する
:- pred save_surface(surface::in, string::in, io::di, io::uo) is det.

% free_surface(Surface, !IO)
% サーフェイスを解放する
:- pred free_surface(surface::in, io::di, io::uo) is det.

% load_image(FileName, Surface, !IO).
% 画像ファイルを(bmp, jpg, png)を読み込んでサーフェイスを返す．
:- pred load_image(string::in, surface::out, io::di, io::uo) is det.

% load_font(FileName, PointSize, Font, !IO).
% フォント(ttf)を読み込む
:- pred load_font(string::in, int::in, font::out, io::di, io::uo) is det.

% render_string(Font, String, Color, Surface, !IO).
% 文字列を描画して，そのサーフェイスを返す．
:- pred render_string(font::in, string::in, color::in, 
    surface::out, io::di, io::uo) is det.

% render_string_size(Font, String, Height, Width, !IO).
% 文字列を描画したときの大きさを計測する．
:- pred render_string_size(font::in, string::in, int::out, int::out, 
    io::di, io::uo) is det.

% draw_line(Surface, Pt1, Pt2, Color, !IO).
% 線を引く
:- pred draw_line(surface::in,
    point::in, point::in, color::in, io::di, io::uo) is det.

% draw_pixel(Surface, Point, Color, !IO).
% 点を打つ
:- pred draw_pixel(surface::in, point::in, color::in, io::di, io::uo) is det.

% draw_circle(Surface, Point, Radius, Color, !IO).
% 円を描く
:- pred draw_circle(surface::in,
    point::in, int::in, color::in, io::di, io::uo) is det.
    
% draw_filled_circle(Surface, Point, Radius, Color, !IO).
% 塗りつぶした円を描く
:- pred draw_filled_circle(surface::in,
    point::in, int::in, color::in, io::di, io::uo) is det.

% draw_rect(Surface, Pt1, Pt2, Color, !IO).
% 四角形を描く
:- pred draw_rect(surface::in,
    point::in, point::in, color::in, io::di, io::uo) is det.

% draw_filled_rect(Surface, Pt1, Pt2, Color, !IO).
% 塗りつぶした四角形を描く
:- pred draw_filled_rect(surface::in,
    point::in, point::in, color::in, io::di, io::uo) is det.

% draw_trigon(Surface, Pt1, Pt2, Pt3, Color, !IO).
% 三角形ポリゴンを描く．
:- pred draw_trigon(surface::in,
    point::in, point::in, point::in, color::in, io::di, io::uo) is det.

% draw_filled_trigon(Surface, Pt1, Pt2, Pt3, Color, !IO).
% 塗りつぶした三角形ポリゴンを描く．
:- pred draw_filled_trigon(surface::in,
    point::in, point::in, point::in, color::in, io::di, io::uo) is det.

% イベントの種類
:- type event_type
    ---> no_event
    ;    quit_event
    ;    mouse_down_event(mouse_button, int, int)
    ;    mouse_up_event(mouse_button, int, int)
    ;    mouse_move_event(int, int)
    ;    key_down_event(keysym)
    ;    key_up_event(keysym).

% マウスボタンの種類
:- type mouse_button
    ---> left_button
    ;    middle_button
    ;    right_button.

% キーの種類
:- type keysym
    ---> key_up
    ;    key_down
    ;    key_right
    ;    key_left
    ;    key_return
    ;    key_escape
    ;    key_space
    ;    key_z
    ;    key_x
    ;    key_c
    ;    key_others.

% 色
:- type color ---> rgb(int, int, int).

% 矩形
:- type rect ---> xywh(int, int, int, int).

% 位置
:- type point ---> xy(int, int).

%============================================================
:- implementation.

:- pragma foreign_decl("C", "#include <stdio.h>").
:- pragma foreign_decl("C", "#include <stdlib.h>").
:- pragma foreign_decl("C", "#include \"SDL/SDL.h\"").
:- pragma foreign_decl("C", "#include \"SDL/SDL_image.h\"").
:- pragma foreign_decl("C", "#include \"SDL/SDL_ttf.h\"").
:- pragma foreign_decl("C", "#include \"SDL/SDL_gfxPrimitives.h\"").

:- type surface ---> surface(c_pointer).
:- type font ---> font(c_pointer).

%------------------------------
% init
%------------------------------
:- pragma foreign_proc("C",
    init(Width::in, Height::in, Screen::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Surface *screen; 
    SDL_Init(SDL_INIT_VIDEO);
    IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_TIF);
    TTF_Init();
    
    Screen = (MR_Word)SDL_SetVideoMode(
        Width, Height, 32, SDL_HWSURFACE | SDL_DOUBLEBUF);
        
    atexit(IMG_Quit);
    atexit(SDL_Quit);
    atexit(TTF_Quit);
    S1 = S0;
    ").

%------------------------------
% window_title
%------------------------------
:- pragma foreign_proc("C",
    window_title(Title::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_WM_SetCaption(Title, Title);
    S1 = S0;
    ").


%------------------------------
% delay
%------------------------------
:- pragma foreign_proc("C",
    delay(MS::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Delay(MS);
    S1 = S0;
    ").

%------------------------------
% flip
%------------------------------
:- pragma foreign_proc("C",
    flip(Surface::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Flip((SDL_Surface*)Surface);
    S1 = S0;
    ").

%------------------------------
% blit
%------------------------------

:- pred blit_stub(surface::in, surface::in, int::in, int::in, io::di, io::uo) is det.
:- pred blit_stub(surface::in, int::in, int::in, int::in, int::in,
    surface::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    blit_stub(Src::in, Dst::in, X::in, Y::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Rect dst = { X, Y, 0, 0 };
    int r = SDL_BlitSurface(
        (SDL_Surface*)Src, NULL, (SDL_Surface*)Dst, &dst);
    if (r) {
        fprintf(stderr, \"Couldn't blit surface.\");
        exit(EXIT_FAILURE);
    }
    S1 = S0;
    ").

:- pragma foreign_proc("C",
    blit_stub(Src::in, SX::in, SY::in, SW::in, SH::in, 
        Dst::in, X::in, Y::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Rect src = { SX, SY, SW, SH };
    SDL_Rect dst = { X, Y, 0, 0 };
    int r = SDL_BlitSurface(
        (SDL_Surface*)Src, &src, (SDL_Surface*)Dst, &dst);
    if (r) {
        fprintf(stderr, \"Couldn't blit surface.\");
        exit(EXIT_FAILURE);
    }
    S1 = S0;
    ").

blit(Src, Dst, xy(X, Y), !IO) :-
    blit_stub(Src, Dst, X, Y, !IO).

blit(Src, xywh(SX, SY, SW, SH), Dst, xy(X, Y), !IO) :-
    blit_stub(Src, SX, SY, SW, SH, Dst, X, Y, !IO).

%------------------------------
% fill
%------------------------------

:- pred fill_stub(surface::in, int::in, int::in, int::in, io::di, io::uo) is det.
:- pred fill_stub(surface::in, int::in, int::in, int::in, 
    int::in, int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    fill_stub(Surface::in, R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Surface *surface = (SDL_Surface *)Surface;
    Uint32 color = SDL_MapRGB(surface->format, R, G, B);
    SDL_FillRect(surface, NULL, color);
    S1 = S0;
    ").

:- pragma foreign_proc("C",
    fill_stub(Surface::in, R::in, G::in, B::in,
        X::in, Y::in, W::in, H::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Surface *surface = (SDL_Surface *)Surface;
    SDL_Rect rect = { X, Y, W, H };
    Uint32 color = SDL_MapRGB(surface->format, R, G, B);
    SDL_FillRect(surface, &rect, color);
    S1 = S0;
    ").

fill(Surface, rgb(R, G, B), !IO) :-
    fill_stub(Surface, R, G, B, !IO).

fill(Surface, rgb(R, G, B), xywh(X, Y, W, H), !IO) :-
    fill_stub(Surface, R, G, B, X, Y, W, H, !IO).

%------------------------------
% poll
%------------------------------
:- pragma foreign_decl("C", "static SDL_Event glb_event;").
    
:- pragma foreign_enum("C", mouse_button/0,
    [
        left_button - "SDL_BUTTON_LEFT",
        middle_button - "SDL_BUTTON_MIDDLE",
        right_button - "SDL_BUTTON_RIGHT"
    ]).
    
:- pragma foreign_enum("C", keysym/0,
    [
        key_up - "SDLK_UP",
        key_down - "SDLK_DOWN",
        key_right - "SDLK_RIGHT",
        key_left - "SDLK_LEFT",
        key_return - "SDLK_RETURN",
        key_escape - "SDLK_ESCAPE",
        key_space - "SDLK_SPACE",
        key_z - "SDLK_z",
        key_x - "SDLK_x",
        key_c - "SDLK_c",
        key_others - "0"
    ]).

:- pred poll_stub(int::out, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    poll_stub(Out::out, S0::di, S1::uo),
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
        case SDL_KEYDOWN:
            Out = 5;
            break;
        case SDL_KEYUP:
            Out = 6;
            break;
        default:
            Out = 0;
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
 
:- pred get_key_event(keysym::out, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    get_key_event(KeySym::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    switch (glb_event.key.keysym.sym) {
    case SDLK_UP:
    case SDLK_DOWN:
    case SDLK_RIGHT:
    case SDLK_LEFT:
    case SDLK_RETURN:
    case SDLK_ESCAPE:
    case SDLK_SPACE:
    case SDLK_z:
    case SDLK_x:
    case SDLK_c:
        KeySym = glb_event.key.keysym.sym;
        break;
    default:
        KeySym = 0;
        break;
    }
    S1 = S0;
    ").       

poll(Type, !IO) :-
    poll_stub(Out, !IO),
    (
        Out = 1 ->
        Type = quit_event
    ;
        Out = 2 ->
        get_button_event(Btn, X, Y, !IO),
        Type = mouse_down_event(Btn, X, Y)
    ;
        Out = 3 ->
        get_button_event(Btn, X, Y, !IO),
        Type = mouse_up_event(Btn, X, Y)
    ;
        Out = 4 ->
        get_motion_event(X, Y, !IO),
        Type = mouse_move_event(X, Y)
    ;
        Out = 5 ->
        get_key_event(KeySym, !IO),
        Type = key_down_event(KeySym)
    ;
        Out = 6 ->
        get_key_event(KeySym, !IO),
        Type = key_up_event(KeySym)
    ;
        Type = no_event
    ).

%------------------------------
% get_ticks
%------------------------------
:- pragma foreign_proc("C",
    get_ticks(Out::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    Out = SDL_GetTicks();
    S1 = S0;
    ").

%------------------------------
% get_surface
%------------------------------
:- pragma foreign_proc("C",
    get_surface(Out::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    Out = (MR_Word)SDL_GetVideoSurface();
    S1 = S0;
    ").

%------------------------------
% create_surface
%------------------------------
:- pragma foreign_proc("C",
    create_surface(W::in, H::in, Surface::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    Surface = (MR_Word)SDL_CreateRGBSurface(
        SDL_HWSURFACE | SDL_SRCCOLORKEY | SDL_SRCALPHA,
        W, H, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
    S1 = S0;
    ").

%------------------------------
% save_surface
%------------------------------
:- pragma foreign_proc("C",
    save_surface(Surface::in, FileName::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_SaveBMP((SDL_Surface *)Surface, FileName);
    S1 = S0;
    ").

%------------------------------
% free_surface
%------------------------------
:- pragma foreign_proc("C",
    free_surface(Surface::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_FreeSurface((SDL_Surface *)Surface);
    S1 = S0;
    ").

%------------------------------
% load_image
%------------------------------
:- pragma foreign_proc("C",
    load_image(FileName::in, Surface::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Surface *surface;
    surface = IMG_Load(FileName);
    if (!surface) {
        fprintf(stderr, \"Couldn't open file [%s]: %s\",
            FileName, SDL_GetError());
        exit(EXIT_FAILURE);
    }
    Surface = (MR_Word)surface;
    S1 = S0;
    ").

%------------------------------
% load_font
%------------------------------
:- pragma foreign_proc("C",
    load_font(FileName::in, Size::in, Font::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    TTF_Font *font;
    font = TTF_OpenFont(FileName, Size);
    if (!font) {
        fprintf(stderr, \"Couldn't open font: %s\", FileName);
        exit(EXIT_FAILURE);
    }
    Font = (MR_Word)font;
    S1 = S0;
    ").

%------------------------------
% render_string
%------------------------------
:- pred render_string(font::in, string::in, int::in, int::in, int::in, 
    surface::out, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    render_string(Font::in, Str::in, R::in, G::in, B::in,
        Surface::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    SDL_Color color = {R, G, B};
    SDL_Surface *surface = TTF_RenderUTF8_Blended(
        (TTF_Font*)Font, Str, color);
    Surface = (MR_Word)surface;
    S1 = S0;
    ").

render_string(Font, Str, rgb(R, G, B), Surface, !IO) :-
    render_string(Font, Str, R, G, B, Surface, !IO).

%------------------------------
% render_string_size
%------------------------------
:- pragma foreign_proc("C",
    render_string_size(Font::in, Str::in, W::out, H::out, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    int SW, SH;
    TTF_SizeUTF8((TTF_Font*)Font, Str, &SW, &SH);
    W = SW, H = SH;
    S1 = S0;
    ").

%------------------------------
% draw_line
%------------------------------
:- pred draw_line(surface::in, int::in, int::in, int::in, int::in,
    int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_line(Surface::in, X1::in, Y1::in, X2::in, Y2::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    aalineRGBA((SDL_Surface *)Surface, X1, Y1, X2, Y2, R, G, B, 255);
    S1 = S0;
    ").

draw_line(Surface, xy(X1, Y1), xy(X2, Y2), rgb(R, G, B), !IO) :-
    draw_line(Surface, X1, Y1, X2, Y2, R, G, B, !IO).

%------------------------------
% draw_pixel
%------------------------------
:- pred draw_pixel(surface::in, int::in, int::in, 
    int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_pixel(Surface::in, X1::in, Y1::in, R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    pixelRGBA((SDL_Surface *)Surface, X1, Y1, R, G, B, 255);
    S1 = S0;
    ").

draw_pixel(Surface, xy(X1, Y1), rgb(R, G, B), !IO) :-
    draw_pixel(Surface, X1, Y1, R, G, B, !IO).

%------------------------------
% draw_circle
%------------------------------
:- pred draw_circle(surface::in, int::in, int::in, 
    int::in, int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_circle(Surface::in, X1::in, Y1::in, Rad::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    aacircleRGBA((SDL_Surface *)Surface, X1, Y1, Rad, R, G, B, 255);
    S1 = S0;
    ").

draw_circle(Surface, xy(X1, Y1), Rad, rgb(R, G, B), !IO) :-
    draw_circle(Surface, X1, Y1, Rad, R, G, B, !IO).

:- pred draw_filled_circle(surface::in, int::in, int::in, 
    int::in, int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_filled_circle(Surface::in, X1::in, Y1::in, Rad::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    filledCircleRGBA((SDL_Surface *)Surface, X1, Y1, Rad, R, G, B, 255);
    S1 = S0;
    ").

draw_filled_circle(Surface, xy(X1, Y1), Rad, rgb(R, G, B), !IO) :-
    draw_filled_circle(Surface, X1, Y1, Rad, R, G, B, !IO).

%------------------------------
% draw_rect
%------------------------------
:- pred draw_rect(surface::in, int::in, int::in, int::in, int::in,
    int::in, int::in, int::in, io::di, io::uo) is det.
    
:- pragma foreign_proc("C",
    draw_rect(Surface::in, X1::in, Y1::in, X2::in, Y2::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    rectangleRGBA((SDL_Surface *)Surface, X1, Y1, X2, Y2, R, G, B, 255);
    S1 = S0;
    ").

draw_rect(Surface, xy(X1, Y1), xy(X2, Y2), rgb(R, G, B), !IO) :-
    draw_rect(Surface, X1, Y1, X2, Y2, R, G, B, !IO).

:- pred draw_filled_rect(surface::in, int::in, int::in, int::in, int::in,
    int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_filled_rect(Surface::in, X1::in, Y1::in, X2::in, Y2::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    boxRGBA((SDL_Surface *)Surface, X1, Y1, X2, Y2, R, G, B, 255);
    S1 = S0;
    ").

draw_filled_rect(Surface, xy(X1, Y1), xy(X2, Y2), rgb(R, G, B), !IO) :-
    draw_filled_rect(Surface, X1, Y1, X2, Y2, R, G, B, !IO).

%------------------------------
% draw_trigon
%------------------------------
:- pred draw_trigon(surface::in, int::in, int::in, int::in, int::in,
    int::in, int::in, int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_trigon(Surface::in, X1::in, Y1::in, X2::in, Y2::in, X3::in, Y3::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    aatrigonRGBA((SDL_Surface *)Surface, X1, Y1, X2, Y2, X3, Y3, R, G, B, 255);
    S1 = S0;
    ").

draw_trigon(Surface, xy(X1, Y1), xy(X2, Y2), xy(X3, Y3), rgb(R, G, B), !IO) :-
    draw_trigon(Surface, X1, Y1, X2, Y2, X3, Y3, R, G, B, !IO).

:- pred draw_filled_trigon(surface::in, int::in, int::in, int::in, int::in,
    int::in, int::in, int::in, int::in, int::in, io::di, io::uo) is det.

:- pragma foreign_proc("C",
    draw_filled_trigon(Surface::in, X1::in, Y1::in, X2::in, Y2::in, X3::in, Y3::in,
        R::in, G::in, B::in, S0::di, S1::uo),
    [promise_pure, will_not_call_mercury],
    "
    filledTrigonRGBA((SDL_Surface *)Surface, X1, Y1, X2, Y2, X3, Y3, R, G, B, 255);
    S1 = S0;
    ").

draw_filled_trigon(Surface, xy(X1, Y1), xy(X2, Y2), xy(X3, Y3), rgb(R, G, B), !IO) :-
    draw_trigon(Surface, X1, Y1, X2, Y2, X3, Y3, R, G, B, !IO).
