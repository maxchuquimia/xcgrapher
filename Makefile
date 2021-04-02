prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/xcgrapher" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/xcgrapher"

clean:
	rm -rf .build

.PHONY: build install uninstall clean

