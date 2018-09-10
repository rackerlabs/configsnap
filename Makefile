# Makefile for configsnap
# Required packages:
#   RPM
#     rpmbuild
#     gawk
#
#   DEB
#     build-essential
#     dpkg-buildpackage
#     gawk
#
# package details
NAME := "configsnap"
BUILD_PKGS =  configsnap additional.conf configsnap.help2man LICENSE README.md
BUILD_PKGS += MAINTAINERS.md NEWS

# package info
UPSTREAM := "https://github.com/rackerlabs/${NAME}.git"
VERSION := $(shell git tag -l | sort -V | tail -n 1)
RELEASE := $(shell gawk '/^Release:\s+/{print gensub(/%.*/,"","g",$$2)}' ${NAME}.spec)
COMMIT := $(shell git log --pretty=format:'%h' -n 1)
DATE := $(shell date --iso-8601)
DATELONG := $(shell date --iso-8601=seconds)

# build info
BUILD_ROOT := "BUILD"
BUILD_DIR := "${NAME}-${VERSION}"
DIST := $(shell python -c "import platform; print(platform.linux_distribution()[0])")

ifeq (${DIST},Fedora)
	RPM_TOPDIR := $(shell rpm -E '%{_topdir}')
	RPM_SPECDIR := $(shell rpm -E '%{_specdir}')
	RPM_SRCDIR := $(shell rpm -E '%{_sourcedir}')
endif

# testing if there is a valid release tag can't see this failing - it'll just
# pick up the previous one
ifeq (${RELEASE},)
	.PHONY: err
	ERR = $(error No release version found)
	err: ; $(ERR)
endif

.PHONY: fedora debian variables clean req_files ${BUILD_PKGS}

all: variables

fedora: req_files
	@echo "Building release ${VERSION}_${RELEASE} for $@"
	tar -C ${BUILD_ROOT} -czvf ${BUILD_ROOT}/${VERSION}.tar.gz ${BUILD_DIR}
	cp ${BUILD_ROOT}/${VERSION}.tar.gz ${RPM_SRCDIR}
	#rpmbuild -ba ${RPM_SPECDIR}/${NAME}.spec

debian: req_files
	tar -C ${BUILD_ROOT} -czf ${BUILD_ROOT}/${NAME}_${VERSION}.orig.tar.gz ${BUILD_DIR}
	cp -rpv debian ${BUILD_ROOT}/${BUILD_DIR}
	cd ${BUILD_ROOT} && debchange -M --package ${NAME} -v ${VERSION}-${RELEASE} ${NAME} ${VERSION}-${RELEASE}
	cd ${BUILD_ROOT}/${BUILD_DIR} && debuild -i -us -uc -b

req_files: ${BUILD_PKGS}
	install -D -p -t ${BUILD_ROOT}/${BUILD_DIR} $+

variables:
	@echo "DIST:  		${DIST}"
	@echo "NAME:  		${NAME}"
	@echo "VERSION: 	${VERSION}"
	@echo "RELEASE: 	${RELEASE}"
	@echo "COMMIT:  	${COMMIT}"
	@echo "DATE:  		${DATE}"
	@echo "DATELONG:  	${DATELONG}"
	@echo "BUILD_DIR:  	${BUILD_DIR}"
ifeq (${DIST},Fedora)
	@echo "RPM_TOPDIR:	${RPM_TOPDIR}"
	@echo "RPM_SPECDIR:	${RPM_SPECDIR}"
	@echo "RPM_SRCDIR:	${RPM_SRCDIR}"
endif

clean:
	$(RM) -r ${BUILD_ROOT}


# vim: noet:
