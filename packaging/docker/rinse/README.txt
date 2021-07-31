Patches required for rinse to support newer fedora and opensuse releases:

--------------------------------------------------------------------------

Add the following lines to /etc/rinse/rinse.conf (changing the mirrors if required):

[fedora-32]
# mirror       = http://download.fedoraproject.org/pub/fedora/linux/releases/32/Everything/x86_64/os/Packages/
mirror       = http://fedora.mirror.digitalpacific.com.au/linux/releases/32/Everything/x86_64/os/Packages/

[fedora-33]
# mirror       = http://download.fedoraproject.org/pub/fedora/linux/releases/33/Everything/x86_64/os/Packages/
mirror       = http://fedora.mirror.digitalpacific.com.au/linux/releases/33/Everything/x86_64/os/Packages/

[opensuse-15.3]
mirror.amd64 = http://download.opensuse.org/distribution/leap/15.3/repo/oss/x86_64/

[opensuse-tumbleweed]
mirror.amd64 = http://download.opensuse.org/tumbleweed/repo/oss/x86_64/

--------------------------------------------------------------------------

Add the *.packages files from this directory to /etc/rinse/ .

For fedora, these were created as described on the rinse manpage: start a VM
with the corresponding distribution installed and run:

  repoquery --requires --resolve --recursive dnf yum rpm | \
    perl -pe 's/(.*)-.*?-.*?$/$1/g' | sort -u | \
    egrep -v 'glibc-all-langpacks|glibc-langpack-'

For opensuse, these were created by using the script opensuse-core.pl
(found in this directory) to extract a full recursive dependency list for
rpm, zypper, gzip, sed, xz, and util-linux.  We include gzip, sed and xz
in this list because otherwise opensuse may try to install the busybox
variants of these packages, which causes problems for rpm-build later on.

--------------------------------------------------------------------------

Beneath /usr/lib/rinse, create a directory for each new distribution
containing a script post-install.sh.  These should be copies of:
- fedora-32 -> fedora_3x_post-install.sh
- fedora-33 -> fedora_3x_post-install.sh (can symlink into fedora-32)
- fedora-34 -> fedora_3x_post-install.sh (can symlink into fedora-32)
- opensuse-15.2 -> opensuse_post-install.sh (replace the rinse version)
- opensuse-15.3 -> opensuse_post-install.sh (can symlink into opensuse-15.2)
- opensuse-tumbleweed -> opensuse_tumbleweed_post-install.sh
