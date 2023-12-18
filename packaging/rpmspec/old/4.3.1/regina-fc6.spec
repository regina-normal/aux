# Known to work for:
# - Fedora Core 6

Name: regina-normal
Summary: 3-manifold topology software with normal surface support
Version: 4.3.1
Release: 1.%{_vendor}
License: GPL
# I wish there were a more sane group (like Applications/Mathematics).
Group: Applications/Engineering
Source: http://prdownloads.sourceforge.net/regina/regina-%{version}.tar.gz
URL: http://regina.sourceforge.net/
Patch: regina-lam.patch
Packager: Ben Burton <bab@debian.org>
BuildRoot: %{_tmppath}/%{name}-buildroot

Requires: kdelibs
Requires: kdebase
Requires: python
Conflicts: regina

BuildRequires: boost-devel
BuildRequires: cppunit-devel
BuildRequires: doxygen
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: glibc-devel
BuildRequires: gmp-devel
BuildRequires: kdelibs-devel >= 3.2
BuildRequires: lam-devel
BuildRequires: libaio-devel
BuildRequires: libselinux-devel
BuildRequires: libstdc++-devel
BuildRequires: libxml2-devel
BuildRequires: popt
BuildRequires: python-devel
BuildRequires: qt-devel >= 3.2
BuildRequires: zlib-devel

Prereq: /sbin/ldconfig

%description
Regina is a suite of mathematical software for 3-manifold topologists.
It focuses upon the study of 3-manifold triangulations and includes
support for normal surfaces and angle structures.

Highlights of Regina include triangulation analysis and simplification,
census creation and normal surface enumeration.  It offers embedded
Python scripting giving full access to the calculation engine.

%prep
%setup -n regina-%{version}
%patch

%build
unset QTDIR || : ; . /etc/profile.d/qt.sh
FLAGS="$RPM_OPT_FLAGS -DNDEBUG -DNO_DEBUG"
export CFLAGS="$FLAGS"
export CXXFLAGS="$FLAGS"
./configure --disable-debug --mandir=%{_mandir}
make
make check

%install
rm -rf $RPM_BUILD_ROOT
make install-strip DESTDIR=$RPM_BUILD_ROOT

# Delete unnecessary static libraries.
rm -f $RPM_BUILD_ROOT%{_libdir}/libregina-kdecommon.a
rm -f $RPM_BUILD_ROOT%{_libdir}/regina/python/regina.a
rm -f $RPM_BUILD_ROOT%{_libdir}/kde3/libreginapart.a

# Delete library files that can cause unnecessary dependencies.
rm -f $RPM_BUILD_ROOT%{_libdir}/libregina-kdecommon.la
rm -f $RPM_BUILD_ROOT%{_libdir}/libregina-kdecommon.so

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc AUTHORS.txt
%doc CHANGES.txt
%doc HIGHLIGHTS.txt
%doc LICENSE.txt
%doc README.MPI
%docdir %{_docdir}/HTML/en/regina
%docdir %{_datadir}/regina/engine-docs
%{_bindir}/*
%{_includedir}/regina
%{_libdir}/libregina*
# Make sure we don't ship unwanted static libs by accident.
%{_libdir}/kde3/libreginapart.la
%{_libdir}/kde3/libreginapart.so
%{_libdir}/regina/python/regina.la
%{_libdir}/regina/python/regina.so
%{_docdir}/HTML/en/regina
%{_datadir}/applications/kde/*
%{_datadir}/apps/regina
%{_datadir}/apps/reginapart
%{_datadir}/icons/*/*/*/*
%{_datadir}/man/*/*
%{_datadir}/mimelnk/*/*
%{_datadir}/regina
%{_datadir}/services/*

%changelog
* Fri May 5 2006 Ben Burton <bab@debian.org> 4.3.1
- New upstream release.

* Mon Mar 27 2006 Ben Burton <bab@debian.org> 4.3
- New upstream release.

* Sun Sep 18 2005 Ben Burton <bab@debian.org> 4.2.1
- New upstream release.

* Thu Jul 7 2005 Ben Burton <bab@debian.org> 4.2
- New upstream release.
- Note that regina-normal now includes MPI support.  These packages are
  built against the LAM implementation of MPI.

* Sun Jul 25 2004 Ben Burton <bab@debian.org> 4.1.3
- New upstream release.

* Fri Jun 11 2004 Ben Burton <bab@debian.org> 4.1.2
- Initial packaging using Fedora Core 2.
