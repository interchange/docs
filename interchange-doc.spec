Summary: Interchange documentation
Name: interchange-doc
Version: 4.8.4
Release: 9
Vendor: Red Hat, Inc.
License: GPL
URL: http://interchange.redhat.com/
Packager: Interchange Development Team <interchange@redhat.com>
Source: http://interchange.redhat.com/pub/interchange/%{name}-%{version}.tar.gz
Group: Applications/Internet
BuildRoot: %{_tmppath}/%{name}-%version

%define ic_doc_dir %{_docdir}/interchange-%version


%description
Interchange is a powerful web application server focusing on ecommerce.
This package contains complete Interchange documentation in several
common document formats.


%prep


%setup

# man pages are part of base Interchange RPM, so don't include them
rm -f *.8
rm -f %{name}.spec


%build

if test -z "$RPM_BUILD_ROOT" -o "$RPM_BUILD_ROOT" = "/"
then
	echo "RPM_BUILD_ROOT has stupid value"
	exit 1
fi
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

# copy remaining files into build root
DOCDIR=$RPM_BUILD_ROOT%ic_doc_dir
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

[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT


%changelog

* Mon Apr 29 2002 Jon Jensen <jon@redhat.com>
- Delete unnecessary files in setup, not build phase.
- Build RPM for same arch as everything else, not noarch.

* Fri Jul 27 2001 Jon Jensen <jon@redhat.com>
- Install into /usr{/share}/doc/interchange-x.x.x instead of interchange-doc.
  No reason to have separate directories for the same kind of content.

* Thu Jul 26 2001 Jon Jensen <jon@redhat.com>
- Initial interchange-doc package.
