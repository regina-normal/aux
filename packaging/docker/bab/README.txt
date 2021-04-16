
To build the bab/fedora:* and bab/opensuse:* images, run the corresponding
scripts (fedora-32.sh, opensuse-15.2.sh, etc.) from this directory.

To build the bab/debian:* and bab/ubuntu:* images, run commands of the
following type as root from this directory (substituting the correct
distribution and architecture):

  ./mkimage.sh -t bab/debian:buster debootstrap --arch=amd64 buster
  ./mkimage.sh -t bab/ubuntu:groovy_i386 debootstrap --arch=i386 groovy
  ...

