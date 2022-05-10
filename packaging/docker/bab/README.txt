
To build the bab/fedora:* and bab/opensuse:* images, run the corresponding
scripts (fedora-32.sh, opensuse-15.2.sh, etc.) from this directory.

To build the bab/debian:* and bab/ubuntu:* images, run commands of the
following type as root from this directory (substituting the correct
distribution and architecture):

  ./mkimage.sh -t bab/debian:bullseye debootstrap --arch=amd64 bullseye
  ./mkimage.sh -t bab/ubuntu:focal_i386 debootstrap --arch=i386 focal
  ...

