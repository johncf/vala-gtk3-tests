.PHONY: all
all: bin/anim bin/draw

bin/%: %.vala
	mkdir -p bin
	valac --pkg gtk+-3.0 $< -o $@
