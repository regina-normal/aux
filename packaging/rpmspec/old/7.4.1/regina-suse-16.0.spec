Name: regina-normal
Summary: Mathematical software for low-dimensional topology
Version: 7.4.1
Release: lp160.1
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
BuildRequires: doxygen
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: glibc-devel
BuildRequires: gmp-devel
BuildRequires: graphviz-devel
BuildRequires: libstdc++-devel
BuildRequires: libxml2-devel
BuildRequires: libxslt-tools
BuildRequires: lmdb-devel
BuildRequires: pkg-config
BuildRequires: python3-devel
BuildRequires: qt6-base-devel
BuildRequires: qt6-svg-devel
BuildRequires: sed
BuildRequires: shared-mime-info
BuildRequires: zlib-devel

Prereq: /sbin/ldconfig

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

%prep
%setup -n regina-%{version}

%build
export CFLAGS=$RPM_OPT_FLAGS
export CXXFLAGS=$RPM_OPT_FLAGS
export LDFLAGS="-Wl,-Bsymbolic-functions $LDFLAGS"
mkdir build
cd build

cmake \
  -DDISABLE_RPATH=1 -DCMAKE_INSTALL_PREFIX=/usr \
  -DPACKAGING_MODE=1 \
  -DBUILD_INFO="Upstream openSUSE Leap 16.0 package" \
  -DREGINA_KVSTORE=lmdb \
  -DGRAPHVIZ_DYNAMIC_PLUGINS=1 \
  ..

%make_jobs

# The debug symbols in regina's python module are so enormous that my VMs
# run out of space.  Honestly, 2GB should be enough for a package build...
/usr/bin/strip "`pwd`/python/regina/engine.so"

LD_LIBRARY_PATH="`pwd`/engine:$LD_LIBRARY_PATH" make %{?_smp_mflags} VERBOSE=1 test ARGS=-V

%install
pushd build
%makeinstall
popd

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

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
%{_mandir}/*/*
%{_prefix}/lib/python3.13/site-packages/regina/

%changelog
* Tue Nov 25 2025 Ben Burton <bab@debian.org> 7.4.1
- New upstream release.
- Python and gcc versions are now back to the openSUSE defaults,
  since with openSUSE Leap 16.0 these defaults are finally modern.

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
- The openSUSE 15.6 package now uses Python 3.12, not the default Python 3.6.

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

* Sat May 16 2009 Ben Burton <bab@debian.org> 4.6
- New upstream release.

* Tue Oct 28 2008 Ben Burton <bab@debian.org> 4.5.1
- New upstream release.
- Now requires kdegraphics3-pdf, which provides an embedded viewer for
  Regina's new PDF packets.

* Sun Jun 29 2008 Ben Burton <bab@debian.org> 4.5 (SuSE 11.0)
- Packaging the 4.5 release (May 2008) for SuSE 11.0.
- Note that regina-normal needs to be built against boost 1.34.1-42.2 (or
  later) from the updates repository, since the boost packages originally
  shipped with SuSE 11.0 are broken.  See
  https://bugzilla.novell.com/show_bug.cgi?id=401964 for details.

* Sat May 17 2008 Ben Burton <bab@debian.org> 4.5
- New upstream release.

* Sun Nov 25 2007 Ben Burton <bab@debian.org> 4.4
- New upstream release.
- Removed MPI-enabled utilities from packages, since this causes hassles
  for ordinary desktop users who need to hunt down MPICH dependencies.

* Sun Feb 4 2007 Ben Burton <bab@debian.org> 4.3.1
- Packaging the 4.3.1 release (May 2006) for SuSE 10.2.
- Reenabled Python scripting for SuSE 10.1 and 10.2, since SuSE has
  fixed their boost packages once more.

* Mon Mar 27 2006 Ben Burton <bab@debian.org> 4.3
- New upstream release.
- Python scripting is again disabled because SuSE 10.0's boost packages
  are broken (https://bugzilla.novell.com/show_bug.cgi?id=137558).
  SuSE claims that this will be fixed in SuSE 10.1.

* Sun Sep 18 2005 Ben Burton <bab@debian.org> 4.2.1
- New upstream release.

* Thu Jul 7 2005 Ben Burton <bab@debian.org> 4.2
- New upstream release.
- Reenabled Python scripting for SuSE >= 9.2.
- Note that regina-normal now includes MPI support.  These packages are
  built against the MPICH implementation of MPI with the ch-p4 device.

* Sun Jul 25 2004 Ben Burton <bab@debian.org> 4.1.3
- New upstream release.
- Built against an updated popt from YaST online updates.  The earlier
  popt packages from SuSE used an incorrect soname (libpopt.so.1).  The
  updated popt packages fix this (they now use libpopt.so.0).  Because
  this bugfix from SuSE changes the soname, regina-normal will require
  the updated popt package, and will no longer be able to use the
  original popt from SuSE 9.1.

* Sun Jun 27 2004 Ben Burton <bab@debian.org> 4.1.2
- Initial packaging using SuSE 9.1.
- Python scripting is initially disabled because of bugs in SuSE 9.1's
  C++ compiler (SuSE applies patches to g++ that inadvertently break
  Boost.Python).  For a fuller explanation, see:
  http://mail.python.org/pipermail/c++-sig/2004-June/007561.html
