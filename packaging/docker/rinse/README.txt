Patches required for rinse to support newer fedora and opensuse releases:

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

For fedora, these were created as described on the rinse manpage: start a VM
with the corresponding distribution installed and run:

  repoquery --requires --resolve --recursive dnf yum rpm | \
    perl -pe 's/(.*)-.*?-.*?$/$1/g' | sort -u | \
    egrep -v 'glibc-all-langpacks|glibc-langpack-'

--------------------------------------------------------------------------

Beneath /usr/lib/rinse, create a directory for each new distribution
containing a script post-install.sh.  These should be copies of:
- fedora-32 -> fedora_3x_post-install.sh
- fedora-33 -> fedora_3x_post-install.sh (can be a symlink into fedora-32)
- opensuse-15.2 -> opensuse_post-install.sh (replace the rinse version)
