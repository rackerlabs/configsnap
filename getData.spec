Name:           getData
Version:        0.10
Release:        1%{?dist}
Summary:        Record and compare system state

License:        ASL 2.0
URL:            https://github.com/rackerlabs/getData
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

%description
getData records important system state information and can optionally compare with a previous state and identify changes

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -m 755 getData %{buildroot}%{_bindir}

%files
%defattr(-,root,root,-)
%{_bindir}/getData

%changelog
* Wed Jul 27 2016 Piers Cornwell <piers.cornwell@rackspace.co.uk>
- Initial public release, version 0.10

* Mon May 9 2016 Piers Cornwell <piers.cornwell@rackspace.co.uk>
- Initial standalone tagged release, version 0.9
