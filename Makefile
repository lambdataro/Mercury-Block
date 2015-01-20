all:
	mmc --make block --ld-flags -lSDL2 -lSDL2_image

clean:
	rm -r *.err *.mh block Mercury
