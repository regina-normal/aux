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
Release:        150400.12.41
Summary:        SUSE specific RPM configuration files
License:        GPL-2.0-or-later
Group:          System/Packages
Source:         %{name}-%{version}.tar.gz
# needed for jsc#SLE-20017
Source1:	macros.rpm415
Patch1:         bsc1190850-support-zstd-compressed-kernel-modules.patch
Patch2:         sle_version.diff
Patch3:         bsc1192160-rpm-config-SUSE-support-compressed-firmware-files.patch

# RPM owns the directories we need
Requires:       rpm

BuildArch:      noarch
#!BuildIgnore:  rpm-config-SUSE

%description
This package contains the RPM configuration data for the SUSE Linux
distribution family.

%prep
%setup -q
%autopatch -p1

%build
# Set up the SUSE Linux version macros
sed -e 's/@suse_version@/%{?suse_version}%{!?suse_version:0}/' \
    -e 's/@sles_version@/%{?sles_version}%{!?sles_version:0}/' \
    -e 's/@ul_version@/%{?ul_version}%{!?ul_version:0}/' \
    -e '/@is_opensuse@%{?is_opensuse:nomatch}/d' \
    -e 's/@is_opensuse@/%{?is_opensuse}%{!?is_opensuse:0}/' \
    -e 's/@sle_version@/%{?sle_version}%{!?sle_version:0}/' \
  < suse_macros.in > suse_macros

%install
# Install SUSE vendor macros and rpmrc
mkdir -p %{buildroot}%{_rpmconfigdir}/suse
cp -a suse_macros %{buildroot}%{_rpmconfigdir}/suse/macros

# Install vendor dependency generators
cp -a fileattrs %{buildroot}%{_rpmconfigdir}
cp -a scripts/* %{buildroot}%{_rpmconfigdir}
cp -a macros.d %{buildroot}%{_rpmconfigdir}
cp %{S:1}  %{buildroot}%{_rpmconfigdir}/macros.d/


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
* Mon Feb 14 2022 sweiberg@suse.com
- Remove definition of _distconfdir, as this should not be defined
  for SLE-15. Else this will conflict with our non-usr-merged
  environment and cause problems with transactional-update, openssh
  and other packages (bsc#1195679)
* Mon Nov 15 2021 qkzhu@suse.com
- Add bsc1192160-rpm-config-SUSE-support-compressed-firmware-files.patch:
  Backported from e4c04ac, the upcoming kernel will support the
  compressed firmware files, and this patch corresponds to that kernel
  change, fixing firmware.prov to deal with the xz-compressed firmware
  files as well (bsc#1192160).
* Thu Oct 28 2021 lnussel@suse.de
- backport %%sle_version in macros file from Factory (boo#1187214,
  sle_version.diff)
* Wed Oct  6 2021 josef.moellers@suse.com
- Support ZSTD compressed kernel modules
  [bsc#1190850,
  bsc1190850-support-zstd-compressed-kernel-modules.patch]
* Mon Aug  2 2021 fcrozat@suse.com
- Add macros.rpm415 to allow easy backport of Factory srpm
  [jsc#SLE-20017].
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
