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
BUILD_FILES =  configsnap additional.conf configsnap.help2man LICENSE README.md
BUILD_FILES += MAINTAINERS.md NEWS

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
OUT_DIR := "${HOME}/output"
DIST := $(shell python -c "import platform; print(platform.linux_distribution()[0])")
DEB_DIST := "xenial"

RPM_TOPDIR := $(shell rpm -E '%{_topdir}')
RPM_SPECDIR := $(shell rpm -E '%{_specdir}')
RPM_SRCDIR := $(shell rpm -E '%{_sourcedir}')
RPM_RPMDIR := $(shell rpm -E '%{_rpmdir}')
SRPM_RPMDIR := $(shell rpm -E '%{_srcrpmdir}')

.PHONY: rpm dev variables clean pre_clean req_files ${BUILD_FILES}

all: variables

el6 el7 fedora: ${BUILD_FILES}
	@echo "Building release ${VERSION}_${RELEASE} for $@"
	mkdir -p ${BUILD_ROOT}/$@/${BUILD_DIR}
	for file in $(BUILD_FILES); do \
		cp $$file ${BUILD_ROOT}/$@/${BUILD_DIR}/$$file; \
		done
	cd ${BUILD_ROOT}/$@ \
		&& tar -czvf ${VERSION}.tar.gz ${BUILD_DIR} \
		&& cp ${VERSION}.tar.gz ${RPM_SRCDIR}/
	cp ${NAME}.spec ${RPM_SPECDIR}/
	rpmbuild -ba ${RPM_SPECDIR}/${NAME}.spec

deb: ${BUILD_FILES}
	@echo "Building release ${VERSION}_${RELEASE} for $@"
	mkdir -p ${BUILD_ROOT}/$@/${BUILD_DIR}
	for file in $(BUILD_FILES); do \
		cp $$file ${BUILD_ROOT}/$@/${BUILD_DIR}/$$file; \
		done
	tar -C ${BUILD_ROOT}/$@ -czf ${BUILD_ROOT}/$@/${NAME}_${VERSION}.orig.tar.gz ${BUILD_DIR}
	cp -rpv debian ${BUILD_ROOT}/$@/${BUILD_DIR}
	cd ${BUILD_ROOT}/$@/${BUILD_DIR} \
		&& debchange -M --create --package ${NAME} --force-distribution -D ${DEB_DIST} -v ${VERSION}-${RELEASE} ${NAME} ${VERSION}-${RELEASE} \
		&& debuild -i -us -uc -b

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
