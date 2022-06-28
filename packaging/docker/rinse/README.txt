Patches required for rinse to support newer fedora and opensuse releases:

- Extra lines for the mirrors in /etc/rinse/rinse.conf
- A new package list in /etc/rinse/ (*.packages)
- A new post-install script in /usr/lib/rinse/ (usually a symlink to the
  same post-install script from an earlier version of the same distribution)

These patches are already rolled into Ben's rinse package for recent fedora
and opensuse releases (suitable for use with debian bullseye/bookworm/sid):

  deb https://people.debian.org/~bab/rinse unstable/

--------------------------------------------------------------------------

To create *.packages files for new fedora/opensuse releases:

For fedora, these are created as described on the rinse manpage: start a VM
with the corresponding distribution installed and run:

  repoquery --requires --resolve --recursive dnf yum rpm | \
    perl -pe 's/(.*)-.*?-.*?$/$1/g' | sort -u | \
    egrep -v 'glibc-all-langpacks|glibc-langpack-'

For opensuse, these are created by using the script opensuse-core.pl
(found in this directory) to extract a full recursive dependency list for
rpm, zypper, gzip, grep, sed, xz, and util-linux.  We include gzip, sed, grep
and xz in this list because otherwise opensuse may try to install the busybox
variants of these packages, which causes problems for rpm-build later on.

--------------------------------------------------------------------------

Subdirectories:

patched/ - changes that have already been incorporated into Ben's rinse package

