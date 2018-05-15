Name:          configsnap
Version:       0.13
Release:       1%{?dist}
Summary:       Record and compare system state
License:       ASL 2.0
URL:           https://github.com/rackerlabs/%{name}
Source0:       https://github.com/rackerlabs/%{name}/archive/%{version}.tar.gz
# Changes the python shebang to python2
Patch0:        python_executable.patch
BuildArch:     noarch
BuildRequires: python2-devel
BuildRequires: help2man

%description
configsnap records important system state information and can optionally compare
with a previous state and identify changes

%prep
%setup -q
%patch0 -p0

%build
help2man --include=%{name}.help2man --no-info ./%{name} -o %{name}.man

%install
mkdir -p %{buildroot}%{_sbindir} \
  %{buildroot}%{_mandir}/man1 \
  %{buildroot}%{_sysconfdir}/%{name}
install -p -m 0755 %{name} %{buildroot}%{_sbindir}
install -p -m 0644 %{name}.man %{buildroot}%{_mandir}/man1/%{name}.1
install -p -m 0600 additional.conf %{buildroot}%{_sysconfdir}/%{name}/additional.conf

%files
%defattr(-,root,root,-)
%{!?_licensedir:%global license %doc}
%license LICENSE
%doc README.md
%doc NEWS
%doc MAINTAINERS.md
%config(noreplace) %{_sysconfdir}/%{name}/additional.conf
%{_mandir}/man1/%{name}.1*
%{_sbindir}/%{name}
%{_sysconfdir}/%{name}

%changelog
* Wed Feb 07 2018 Fedora Release Engineering <releng@fedoraproject.org> - 0.13-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Thu Aug 17 2017 Piers Cornwell <piers.cornwell@rackspace.co.uk> 0.13-1
- New option -a to create a tar archive of the output
- New option -w to overwrite existing output
- PEP8 fixes
- Modify check for PHP presence

* Wed Jul 26 2017 Fedora Release Engineering <releng@fedoraproject.org> - 0.12-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Mon Jun 12 2017 Piers Cornwell <piers.cornwell@rackspace.co.uk> 0.12-2
- Record Pacemaker status
- Don't raise exception if command doesn't exist
- Add alternative path for lspci
- Allow MySQL show databases to fail
- Record PHP state
- Record iptables rules
- Documented tested platforms
- Optional custom collection

* Fri Feb 10 2017 Fedora Release Engineering <releng@fedoraproject.org> - 0.11-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Wed Jan 25 2017 Christos Triantafyllidis <christos.triantafyllidis@rackspace.co.uk> 0.11-2
- Updated spec according to Fedora Guidelines

* Wed Dec 21 2016 Piers Cornwell <piers.cornwell@rackspace.co.uk> 0.11-1
- Renamed from getData to configsnap
- Backup grubenv for grub2
- Support for Fedora
- Added man page
- Record dm-multipath information
- Continue if lvm isn't present
- Allow PowerPath to be present, but with no LUNs

* Wed Jul 27 2016 Piers Cornwell <piers.cornwell@rackspace.co.uk> 0.10-1
- Initial public release, version 0.10

* Mon May 9 2016 Piers Cornwell <piers.cornwell@rackspace.co.uk> 0.9-1
- Initial standalone tagged release, version 0.9
