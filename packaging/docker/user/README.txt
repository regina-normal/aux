To build each docker image, run from this directory:

./build <release> [<arch>]

Examples:

  ./build bookworm
  ./build xenial i386
  ./build 39
  ./build 25 i386

Specifically, <release> must be:
- a debian/ubuntu release codename (e.g., bullseye or jammy); or
- a fedora release version (e.g., 39).

If <arch> is provided, it must also be an explicit suffix on the docker image
tag. In practice this means that, if present, <arch> should be i386.
