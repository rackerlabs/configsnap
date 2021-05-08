# Makefile for configsnap
# Required packages:
#   RPM
#     rpmbuild
#
#   DEB
#     build-essential
#     devscripts
#
# package details
NAME = "configsnap"
BUILD_FILES =  configsnap additional.conf configsnap.help2man LICENSE README.md
BUILD_FILES += MAINTAINERS.md NEWS

SHELL = /bin/bash

# package info
UPSTREAM = "https://github.com/rackerlabs/$(NAME).git"
VERSION := $(shell git tag -l | sort -V | tail -n 1)
RELEASE := $(shell perl -nle 'print $$& while m{^Release:\s+\K[0-9]+}g' $(NAME).spec)
COMMIT = $(shell git log --pretty=format:'%h' -n 1)
DATE = $(shell date +%Y-%m-%d)
DATELONG = $(shell date +%Y-%m-%dT%H:%M:%S%z)

# build info
BUILD_ROOT := "BUILD"
BUILD_DIR := "$(NAME)-$(VERSION)"
PATCH_DIR = $(CURDIR)/patches
OS := $(shell uname)
ifeq ($(OS), Darwin)
        DIST := "MacOS"
else
        DIST := $(shell lsb_release -si)
        DIST_VER := $(shell lsb_release -sr | cut -d '.' -f1)
endif
DIST_DIR := $(DIST)$(DIST_VER)

ifeq ($(DIST), $(filter $(DIST), Fedora CentOS))
        RPM_TOPDIR := $(shell rpm -E '%{_topdir}')
        RPM_SPECDIR := $(shell rpm -E '%{_specdir}')
        RPM_SRCDIR := $(shell rpm -E '%{_sourcedir}')
        #RPM_RPMDIR := $(shell rpm -E '%{_rpmdir}')
        #RPM_SRPMDIR := $(shell rpm -E '%{_srcrpmdir}')
endif

ifeq ($(DIST), Debian)
        DEB_DIST := $(shell lsb_release -sc)
endif

.PHONY: deb rpm variables setup-build-dir prepare-patches clean ${BUILD_FILES}

all: variables

rpm: prepare-patches
	@echo "Building release $(VERSION)_$(RELEASE) for $(DIST_DIR)"
	cd $(BUILD_ROOT)/$(DIST_DIR) && \
		tar -czvf $(VERSION).tar.gz $(BUILD_DIR) && \
		cp $(VERSION).tar.gz $(RPM_SRCDIR)/
	cp $(NAME).spec $(RPM_SPECDIR)/
	rpmbuild -ba $(RPM_SPECDIR)/$(NAME).spec

deb: prepare-patches
	@echo "Building release $(VERSION)_$(RELEASE) for $(DIST_DIR)"
	tar -C $(BUILD_ROOT)/$(DIST_DIR) -czf $(BUILD_ROOT)/$(DIST_DIR)/$(NAME)_$(VERSION).orig.tar.gz $(BUILD_DIR)
	cp -rpv debian $(BUILD_ROOT)/$(DIST_DIR)/$(BUILD_DIR)
	cd $(BUILD_ROOT)/$(DIST_DIR)/$(BUILD_DIR) && \
		debchange -M --create --package $(NAME) --force-distribution -D $(DEB_DIST) -v $(VERSION)-$(RELEASE) $(NAME) $(VERSION)-$(RELEASE) && \
		debuild -i -us -uc -b


prepare-patches: setup-build-dir
ifeq ($(DIST)$(DIST_VER), CentOS7)
	git apply --directory $(BUILD_ROOT)/$(DIST_DIR)/$(BUILD_DIR) $(PATCH_DIR)/001-python-exec.patch
endif

setup-build-dir: $(BUILD_FILES)
	rm -rf $(BUILD_ROOT)/$(DIST_DIR)
	for file in $(BUILD_FILES); do \
		install -D -T $$file $(BUILD_ROOT)/$(DIST_DIR)/$(BUILD_DIR)/$$file; \
	done

clean:
	shopt -s nullglob && \
	rm -f -r $(CURDIR)/$(BUILD_ROOT)/*

variables:
	@echo "OS:              $(OS)"
	@echo "DIST:            $(DIST)"
	@echo "DIST_VER:        $(DIST_VER)"
	@echo "NAME:            $(NAME)"
	@echo "VERSION:         $(VERSION)"
	@echo "RELEASE:         $(RELEASE)"
	@echo "COMMIT:          $(COMMIT)"
	@echo "DATE:            $(DATE)"
	@echo "DATELONG:        $(DATELONG)"
	@echo "BUILD_DIR:       $(BUILD_DIR)"
ifeq ($(DIST), $(filter $(DIST), Fedora CentOS))
	@echo "RPM_TOPDIR:      $(RPM_TOPDIR)"
	@echo "RPM_SPECDIR:     $(RPM_SPECDIR)"
	@echo "RPM_SRCDIR:      $(RPM_SRCDIR)"
endif

# vim: noet:
