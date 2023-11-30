The rinse binary here is currently synced with upstream rinse 4.1.
It has been patched to support verifying signatures on the downloaded RPMs,
improves support for different architectures, and works around issues that
arise in some older distributions.

Upstream rinse has the following copyright notice:

  Copyright 2007-2010 Steve Kemp <steve@steve.org.uk>
  Copyright 2011-2022 Thomas Lange <lange@cs.uni-koeln.de>

  License:

  This program is free software, you can redistribute it and/or modify it under
  the same terms as Perl itself.

  Perl is distributed under licenses:

      a) the GNU General Public License as published by the Free Software
         Foundation; either version 1, or (at your option) any later
         version, or

      b) the "Artistic License" which comes with Perl.

Dependencies: wget libterm-size-perl libwww-perl perl rpm cpio rpm2cpio

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
fedora-release{,-common,-identity-basic}.  We should probably
revisit this latter decision at a later date to see if it still makes sense.

For fedora <= 25: dnf repoquery does not support --recursive, and so instead
we use the script fedora-old.pl (found in this directory).

For opensuse, package lists are created by using the script opensuse-core.pl
(found in this directory) to extract a full recursive dependency list for
rpm, zypper, gzip, grep, sed, xz, and util-linux.  We include gzip, sed, grep
and xz in this list because otherwise opensuse may try to install the busybox
variants of these packages, which causes problems for rpm-build later on.
We then manually edit the package list to use cracklib-dict-small instead of
cracklib-dict-full.

--------------------------------------------------------------------------

Regarding postinst scripts:

In postinst/, each script corresponds to the _first_ release where it can be
used.  So, for example, postinst/fedora-22 should be used for fedora >= 22
but not fedora <= 21.

Currently we only support fedora 22 onwards (which appears to be the first
release that introduced dnf); if we ever need to go further back then there
are scripts that can be pulled from old versions of rinse.

The postinst scripts here are pulled from rinse and patched:

- The fedora script is patched to avoid the final dnf update (since regina's
  build images manage updates separately, after modifying the list of active
  repositories).  It also adds some %postinst tasks that were needed but not
  run (such as ldconfig).

- The opensuse script is made more robust by adding strict GPG checking to
  zypper repositories and also individual RPMs.  It also adds some %postinst
  tasks that were needed but not run (such as migrating the rpmdb to a new
  location and fixing the baseproduct symlink), makes better use of cached
  downloads, and disables (but does not remove) the backports/update repos
  if present.

