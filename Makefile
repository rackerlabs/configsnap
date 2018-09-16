# Makefile for configsnap
# Required packages:
#   RPM
#     rpmbuild
#     gawk
#
#   DEB
#     build-essential
#     devscripts
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
OUT_DIR := "/root/output"
DIST := $(shell python -c "import platform; print(platform.linux_distribution()[0])")
DEB_DIST := "xenial"

RPM_TOPDIR := $(shell rpm -E '%{_topdir}')
RPM_SPECDIR := $(shell rpm -E '%{_specdir}')
RPM_SRCDIR := $(shell rpm -E '%{_sourcedir}')
RPM_RPMDIR := $(shell rpm -E '%{_rpmdir}')

.PHONY: fedora debian variables clean req_files ${BUILD_PKGS}

all: variables

fedora: ${BUILD_PKGS}
	@echo "Building release ${VERSION}_${RELEASE} for $@"
	tar -C ${BUILD_ROOT} -czvf ${BUILD_ROOT}/${VERSION}.tar.gz ${BUILD_DIR}
	cp ${BUILD_ROOT}/${VERSION}.tar.gz ${RPM_SRCDIR}
	cp ${NAME}.spec ${RPM_SPECDIR}
	rpmbuild -ba ${RPM_SPECDIR}/${NAME}.spec
	cp ${RPM_RPMDIR}/noarch/${NAME}-${VERSION}-${RELEASE}*rpm ${OUT_DIR}

debian: ${BUILD_PKGS}
	@echo "Building release ${VERSION}_${RELEASE} for $@"
	tar -C ${BUILD_ROOT} -czf ${BUILD_ROOT}/${NAME}_${VERSION}.orig.tar.gz ${BUILD_DIR}
	cp -rpv building/debian ${BUILD_ROOT}/${BUILD_DIR}
	cd ${BUILD_ROOT}/${BUILD_DIR} && debchange -M --package ${NAME} --force-distribution -D ${DEB_DIST} -v ${VERSION}-${RELEASE} ${NAME} ${VERSION}-${RELEASE}
	cd ${BUILD_ROOT}/${BUILD_DIR} && debuild -i -us -uc -b
	cp ${BUILD_ROOT}/${NAME}_${VERSION}-${RELEASE}*deb ${OUT_DIR}

${BUILD_PKGS}: pre_clean
	install -D -p $@ ${BUILD_ROOT}/${BUILD_DIR}/$@

pre_clean:
	$(RM) -r ${BUILD_ROOT}/${BUILD_DIR}

variables:
	@echo "DIST:  		${DIST}"
	@echo "NAME:  		${NAME}"
	@echo "VERSION: 	${VERSION}"
	@echo "RELEASE: 	${RELEASE}"
	@echo "COMMIT:  	${COMMIT}"
	@echo "DATE:  		${DATE}"
	@echo "DATELONG:  	${DATELONG}"
	@echo "BUILD_DIR:  	${BUILD_DIR}"
	@echo "RPM_TOPDIR:	${RPM_TOPDIR}"
	@echo "RPM_SPECDIR:	${RPM_SPECDIR}"
	@echo "RPM_SRCDIR:	${RPM_SRCDIR}"

clean:
	$(RM) -r ${BUILD_ROOT}


# vim: noet:
