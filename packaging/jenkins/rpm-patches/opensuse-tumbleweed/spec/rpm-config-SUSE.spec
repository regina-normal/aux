#
# spec file for package rpm-config-SUSE
#
# Copyright (c) 2020 SUSE LLC
# Copyright (c) 2018 Neal Gompa <ngompa13@gmail.com>.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           rpm-config-SUSE
Version:        0.g64
Release:        1.2
Summary:        SUSE specific RPM configuration files
License:        GPL-2.0-or-later
Group:          Development/Tools/Building
URL:            https://github.com/openSUSE/rpm-config-SUSE
Source:         %{name}-%{version}.tar.xz

# RPM owns the directories we need
Requires:       rpm

BuildArch:      noarch
#!BuildIgnore:  rpm-config-SUSE

%description
This package contains the RPM configuration data for the SUSE Linux
distribution family.

%prep
%setup -q

%build
# Set up the SUSE Linux version macros
sed -e 's/@suse_version@/%{?suse_version}%{!?suse_version:0}/' \
    -e 's/@sles_version@/%{?sles_version}%{!?sles_version:0}/' \
    -e 's/@ul_version@/%{?ul_version}%{!?ul_version:0}/' \
    -e '/@is_opensuse@%{?is_opensuse:nomatch}/d' \
    -e 's/@is_opensuse@/%{?is_opensuse}%{!?is_opensuse:0}/' \
    -e '/@leap_version@%{?leap_version:nomatch}/d' \
    -e 's/@leap_version@/%{?leap_version}%{!?leap_version:0}/' \
%if 0%{?is_opensuse}
    -e '/@sle_version@%{?sle_version:nomatch}/d' \
    -e 's/@sle_version@/%{?sle_version}%{!?sle_version:0}/' \
%else
    -e '/@sle_version@/d' \
%endif
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
%{_rpmconfigdir}/locale.prov
# kmod deps
%{_rpmconfigdir}/find-provides.ksyms
%{_rpmconfigdir}/find-requires.ksyms
%{_rpmconfigdir}/find-supplements.ksyms

%changelog
* Mon Oct 26 2020 lnussel@suse.de
- Update to version 0.g64:
  * Define a global %%_firmwaredir
  * macros.obs: remove unused macros
* Mon Aug 31 2020 lnussel@suse.de
- Update to version 0.g60:
  * Add VPATH macros from RH/Fedora to make upstream Meson macros work
  * Don't limit locale match to /usr/share/locale
* Sun Mar 22 2020 kukuk@suse.com
- Update to version 0.g56:
  * Remove grep and diffutils from fillup_prereq, replace coreutils with file requires
  * Avoid overwriting files that didn't actually change on disk
* Thu Jan 30 2020 dimstar@opensuse.org
- Update to version 0.g52:
  * Make deprecated %%install_info not fail when used within if/fi construct
* Fri Dec 27 2019 opensuse-packaging@opensuse.org
- Update to version 0.g50:
  * Add missing changelog entries and fix authors
  * Add ldconfig_scriptlets macros for RH/Fedora compatibility
  * move %%install_info to file triggers (boo#1152105)
* Wed Nov  6 2019 opensuse-packaging@opensuse.org
- Update to version 0.g45:
  * Use -flto=auto for _lto_cflags for now
* Tue Oct 29 2019 opensuse-packaging@opensuse.org
- Update to version 0.g44:
  * Sync specfile changes
  * Add _lto_cflags to suse_macros for now
* Wed Oct 16 2019 opensuse-packaging@opensuse.org
- Update to version 0.g42:
  * Add __perl macro until the perl package provides it
  * Add requires_eq and requires_ge macros
* Wed Sep 25 2019 lnussel@suse.de
- Update to version 0.g40:
  * locale.prov: also work with -locale packages
  * locale.prov: discard input in error case
* Thu Sep 19 2019 lnussel@suse.de
- Update to version 0.g37:
  * Add macros for locale provides
* Wed Aug 28 2019 opensuse-packaging@opensuse.org
- Update to version 0.g35:
  * Add _distconfdir as /usr/etc
  * find-provides.ksyms, find-requires.ksyms: cleanup kernel version handling (bsc#1145601).
  * find-requires.ksyms: fix matching of uninstalled files (bsc#1145601).
  * add changes
* Thu Aug 15 2019 msuchanek@suse.de
- Update to version 0.g32:
  * find-provides.ksyms, find-requires.ksyms: cleanup kernel version handling (bsc#1145601).
  * find-requires.ksyms: fix matching of uninstalled files (bsc#1145601).
* Wed Aug 14 2019 dimstar@opensuse.org
- Update to version 0.g29:
  * find-requires.ksyms: Move modinfo and modprobe before the ksym dependency code.
* Tue Jun 18 2019 Takashi Iwai <tiwai@suse.de>
- Add support for compressed firmware files
- Add support for compressed kernel modules
* Fri May 17 2019 Martin Wilck <mwilck@suse.com>
- macros: avoid emitting bashisms into scriptlets
* Thu Apr 25 2019 Michal Suchanek <msuchanek@suse.de>
- Provide/require modules with .ko suffix (jsc#SLE-3853)
* Wed Apr 10 2019 kukuk@suse.de
- Don't use bash syntax in %%install_info macro [bsc#1131957]
* Tue Mar  5 2019 Michal Suchanek <msuchanek@suse.de>
- Add automatic kernel module requires for module-load.d files
  (FATE#326579).
* Wed Jan 30 2019 mls@suse.de
- Added macros.d/macros.initrd
* Tue Dec 18 2018 Michal Suchanek <msuchanek@suse.de>
- Add kmod(module) provides to kernel and KMPs (FATE#326579).
* Wed Oct 24 2018 msuchanek@suse.de
- Fix superfluous TOC. dependency (bsc#1113100)
* Fri Oct 12 2018 Jan Engelhardt <jengelh@inai.de>
- Update to new snapshot 0.g8
  * %%lang_package: fix "empty Requires:" being emitted
  * %%user_group_add: do not ignore errors from useradd
* Wed Sep  5 2018 Jan Engelhardt <jengelh@inai.de>
- Update to new snapshot 0.g5
  * Modified %%lang_package to not inject -n when -r is given.
* Sat Aug 18 2018 schwab@suse.de
- Break build cycle with rpm
* Mon Feb 26 2018 Neal Gompa <ngompa13@gmail.com>
- Initial split of RPM vendor configuration from rpm package
