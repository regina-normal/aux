Patches required for rinse to support newer fedora releases:

--------------------------------------------------------------------------

Add the following lines to /etc/rinse/rinse.conf (changing the mirrors if required):

[fedora-32]
# mirror       = http://download.fedoraproject.org/pub/fedora/linux/releases/32/Everything/x86_64/os/Packages/
mirror       = http://fedora.mirror.digitalpacific.com.au/linux/releases/32/Everything/x86_64/os/Packages/

[fedora-33]
# mirror       = http://download.fedoraproject.org/pub/fedora/linux/releases/33/Everything/x86_64/os/Packages/
mirror       = http://fedora.mirror.digitalpacific.com.au/linux/releases/33/Everything/x86_64/os/Packages/

--------------------------------------------------------------------------

Add the *.packages files from this directory to /etc/rinse/ .

These were created as described on the rinse manpage: start a VM with the
corresponding distribution installed and run:

  repoquery --requires --resolve --recursive dnf yum rpm | \
    perl -pe 's/(.*)-.*?-.*?$/$1/g' | sort -u \
    egrep -v 'glibc-all-langpacks|glibc-langpack-'

--------------------------------------------------------------------------

Beneath /usr/lib/rinse, create a directory for each new distribution
with a corresponding post-install.sh.  For fedora-32 and fedora-33, the
correct post-install script is included here (just install it as
fedora-32/post_install.sh, and make fedora-33/post_install.sh a symlink).

