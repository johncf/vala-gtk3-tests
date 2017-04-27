.PHONY: all
all: main.vala
	mkdir -p bin
	valac --pkg gtk+-3.0 main.vala -o bin/main
