#!/bin/bash
set -e

if [ -e /etc/os-release ]; then
  source /etc/os-release
  release="$VERSION_ID"
  if [ -z "$release" ]; then
    echo "ERROR: Could not deduce OS version from /etc/os-release"; exit 1
  fi
else
  echo "ERROR: Could not deduce OS version: missing /etc/os-release"; exit 1
fi

echo "Importing Regina's signing key..."
case "$release" in
  42.* )
    cp /root/regina-key.asc /var/lib/rpm/pubkeys/regina.key
    ;;
  * )
    rpmkeys --import /root/regina-key.asc
    ;;
esac

echo "Setting up repository for openSUSE $release"

opt=
case "$release" in
  42.* )
    # The certificates shipped with openSUSE 42.x are too old now, and
    # zypper can no longer verify the certificate from people.debian.org.
    opt='?ssl_verify=no'
    ;;
  * )
    ;;
esac

src=/root/regina.repo
cat > "$src" <<__END__
[regina]
name=Regina
baseurl=https://people.debian.org/~bab/rpm/regina/opensuse/$release/$opt
enabled=1
repo_gpgcheck=1
gpgcheck=1
gpgkey=https://people.debian.org/~bab/regina-key.txt
autorefresh=1
__END__

zypper addrepo "$src"
echo --------------------
cat "$src"
echo --------------------
rm -f "$src"

case "$release" in
  42.* )
    # It seems the only way for zypper to import the repository signing key is
    # to refresh the repositories with the --gpg-auto-import-keys flag.  Ugh.
    zypper -n --gpg-auto-import-keys refresh --force-download
    ;;
  * )
    ;;
esac
