.PHONY: all
all: bin/anim

bin/%: %.vala
	mkdir -p bin
	valac --pkg gtk+-3.0 $< -o $@
