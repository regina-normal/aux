#!/bin/bash
set -e

certsuite="$1"
if [ -z "$certsuite" ]; then
  echo "Usage: $0 <suite_for_certificates>"
  exit 1
fi

echo "Adding certificates from $certsuite..."

certlist=/etc/apt/sources.list.d/cert.list
certprefs=/etc/apt/preferences.d/cert.prefs

arch=`uname -m`

# Add an extra APT source for $certsuite-security.
# Where this comes from (e.g., the main ubuntu servers / ports / etc.) depends
# on the underlying architecture.  We assume for the moment that the suite is
# still current (i.e., it lives on the main ubuntu archive/ports servers and
# not old-releases).
case "$arch" in
  aarch64 )
    cat > $certlist <<__END__
deb http://ports.ubuntu.com/ubuntu-ports $certsuite-security main
__END__
    ;;
  * )
    cat > $certlist <<__END__
deb http://archive.ubuntu.com/ubuntu $certsuite-security main
__END__
    ;;
esac

cat > $certprefs <<__END__
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
rm $certlist $certprefs
