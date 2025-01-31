##
## Copyright (c) 2018-2025 Stéphane Micheloud
##
## Licensed under the MIT License.
##
##############################################################################

TARGET ?= go

include ../Makefile.inc

PROJECT_NAME ?= $(shell basename $(CURDIR))

SOURCE_DIR  = src
TARGET_DIR  = target
TARGET_DOCS_DIR = $(TARGET_DIR)/docs

##############################################################################
## main rules

SOURCES = $(wildcard $(SOURCE_DIR)/Main.dfy)
TARGET_FILE = $(TARGET_DIR)/$(PROJECT_NAME)$(TARGET_EXT)
XXX_FILE = $(realpath $(TARGET_DIR)/.)/$(PROJECT_NAME)$(TARGET_EXT)

BUILD_OPTS = $(if $(filter native,$(TARGET)),,--target $(TARGET)) -output "$(XXX_FILE)"

all: build

build: $(TARGET_FILE)

$(TARGET_FILE): $(SOURCES)
	[ -d "$(TARGET_DIR)" ] || "$(MKDIR)" -p "$(TARGET_DIR)"
	PATH=$(PATH):$(GOROOT)/bin:$(GOBIN) && \
	"$(DAFNY)" build $(BUILD_OPTS) $(SOURCES)

clean:
	"$(RM)" -rf "$(TARGET_DIR)"

compile: build

run: build
	$(TARGET_FILE)

help:
	@$(ECHO) "Usage: make all|build|clean|doc|help|lint|run|test"
	@$(ECHO) ""
	@$(ECHO) "  Subcommands:"
	@$(ECHO) "    all    alias for build"
	@$(ECHO) "    build  compile Dafny source files"
	@$(ECHO) "    clean  delete generated files"
	@$(ECHO) "    doc    generate HTML documentation"
	@$(ECHO) "    help   print this help message"
	@$(ECHO) "    run    execute main program \"$(TARGET)\""

##############################################################################
## doc rules

RUSTDOC_OPTS=

doc:
	[ -d "$(TARGET_DOCS_DIR)" ] || $(MKDIR) -p "$(TARGET_DOCS_DIR)"
	"$(RUSTDOC)" $(RUSTDOC_OPTS)

##############################################################################
## lint rules

lint:
	"$(CARGO)" clippy

##############################################################################
## phony

.PHONY: all build clean doc help lint run

.SUFFIXES:
.SUFFIXES: .exe .rs
