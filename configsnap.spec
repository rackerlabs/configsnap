Name:          configsnap
Version:       0.12
Release:       1%{?dist}
Summary:       Record and compare system state
License:       ASL 2.0
URL:           https://github.com/rackerlabs/%{name}
Source0:       https://github.com/rackerlabs/%{name}/archive/%{version}.tar.gz
BuildArch:     noarch
BuildRequires: python2-devel
BuildRequires: help2man

%description
configsnap records important system state information and can optionally compare
with a previous state and identify changes

%prep
%setup -q

%build
help2man --include=%{name}.help2man --no-info ./%{name} -o %{name}.man

%install
mkdir -p %{buildroot}%{_bindir} \
  %{buildroot}%{_mandir}/man1 \
  %{buildroot}%{_sysconfdir}/%{name}
install -p -m 0755 %{name} %{buildroot}%{_bindir}
install -p -m 0644 %{name}.man %{buildroot}%{_mandir}/man1/%{name}.1
install -p -m 0600 additional.conf %{buildroot}%{_sysconfdir}/%{name}/additional.conf

%files
%defattr(-,root,root,-)
%{!?_licensedir:%global license %doc}
%license LICENSE
%doc README.md
%doc NEWS
%doc MAINTAINERS.md
%{_mandir}/man1/%{name}.1*
%{_bindir}/%{name}
%{_sysconfdir}/%{name}

%changelog
* Mon Jun 12 2017 Piers Cornwell <piers.cornwell@rackspace.co.uk> 0.12-1
- Record Pacemaker status
- Don't raise exception if command doesn't exist
- Add alternative path for lspci
- Allow MySQL show databases to fail
- Record PHP state
- Record iptables rules
- Documented tested platforms
- Optional custom collection

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
