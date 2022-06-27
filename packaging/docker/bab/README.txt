
To build the bab/fedora:* and bab/opensuse:* images, run the corresponding
scripts from this directory, passing the fedora/opensuse version number:

  ./fedora 36
  ./opensuse 15.4
  ...

To build the bab/debian:* and bab/ubuntu:* images, run commands of the
following type as root from this directory (substituting the correct
distribution and architecture):

  ./mkimage.sh -t bab/debian:bullseye debootstrap --arch=amd64 bullseye
  ./mkimage.sh -t bab/ubuntu:focal_i386 debootstrap --arch=i386 focal
  ...

---------------------------------------------------------------------------

To prepare a debian host machine for building and using these images:

- fix root's .bashrc to ensure that /sbin and /usr/sbin are on the path,
  if this has not already been done

- set up a backports source in /etc/apt/sources.list, and fix priorities in
  /etc/apt/preferences, so that we have access to a more recent debootstrap
- apt-get install debootstrap zstd
- apt-get install debian-keyring (should already be present)
- manually install a recent ubuntu-keyring package from an ubuntu mirror

- apt-get install docker.io
- add the ordinary user to the docker group, and log out / log in again

- add the APT source: deb https://people.debian.org/~bab/rinse unstable/
- apt-get install rinse
- for newer distros, add extra package lists in /etc/rinse/*.packages,
  mirror locations in /etc/rinse/rinse.conf, and post-install scripts in
  /usr/lib/rinse/

---------------------------------------------------------------------------

Example /etc/apt/sources.list:

deb http://deb.debian.org/debian/ bullseye main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye main contrib non-free

deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free

deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free

deb http://deb.debian.org/debian/ bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-backports main contrib non-free

---------------------------------------------------------------------------

Example /etc/apt/preferences (default priority is 500):

Package: *
Pin: release a=bullseye-backports
Pin-Priority: 100

Package: *
Pin: release a=unstable
Pin-Priority: 100

Package: *
Pin: release a=experimental
Pin-Priority: 50

Package: debootstrap
Pin: release a=bullseye-backports
Pin-Priority: 800

