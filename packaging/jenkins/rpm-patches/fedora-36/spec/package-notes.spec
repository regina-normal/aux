## START: Set by rpmautospec
## (rpmautospec version 0.2.5)
%define autorelease(e:s:pb:) %{?-p:0.}%{lua:
    release_number = 14;
    base_release_number = tonumber(rpm.expand("%{?-b*}%{!?-b:1}"));
    print(release_number + base_release_number - 1);
}%{?-e:.%{-e*}}%{?-s:.%{-s*}}%{?dist}
## END: Set by rpmautospec

Name:           package-notes
Version:        0.4
Release:        %autorelease
Summary:        Generate a linker script to insert .note.package section

%global forgeurl https://github.com/systemd/package-notes
%forgemeta

License:        CC0
URL:            %{forgeurl}
Source0:        %{forgesource}

Source1:        generate-rpm-note.sh
Source2:        macros.package-notes-srpm

BuildArch:      noarch
BuildRequires:  python3-devel
Requires:       python3dist(simplejson)

%description
This package provides a generator of linker scripts that insert a section with
an ELF note with a JSON payload that describes the package the binary was built
for.

%package srpm-macros
Summary:        %{summary}

%description srpm-macros
RPM macros to inject a linker script into link flags and a helper to generate
a script that inserts a section with an ELF note with a JSON payload that
describes the package the binary was built for.

%prep
%autosetup

%build
# nothing to do

%install
install -Dt %{buildroot}%{_bindir}/ generate-package-notes
install -m0644 -Dt %{buildroot}%{_mandir}/man1/ debian/generate-package-notes.1

# A partial reimplementation without Python
install -Dt %{buildroot}%{_rpmconfigdir}/ %{SOURCE1}
install -m0644 -Dt %{buildroot}%{_rpmmacrodir}/ %{SOURCE2}

%files
%{_bindir}/generate-package-notes
%{_mandir}/man1/generate-package-notes.1*

%files srpm-macros
%{_rpmconfigdir}/generate-rpm-note.sh
%{_rpmmacrodir}/macros.package-notes-srpm

%changelog
* Tue Jan 25 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-14
- Disable notes when clang toolchain is used on arm

* Mon Jan 24 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-13
- Disable notes with linkers other than bfd

* Mon Jan 24 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-12
- Add --insert-after param to the note generation script

* Sat Jan 22 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-11
- Add %_package_note_linker and document everything (rhbz#2043178,
  rhbz#2043368)

* Sat Jan 22 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-10
- Allow unsetting %_package_note_readonly to drop the READONLY attribute

* Fri Jan 21 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-9
- Use %{buildsubdir} in %_package_note_file if defined

* Fri Jan 21 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-8
- Also voidify the macros if we're on a noarch build

* Fri Jan 21 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-7
- Use $RPM_PACKAGE_VERSION variable to refer to the package version

* Fri Jan 21 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-6
- Make _generate_package_note_file always recreate the file

* Fri Jan 21 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-5
- Conditionalize all macros on %_package_note_file being defined

* Thu Jan 20 2022 Fedora Release Engineering <releng@fedoraproject.org> 0.4-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Fri Jan 14 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-3
- Rename srpm macros file

* Fri Jan 14 2022 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-2
- Add package-notes-srpm-macros subpackage to configure rpm builds

* Tue Nov 16 2021 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> 0.4-1
- Version 0.4
