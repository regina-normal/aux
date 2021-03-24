This directory contains the scripts, instructions and docker files used
to create the various bab/* and regina/* docker images.

The bab/* images are minimal installations of various GNU/Linux distributions;
for debian/ubuntu these also include essential build tools.

The regina/* images extend these to include all of the software necessary to
build regina.

All images were built on a debian/bullseye system, with the help of
debootstrap and rinse (both of which need patches):

- The debootstrap patches are simply adding newer ubuntu distributions
  (groovy, hirsute, ...); this just involves creating symlinks
  groovy -> gutsy, hirsute -> gutsy, ... in /usr/share/debootstrap/scripts/ .

- The rinse patches are detailed in the rinse/ subdirectory.

