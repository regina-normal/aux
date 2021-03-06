#!/bin/sh
#
#  Customise the distribution post-install.
#


prefix=$1

if [ ! -d "${prefix}" ]; then
  echo "Serious error - the named directory doesn't exist."
  exit
fi

arch=i386
if [ $ARCH = "amd64" ] ; then
    arch=x86_64
fi

#
#  2.  Copy the cached .RPM files into the yum directory, so that
#     yum doesn't need to download them again.
#
echo "  Setting up DNF cache"
mkdir -p ${prefix}/var/cache/yum/core/packages/

for i in ${prefix}/*.rpm ; do
    cp -p $i ${prefix}/var/cache/yum/core/packages/
done

cp -pu $cache_dir/$dist.$ARCH/* ${prefix}/var/cache/yum/core/packages/


#
#  3.  Ensure that DNF has a working configuration file.
#

# use the mirror URL which was specified in rinse.conf
# A correct mirror URL does not contain /Packages on the end
mirror=`dirname $mirror`

# save original yum config
mv ${prefix}/etc/yum.repos.d ${prefix}/etc/yum.repos.d.orig

update_mirror=`echo "$mirror" | sed -e 's#/releases/#/updates/#' -e 's#/os$##'`
source_mirror=`echo "$mirror" | sed -e "s#/$arch/os#/source/tree#"`

mkdir ${prefix}/etc/yum.repos.d
cat > ${prefix}/etc/yum.repos.d/rinse.repo <<EOF
[main]
reposdir=/dev/null
logfile=/var/log/yum.log
gpgcheck=1
repo_gpgcheck=1

[fedora]
name=Fedora
baseurl=$mirror
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-$dist-$arch

[source]
name=Source
baseurl=$source_mirror
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-$dist-primary

[updates]
name=Updates
baseurl=$update_mirror
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-$dist-$arch
EOF

#
#  4.  Install some package via DNF
#

echo "  Bootstrapping DNF"

chroot ${prefix} /usr/bin/dnf -y install vim-minimal dhclient


# do not restore original yum config, because we do *not* want the
# updates repo that fedora enables by default.
# mv ${prefix}/etc/yum.repos.d ${prefix}/etc/yum.repos.d.init
# mv ${prefix}/etc/yum.repos.d.orig ${prefix}/etc/yum.repos.d

# ensure that https repositories work
chroot ${prefix} update-ca-trust


#
#  5.  Clean up
#
chroot ${prefix} /usr/bin/dnf clean all

umount ${prefix}/proc
umount ${prefix}/sys


#
#  6.  Remove the .rpm files from the prefix root.
#
rm -f ${prefix}/*.rpm ${prefix}/var/cache/yum/core/packages/*.rpm

find ${prefix} -name '*.rpmorig' -delete
find ${prefix} -name '*.rpmnew' -delete
