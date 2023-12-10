#!/bin/bash
set -e

certsuite="$1"
if [ -z "$certsuite" ]; then
  echo "Usage: $0 <suite_for_certificates>"
  exit 1
fi

echo "Adding certificates from $certsuite..."

cat > /etc/apt/sources.list.d/cert.list <<__END__
deb http://old-releases.ubuntu.com/ubuntu $certsuite-security main
deb-src http://old-releases.ubuntu.com/ubuntu $certsuite-security main
__END__

cat > /etc/apt/preferences.d/cert.prefs <<__END__
Package: *
Pin: release a=$certsuite-security
Pin-Priority: 100

Package: ca-certificates
Pin: release a=$certsuite-security
Pin-Priority: 800
__END__

apt-get update
apt-cache policy ca-certificates
apt-get install ca-certificates

# Remove the new sources, so we don't accidentally drag anything else in that
# we didn't want.
rm /etc/apt/sources.list.d/cert.list
rm /etc/apt/preferences.d/cert.prefs
