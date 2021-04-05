prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
buildroot = $(shell swift build -c release --show-bin-path)

build:
	swift build -c release --disable-sandbox

install: build
	install "$(buildroot)/xcgrapher" "$(bindir)"
	install "$(buildroot)/libXCGrapherPluginSupport.dylib" "$(libdir)"
	install_name_tool -change \
		"$(buildroot)/libXCGrapherPluginSupport.dylib" \
		"$(libdir)/libXCGrapherPluginSupport.dylib" \
		"$(bindir)/xcgrapher"

uninstall:
	rm -rf "$(bindir)/xcgrapher"
	rm -rf "$(libdir)/libXCGrapherPluginSupport.dylib"

clean:
	rm -rf .build

.PHONY: build install uninstall clean

