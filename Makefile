all:
	mmc --make main --ld-flags -lSDL -lSDL_image -lSDL_ttf -lSDL_gfx

clean:
	rm -r *.err *.mh main Mercury
