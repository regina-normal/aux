Build freshly-updated rolling releases from older snapshot versions.

The rolling/* images should be rebuilt regularly, whereas the base
snapshot/* images can happily remain fixed.

For debian bullseye:
  - Run as root, from ../bab/:
      ./mkimage.sh -t snapshot/debian:bullseye debootstrap \
        --variant=buildd --arch=amd64 bullseye
      ./mkimage.sh -t snapshot/debian:bullseye_i386 debootstrap \
        --variant=buildd --arch=i386 bullseye
  - Run as user, from this directory:
      docker build -t rolling/debian:bullseye \
        -f debian-bullseye-amd64.Dockerfile .
      docker build -t rolling/debian:bullseye_i386 \
        -f debian-bullseye-i386.Dockerfile .

