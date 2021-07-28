#
# spec file for package rpm-config-SUSE
#
# Copyright (c) 2020 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           rpm-config-SUSE
Version:        1
Release:        3.61.1
Summary:        SUSE specific RPM configuration files
License:        GPL-2.0-or-later
Group:          System/Packages
Source:         %{name}-%{version}.tar.gz
Patch0:         bab-suse-macros-os153.patch

# RPM owns the directories we need
Requires:       rpm

BuildArch:      noarch
#!BuildIgnore:  rpm-config-SUSE

%description
This package contains the RPM configuration data for the SUSE Linux
distribution family.

%prep
%setup -q
%patch0 -p0

%build
# Set up the SUSE Linux version macros
sed -e 's/@suse_version@/%{?suse_version}%{!?suse_version:0}/' \
    -e 's/@sles_version@/%{?sles_version}%{!?sles_version:0}/' \
    -e 's/@ul_version@/%{?ul_version}%{!?ul_version:0}/' \
    -e '/@is_opensuse@%{?is_opensuse:nomatch}/d' \
    -e 's/@is_opensuse@/%{?is_opensuse}%{!?is_opensuse:0}/' \
  < suse_macros.in > suse_macros

%install
# Install SUSE vendor macros and rpmrc
mkdir -p %{buildroot}%{_rpmconfigdir}/suse
cp -a suse_macros %{buildroot}%{_rpmconfigdir}/suse/macros

# Install vendor dependency generators
cp -a fileattrs %{buildroot}%{_rpmconfigdir}
cp -a scripts/* %{buildroot}%{_rpmconfigdir}
cp -a macros.d %{buildroot}%{_rpmconfigdir}

%files
%license COPYING
%doc README.md
%{_rpmconfigdir}/suse/
%{_rpmconfigdir}/macros.d/macros.*
%{_rpmconfigdir}/fileattrs/*
%{_rpmconfigdir}/brp-suse
%{_rpmconfigdir}/firmware.prov
%{_rpmconfigdir}/sysvinitdeps.sh
# kmod deps
%{_rpmconfigdir}/find-provides.ksyms
%{_rpmconfigdir}/find-requires.ksyms
%{_rpmconfigdir}/find-supplements.ksyms

%changelog
* Tue Jan 26 2021 mls@suse.de
- Add missing fileattrs/modulesload.attr file to generate requires
  for modules-load.d entries [jsc#SLE-7692]
* Mon Jan 25 2021 mls@suse.de
- Backport find-*.ksyms fixes from Factory [jsc#SLE-7692]:
  * move modinfo and modprobe commands
  * generate kernel module requires for module-load.d files
  * use "if kernel" for modules-load.d requires
  * fix version handling in kernel-uname-r requires
  * fix awk gensub warning
- changed files: find-provides.ksyms, find-requires.ksyms
* Tue Dec  8 2020 mls@suse.de
- Initial split of RPM vendor configuration from rpm package
  [jsc#SLE-17074]
