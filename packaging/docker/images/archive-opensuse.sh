#!/bin/bash
set -e

if [ -e /etc/os-release ]; then
  source /etc/os-release
  release="$VERSION_ID"
  if [ -z "$release" ]; then
    echo "ERROR: Could not deduce OS version from /etc/os-release"; exit 1 ;;
  fi
else
  echo "ERROR: Could not deduce OS version: missing /etc/os-release"; exit 1 ;;
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

src=/root/regina.repo
  cat > "$src" <<__END__
[regina]
name=Regina
baseurl=https://people.debian.org/~bab/rpm/regina/opensuse/$release/
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
