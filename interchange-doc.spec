Summary: Interchange documentation
Name: interchange-doc
Version: 4.7.7
Release: 1
Vendor: Red Hat, Inc.
Copyright: GPL
URL: http://interchange.redhat.com/
Packager: Interchange Development Team <interchange@redhat.com>
Source: http://interchange.redhat.com/pub/interchange/%{name}-%{version}.tar.gz
Group: Applications/Internet
Provides: %name
Obsoletes: %name
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%version

%description
Interchange is the most powerful free ecommerce system available today.
This package contains complete Interchange documentation in several common
document formats.


%define ic_doc_dir %{_docdir}/%{name}-%version


%prep


%setup


%build

if test -z "$RPM_BUILD_ROOT" -o "$RPM_BUILD_ROOT" = "/"
then
	echo "RPM_BUILD_ROOT has stupid value"
	exit 1
fi
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

# man pages are part of base Interchange RPM, so don't include them
rm -f *.8
rm -f %{name}.spec

# copy remaining files into build root
DOCDIR=$RPM_BUILD_ROOT%{_docdir}/%{name}-%version
mkdir -p $DOCDIR
tar cf - . | tar xf - -C $DOCDIR


%install


%pre


%files

%defattr(-, root, root)
%docdir %ic_doc_dir
%ic_doc_dir


%post


%preun


%clean

rm -f %filelist_main
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT


%changelog

* Thu Jul 26 2001 Jon Jensen <jon@redhat.com>
- Initial interchange-doc package.
