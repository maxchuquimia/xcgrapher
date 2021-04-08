prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
buildroot = $(shell swift build -c release --show-bin-path)

configure:
	echo "let DEFAULT_PLUGIN_LOCATION=\"$(libdir)/libXCGrapherModuleImportPlugin.dylib\"" > Sources/xcgrapher/Generated.swift

build: configure
	swift build -c release --disable-sandbox

install: build
	install "$(buildroot)/xcgrapher" "$(bindir)"
	install "$(buildroot)/libXCGrapherPluginSupport.dylib" "$(libdir)"
	install "$(buildroot)/libXCGrapherModuleImportPlugin.dylib" "$(libdir)"
	install_name_tool -change "$(buildroot)/libXCGrapherPluginSupport.dylib" "$(libdir)/libXCGrapherPluginSupport.dylib" "$(bindir)/xcgrapher"

uninstall:
	rm -rf "$(bindir)/xcgrapher"
	rm -rf "$(libdir)/libXCGrapherPluginSupport.dylib"
	rm -rf "$(libdir)/libXCGrapherModuleImportPlugin.dylib"

clean:
	rm -rf .build
	rm Sources/xcgrapher/Generated.swift

.PHONY: build install uninstall clean configure
