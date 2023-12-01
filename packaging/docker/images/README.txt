To build each docker image, run from this directory:

./build <imagetype> <release> [<arch>]

Examples:

  ./build basic bookworm
  ./build desktop xenial i386
  ./build desktop 39
  ./build desktop 25 i386
  ./build desktop 15.5

Arguments:

  <imagetype>
      Indicates what kind of docker image to build.  This must be one of:
        - basic (for a minimal but usable bare-bones environment);
        - desktop (for a full graphical desktop environment).

  <release>
      Indicates which release of which GNU/Linux distribution to use.
      This must be:
        - a debian/ubuntu release codename (e.g., bullseye or jammy); or
        - a fedora release version (e.g., 39); or
        - an opensuse release version (e.g., 15.5).

  <arch>
      Indicates which guest architecture to use, if this is different from
      the host architecture.  In practice, if this is provided at all, it
      would typically be i386.  The architecture here must match an explicit
      suffix on the corresponding docker image tags.

