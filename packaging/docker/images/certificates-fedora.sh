#!/bin/bash
set -e

echo "Installing newer certificates..."

# For now we hard-code the downloaded certificate package as coming from
# Fedora 25 (since the ca-certificates from Fedora 26 and above require a
# newer version of p11-kit which older fedoras do not have).
#
# We compare checksums directly instead of using signatures, since old fedoras
# do not have the fedora 25 signing keys installed.

certrpmfile=ca-certificates-2016.2.10-1.0.fc25.noarch.rpm
certrpmurl=http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/25/Everything/x86_64/os/Packages/c/$certrpmfile
certrpmsha256=72c41d5e587d1171215d87775aa057e2c0659e43de9791ce8b79d62bb90592ad

cd /root

wget "$certrpmurl"
if [ ! -e "$certrpmfile" ]; then
  echo "ERROR: Failed to download new ca-certificates RPM"
  exit 1
fi

foundsum=`sha256sum "$certrpmfile" | cut -f1 -d' '`
if [ "$foundsum" != "$certrpmsha256" ]; then
  echo "ERROR: Checksum mismatch:"
  echo "       Found:    $foundsum"
  echo "       Expected: $certrpmsha256"
  exit 1
fi

# rpm --checksig "$certrpmfile"
rpm -Uvh "$certrpmfile"
rm "$certrpmfile"
