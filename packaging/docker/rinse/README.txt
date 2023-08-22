The rinse binary here is currently synced with upstream rinse 4.1.

--------------------------------------------------------------------------

To create *.packages files for new fedora/opensuse releases:

For new fedora, we begin with the processs described on the rinse manpage
(almost) - start a VM with the corresponding distribution installed and run:

  dnf repoquery --disablerepo fedora-source \
    --requires --resolve --recursive dnf | \
    perl -pe 's/(.*)-.*?-.*?$/$1/g' | sort -u | \
    grep -E -v 'glibc-all-langpacks|glibc-langpack-'

Then add dnf (which is not included in the list), and strip out all
fedora-release-* and generic-release-*, except for
fedora-release{,-common,-server,-identity-server}.  We should probably
revisit this latter decision at a later date to see if it still makes sense.

For fedora <= 25: dnf repoquery does not support --recursive, and so we simply
pull the package listings from old versions of rinse.

For opensuse, package lists are created by using the script opensuse-core.pl
(found in this directory) to extract a full recursive dependency list for
rpm, zypper, gzip, grep, sed, xz, and util-linux.  We include gzip, sed, grep
and xz in this list because otherwise opensuse may try to install the busybox
variants of these packages, which causes problems for rpm-build later on.

--------------------------------------------------------------------------

Regarding postinst scripts:

In postinst/, each script corresponds to the _first_ release where it can be
used.  So, for example, postinst/fedora-22 should be used for fedora >= 22
but not fedora <= 21.

Currently we only support fedora 22 onwards (which appears to be the first
release that introduced dnf); if we ever need to go further back then there
are scripts that can be pulled from old versions of rinse.

Currently the fedora postinst scripts are pulled directly from rinse.
The opensuse scripts are patched to remove --gpg-auto-import-keys and
--no-gpg-checks options from calls to zypper.
