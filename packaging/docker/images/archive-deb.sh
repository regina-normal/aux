#!/bin/bash
set -e

if [ -e /etc/os-release ]; then
  source /etc/os-release
  suite="$VERSION_CODENAME"
  if [ -z "$suite" ]; then
    # Some ancient releases (up to debian jessie) did not set VERSION_CODENAME.
    case "$VERSION_ID" in
      7 ) suite=wheezy ;;
      8 ) suite=jessie ;;
      16.04 ) suite=xenial ;;
      15.10 ) suite=wily ;;
      15.04 ) suite=vivid ;;
      14.10 ) suite=utopic ;;
      14.04 ) suite=trusty ;;
      13.10 ) suite=saucy ;;
      13.04 ) suite=raring ;;
      12.10 ) suite=quantal ;;
      * ) echo "ERROR: Could not deduce suite from /etc/os-release"; exit 1 ;;
    esac
  fi
else
  # Some _very_ ancient releases (up to debian squeeze and ubuntu precise)
  # did not provide /etc/os-release at all.
  issue=`cat /etc/issue`
  case "$issue" in
    'Debian GNU/\s 3.0 '* ) suite=woody ;;
    'Debian GNU/Linux 3.1 '* ) suite=sarge ;;
    'Debian GNU/Linux 4.'* ) suite=etch ;;
    'Debian GNU/Linux 5.'* ) suite=lenny ;;
    'Debian GNU/Linux 6.'* ) suite=squeeze ;;
    'Ubuntu 12.04 '* ) suite=precise ;;
    * ) echo "ERROR: Could not deduce suite from /etc/issue"; exit 1 ;;
  esac
fi

# aptstyle: indicates how we present our sources.list.
#
# Options:
#
# - unified : use regina's unified archive (dists/, pool/, etc.), with a
#   deb822-style *.sources that supports Signed-By with individual fingerprints.
#   Individual fingerprints *possibly* introduced with apt 1.8 (but not sure).
#
# - unifiednokey : use regina's unified archive (dists/, pool/, etc.), with a
#   deb822-style *.sources that only supports Signed-By with an entire keyring.
#   Unified archive introduced in April 2021, shortly after regina 6.0.1.
#
# - standalone : use regina's legacy standalone suite-specific archives, with a
#   deb822-style *.sources that only supports Signed-By with an entire keyring.
#   Full support for deb822 introduced with apt 1.1.
#
# - standaloneline : use regina's legacy standalone suite-specific archives,
#   with a *.list holding individual apt-lines that only need regina's new key.
#   Assumes /root/regina-key.asc is present (this will be given to apt-key).
#
# - none : a debian or ubuntu distribution for which there was no separate
#   regina package repository (typically because the version of regina that it
#   shipped remained current for the lifetime of that distribution).
#
# - embryonic : a debian distribution that dates back to before regina ever
#   appeared in a formal debian release.  Whatever regina packages _did_ exist
#   were part of sid (and in some cases part of contrib, not main), which means
#   the binaries are probably gone forever.
#
# Note: for legacy standalone suite-specific archives, we will source these
# from a different location (currently mirrored at UQ), since p.d.o uses a
# new SSL root certificate that ancient distros cannot verify.  The specific
# error (e.g., seen on quantal, even with trusty's ca-certificates installed):
#
#   gnutls_handshake() failed: A TLS fatal alert has been received.
#
# Some legacy standalone archives were originally signed with the old key
# (1024-bit DSA).  These have since been double-signed with both keys, using
# --digest-algo to force a SHA256 hash (since different digest algorithms may
# mean only the first signature is recognised by gpg).  With apt < 1.2.12, this
# double signing gives a harmless warning if only one public key is available.
aptstyle=

case "$suite" in
  # Ancient debian:
  woody ) aptstyle=embryonic ;;
  sarge ) aptstyle=none ;;
  etch ) aptstyle=none ;;
  lenny ) aptstyle=none ;;
  squeeze ) aptstyle=standaloneline ;;
  wheezy ) aptstyle=standaloneline ;;
  jessie ) aptstyle=standaloneline ;;
  stretch ) aptstyle=standalone ;;
  # Ancient ubuntu LTS:
  bionic ) aptstyle=unifiednokey ;;
  xenial ) aptstyle=standalone ;;
  trusty ) aptstyle=standaloneline ;;
  precise ) aptstyle=standaloneline ;;
  # Ancient ubuntu short-term:
  eoan ) aptstyle=none ;;
  disco ) aptstyle=standalone ;;
  cosmic ) aptstyle=standalone ;;
  artful ) aptstyle=standalone ;;
  zesty ) aptstyle=standalone ;;
  yakkety ) aptstyle=standalone ;;
  wily ) aptstyle=none ;;
  vivid ) aptstyle=standaloneline ;;
  utopic ) aptstyle=standaloneline ;;
  saucy ) aptstyle=standaloneline ;;
  raring ) aptstyle=standaloneline ;;
  quantal ) aptstyle=standaloneline ;;
  # Default:
  * ) aptstyle=unified ;;
esac

echo "Setting up repository for $suite, APT style : $aptstyle"

if [ "$aptstyle" = none ]; then
  echo "Regina was installed in $suite only via the main distro repositories."
  echo "There is no separate regina repository that needs to be added."
  src=
elif [ "$aptstyle" = unified ]; then
  src=/etc/apt/sources.list.d/regina.sources
  cat > "$src" <<__END__
X-Repolib-Name: Regina
Types: deb deb-src
URIs: https://people.debian.org/~bab/regina
Suites: $suite
Components: main
Signed-By:
  /usr/share/keyrings/debian-keyring.gpg
  519A0009FB50255DDB4E889270A6BEDF542D38D9
__END__
elif [ "$aptstyle" = unifiednokey ]; then
  src=/etc/apt/sources.list.d/regina.sources
  cat > "$src" <<__END__
X-Repolib-Name: Regina
Types: deb deb-src
URIs: https://people.debian.org/~bab/regina
Suites: $suite
Components: main
Signed-By: /usr/share/keyrings/debian-keyring.gpg
__END__
elif [ "$aptstyle" = standalone ]; then
  src=/etc/apt/sources.list.d/regina.sources
  cat > "$src" <<__END__
X-Repolib-Name: Regina
Types: deb deb-src
URIs: https://people.smp.uq.edu.au/BenjaminBurton/archive/apt
Suites: $suite/
Signed-By: /usr/share/keyrings/debian-keyring.gpg
__END__
elif [ "$aptstyle" = standaloneline ]; then
  src=/etc/apt/sources.list.d/regina.list
  apt-key add /root/regina-key.asc
  cat > "$src" <<__END__
deb https://people.smp.uq.edu.au/BenjaminBurton/archive/apt $suite/
deb-src https://people.smp.uq.edu.au/BenjaminBurton/archive/apt $suite/
__END__
elif [ "$aptstyle" = embryonic ]; then
  echo 'ERROR: Regina was never part of this formal debian release.'
  exit 1
else
  echo 'ERROR: Unknown APT style'
  exit 1
fi

if [ -n "$src" ]; then
  echo --------------------
  cat "$src"
  echo --------------------
fi
