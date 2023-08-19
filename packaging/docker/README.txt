This directory contains the scripts, instructions and docker files used
to create the various bab/*, regina/*, and other related docker images.

bab/* images are minimal installations of various GNU/Linux distributions.
 |
 \- user/* extend bab/* to include Regina's repositories (for Regina users).
 |
 \- pkgdev/* extend bab/* to include essential tools for building packages.
     |
     \- regina/* extend pkgdev/* to include all software for building regina.

---------------------------------------------------------------------------
SETTING UP A DOCKER HOST MACHINE
---------------------------------------------------------------------------

To prepare a debian/stable host machine for building and using these images:

- fix root's .bashrc to ensure that /sbin and /usr/sbin are on the path,
  if this has not already been done

- set up a backports source in /etc/apt/sources.list, and fix priorities
  for debootstrap in /etc/apt/preferences to use this source
- apt-get install debootstrap zstd curl
- apt-get install debian-keyring (should already be present)
- manually install a recent ubuntu-keyring package from an ubuntu mirror

- apt-get install docker.io
- add the ordinary user to the docker group, and log out / log in again

- add the APT source: deb https://people.debian.org/~bab/rinse unstable/
  and fix priorities for rinse in /etc/apt/preferences to use this source
- apt-get install rinse
- for newer distros, add extra package lists in /etc/rinse/*.packages,
  mirror locations in /etc/rinse/rinse.conf, and post-install scripts in
  /usr/lib/rinse/

Docker *may* need specialised configuration.  Around mid-2021 it was observed
that Fedora Rawhide would not allow the creation of threads (which meant that
curl, dnf, make and other tools all failed).  The problem was docker's default
seccomp profile, which blocked the clone3() syscall.  (This problem was *not*
observed when setting up a docker for the newly-released fedora 36 on arm64
a year later.)  If this problem does occur, then to resolve it:

- Copy the default seccomp profile (default.json) from the docker sources;
- Add clone3 to the list of allowed syscalls;
- Save the resulting profile as /etc/docker/seccomp.json;
- Create /etc/docker/daemon.json with the following contents:
    { "seccomp-profile": "/etc/docker/seccomp.json" }
- Restart the docker daemon.

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

deb https://people.debian.org/~bab/rinse unstable/
deb-src https://people.debian.org/~bab/rinse unstable/

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

Package: rinse
Pin: release a=unstable
Pin-Priority: 800

