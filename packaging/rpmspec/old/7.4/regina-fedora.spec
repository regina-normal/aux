Name: regina-normal
Summary: Mathematical software for low-dimensional topology
Version: 7.4
Release: 1%{?dist}
License: GPL
# I wish there were a more sane group (like Applications/Mathematics).
Group: Applications/Engineering
Source: https://github.com/regina-normal/regina/releases/download/regina-%{version}/regina-%{version}.tar.gz
URL: http://regina-normal.github.io/
Packager: Ben Burton <bab@debian.org>
BuildRoot: %{_tmppath}/%{name}-buildroot

Requires: mimehandler(application/pdf)
Requires: python3
Conflicts: regina

BuildRequires: cmake
BuildRequires: desktop-file-utils
BuildRequires: doxygen
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: glibc-devel
BuildRequires: gmp-devel
BuildRequires: graphviz-devel
BuildRequires: libstdc++-devel
BuildRequires: libxml2-devel
BuildRequires: libxslt
BuildRequires: pkgconfig
BuildRequires: python3-devel
BuildRequires: qt6-qtbase-devel
BuildRequires: qt6-qtsvg-devel
BuildRequires: shared-mime-info
BuildRequires: tokyocabinet-devel
BuildRequires: zlib-devel

%patchlist
# No patches for now.

%description
Regina is a software package for 3-manifold and 4-manifold topologists,
with a focus on triangulations, knots and links, normal surfaces, and
angle structures.

For 3-manifolds, it includes high-level tasks such as 3-sphere recognition,
connected sum decomposition and Hakenness testing, comes with a rich
database of census manifolds, and incorporates the SnapPea kernel for
working with hyperbolic manifolds.  For 4-manifolds, it offers a range of
combinatorial and algebraic tools, plus support for normal hypersurfaces.
For knots and links, Regina can perform combinatorial manipulation,
compute knot polynomials, and work with several import/export formats.

Regina comes with a full graphical user interface, as well as Python bindings
and a low-level C++ programming interface.

%global debug_package %{nil}

%prep
%autosetup -v -p1 -n regina-%{version}

%build
mkdir -p %{_target_platform}
pushd %{_target_platform}

export QTDIR="%{_qt6_prefix}"
export PATH="%{_qt6_bindir}:$PATH"
export CFLAGS="${CFLAGS:--O2}"
export CXXFLAGS="${CXXFLAGS:--O2}"
export FFLAGS="${FFLAGS:--O2}"
cmake -DDISABLE_RPATH=1 -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_VERBOSE_MAKEFILE=ON -DPACKAGING_MODE=1 \
  -DPython_EXECUTABLE=/usr/bin/python3 \
  -DBUILD_INFO="Upstream Fedora %{fedora} package" \
  ..
popd

make %{?_smp_mflags} -C %{_target_platform}
make %{?_smp_mflags} -C %{_target_platform} test ARGS=-V

%install
rm -rf "$RPM_BUILD_ROOT"
make install/fast DESTDIR="$RPM_BUILD_ROOT" -C %{_target_platform}

desktop-file-validate \
  "$RPM_BUILD_ROOT%{_datadir}/applications/org.computop.Regina.desktop" ||:

%post
%?ldconfig
/usr/bin/update-desktop-database &> /dev/null ||:
/usr/bin/update-mime-database %{_datadir}/mime &> /dev/null ||:
/bin/touch --no-create %{_datadir}/icons/hicolor &> /dev/null ||:

%posttrans
/usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor &> /dev/null ||:

%postun
%?ldconfig
/usr/bin/update-desktop-database &> /dev/null ||:
/usr/bin/update-mime-database %{_datadir}/mime &> /dev/null ||:
if [ $1 -eq 0 ]; then
  /bin/touch --no-create %{_datadir}/icons/hicolor &> /dev/null ||:
  /usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor &> /dev/null ||:
fi

%clean
rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(-,root,root)
%doc CHANGES.txt
%doc HIGHLIGHTS.txt
%doc LICENSE.txt
%docdir %{_datadir}/regina/docs/en/regina
%docdir %{_datadir}/regina/docs/en/regina-xml
%docdir %{_datadir}/regina/engine-docs
%{_bindir}/*
%{_datadir}/applications/org.computop.Regina.desktop
%{_datadir}/icons/hicolor/*/*/*
%{_datadir}/metainfo/org.computop.regina.metainfo.xml
%{_datadir}/mime/packages/regina.xml
%{_datadir}/regina/
%{_includedir}/regina/
%{_libdir}/libregina-engine.so
%{_libdir}/libregina-engine.so.%{version}
%{_libexecdir}/regina/
%if 0%{?fedora} >= 41
%{_prefix}/lib/python3.13/site-packages/regina/
%else
%if 0%{?fedora} >= 39
%{_prefix}/lib/python3.12/site-packages/regina/
%else
%if 0%{?fedora} >= 37
%{_prefix}/lib/python3.11/site-packages/regina/
%else
%if 0%{?fedora} >= 35
%{_prefix}/lib/python3.10/site-packages/regina/
%else
%if 0%{?fedora} >= 33
%{_prefix}/lib/python3.9/site-packages/regina/
%else
%{_prefix}/lib/python3.8/site-packages/regina/
%endif
%endif
%endif
%endif
%endif
%{_mandir}/*/*

