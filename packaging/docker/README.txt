This directory contains the scripts, instructions and docker files used
to create the various bab/* and regina/* docker images.

The bab/* images are minimal installations of various GNU/Linux distributions.

The pkgdev/* images extend these to include essential tools for building
packages.

The regina/* images extend these further to include all of the software
necessary to build regina.

All images were built on a debian/bullseye system, with the help of
debootstrap and rinse (both of which need patches):

- The debootstrap patches are simply adding newer ubuntu distributions
  (groovy, hirsute, ...); this just involves creating symlinks
  groovy -> gutsy, hirsute -> gutsy, ... in /usr/share/debootstrap/scripts/ .

- The rinse patches are detailed in the rinse/ subdirectory.

Docker does need some specialised confirmation.  Around mid-2021 it was
observed that the Fedora Rawhide would not allow the creation of threads
(which meant that curl, dnf, make and other tools all failed).  The problem
was docker's default seccomp profile, which blocked the clone3() syscall.
To resolve this:

- Copy the default seccomp profile (default.json) from the docker sources;

- Add clone3 to the list of allowed syscalls;

- Save the resulting profile as /etc/docker/seccomp.json;

- Create /etc/docker/daemon.json with the following contents:

    { "seccomp-profile": "/etc/docker/seccomp.json" }

- Restart the docker daemon.

