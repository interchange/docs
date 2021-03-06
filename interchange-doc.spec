Summary: Interchange documentation
Name: interchange-doc
Version: 5.2.0
Release: 1
Vendor: Interchange Development Group
License: GPL
URL: http://www.icdevgroup.org/
Packager: Jon Jensen <jon@icdevgroup.org>
Source: http://www.icdevgroup.org/pub/interchange/%{name}-%{version}.tar.gz
Group: Applications/Internet
BuildRoot: %{_tmppath}/%{name}-%version

%define ic_doc_dir %{_docdir}/interchange-%version


%description
Interchange is a powerful web application server focusing on ecommerce.
This package contains complete Interchange documentation in several
common document formats.


%prep


%setup

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

* Wed May 05 2004 Jon Jensen <jon@icdevgroup.org>
- update for Interchange 5.2.0

* Mon Dec 15 2003 Jon Jensen <jon@icdevgroup.org>
- put manpages back since they're not in the base Interchange package anymore
- update for Interchange 5.0.1

* Mon Apr 29 2002 Jon Jensen <jon@redhat.com>
- Delete unnecessary files in setup, not build phase.
- Build RPM for same arch as everything else, not noarch.

* Fri Jul 27 2001 Jon Jensen <jon@redhat.com>
- Install into /usr{/share}/doc/interchange-x.x.x instead of interchange-doc.
  No reason to have separate directories for the same kind of content.

* Thu Jul 26 2001 Jon Jensen <jon@redhat.com>
- Initial interchange-doc package.