%changelog
* Tue Aug 26 2025 Ben Burton <bab@debian.org> 7.4
- New upstream release.

* Wed Jul 23 2025 Ben Burton <bab@debian.org> 7.3.1-3
- Update the previous doxygen patch, since it appears the relevant change
  (modules -> topics) happened in doxygen 1.9.8, not doxygen 1.10.

* Wed Jul 23 2025 Ben Burton <bab@debian.org> 7.3.1-2
- Backported some recent fixes from the repository:
  * Fixed the fact that GNOME does not recognise the GUI when it is running,
    which was causing a generic icon and window name to appear in the dock.
  * Added some compatibility patches from upstream to support graphviz >= 13
    and doxygen >= 1.10.

* Tue Jul 8 2025 Ben Burton <bab@debian.org> 7.3.1
- New upstream release.

* Tue May 9 2023 Ben Burton <bab@debian.org> 7.3-2
- Backported some recent fixes from the repository:
  * Fixed a bug where Link::resolve() would not clear calculated properties,
    which could result in incorrect link invariants being cached.
  * Fixed a memory leak in move assignment for triangulations.
  * Now builds under gcc 13.

* Sat Mar 18 2023 Ben Burton <bab@debian.org> 7.3
- New upstream release.

* Thu Oct 20 2022 Ben Burton <bab@debian.org> 7.2
- New upstream release.

* Fri Sep 30 2022 Ben Burton <bab@debian.org> 7.1
- New upstream release.

* Sun Dec 19 2021 Ben Burton <bab@debian.org> 7.0
- New upstream release.

* Fri Feb 12 2021 Ben Burton <bab@debian.org> 6.0.1
- New upstream release.

* Mon Jan 11 2021 Ben Burton <bab@debian.org> 6.0
- New upstream release.

* Wed Dec 23 2020 Ben Burton <bab@debian.org> 5.96
- New upstream release.

* Tue Sep 20 2016 Ben Burton <bab@debian.org> 5.1
- New upstream release.

* Tue Sep 20 2016 Ben Burton <bab@debian.org> 5.0
- New upstream release.

* Fri Aug 29 2014 Ben Burton <bab@debian.org> 4.96
- New upstream release.

* Sun Nov 10 2013 Ben Burton <bab@debian.org> 4.95
- New upstream release.

* Tue Sep 17 2013 Ben Burton <bab@debian.org> 4.94
- New upstream release.

* Tue May 29 2012 Ben Burton <bab@debian.org> 4.93
- New upstream release.

* Wed Mar 28 2012 Ben Burton <bab@debian.org> 4.92
- New upstream release.
- Ported from KDE4 to Qt4-only.

* Mon Sep 12 2011 Ben Burton <bab@debian.org> 4.90
- New upstream release.
- Ported from KDE3 to KDE4, and from autotools to cmake.

* Wed Jul 15 2009 Ben Burton <bab@debian.org> 4.6
- Built for Fedora 11, which was released last month.

* Sat May 16 2009 Ben Burton <bab@debian.org> 4.6
- New upstream release.

* Wed Dec 10 2008 Ben Burton <bab@debian.org> 4.5.1
- Built for Fedora 10, which was released last month.

* Tue Oct 28 2008 Ben Burton <bab@debian.org> 4.5.1
- New upstream release.
- It will help to have KPDF installed, which provides an embedded viewer
  for Regina's new PDF packets.  However, the regina-normal packages for
  Fedora do not list KPDF as a dependency.  This is because:
  + Fedora <= 8 only ships KPDF as part of the monolithic kdegraphics
    package, which is very large.
  + Fedora >= 9 does not ship KPDF at all, but instead focuses on its KDE 4
    successor.
  Regina can find other ways of viewing PDF packets; see Regina's PDF settings
  for details.

* Sat May 17 2008 Ben Burton <bab@debian.org> 4.5
- New upstream release.

* Sun Nov 25 2007 Ben Burton <bab@debian.org> 4.4
- New upstream release.
- Removed MPI-enabled utilities from packages, since this causes hassles
  for ordinary desktop users who need to hunt down LAM dependencies.

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
