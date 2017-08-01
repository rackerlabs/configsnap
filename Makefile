pkg_name := "configsnap"

version := $(shell ./configsnap --version | awk '{print $$NF}')
release := "1"
version_release := ${version}-${release}
deb_dist := "xenial"

files := $(shell ls configsnap)

debsources:
	@which debchange >/dev/null && which dpkg-source >/dev/null || (echo "DEB build requires debchange and dpkg-source" && exit 1)
	@mkdir -p ${pkg_name}-${version}
	@cp -rp ${files} ${pkg_name}-${version}
	@tar -zcf ${pkg_name}_${version}.orig.tar.gz ${pkg_name}-${version}
	@cp -rpv debian ${pkg_name}-${version}
	@cd ${pkg_name}-${version}; debchange --create -M --package ${pkg_name} -v ${version_release} --force-distribution -D ${deb_dist} ${pkg_name} ${version_release}
	@dpkg-source -b ${pkg_name}-${version}
	@rm -rf ${pkg_name}-${version}
