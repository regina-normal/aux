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
rpmkeys --import /root/regina-key.asc

echo "Setting up repository for Fedora $release"

src=/etc/yum.repos.d/regina.repo
  cat > "$src" <<__END__
[regina]
name=Regina
baseurl=https://people.debian.org/~bab/rpm/regina/fedora/$release/
enabled=1
repo_gpgcheck=0
gpgcheck=1
gpgkey=https://people.debian.org/~bab/regina-key.txt
__END__

echo --------------------
cat "$src"
echo --------------------
