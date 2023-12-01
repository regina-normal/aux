This directory contains the scripts, instructions and docker files used
to create the many different docker images that we use.

The initial work to get a distro/release/arch combination off the ground
happens in bare/ (for fixed releases) and rolling/ (for rolling releases
such as debian sid, or arch).  The scripts in these directories create docker
images with tags of the form bare/<distro>:<release>.

The subsequent work to make the images usable all happens in images/.
There is a do-everything script (images/build) which generates many different
types of image.  The images are related as follows:

bare/* : minimal bare-bones installations of various GNU/Linux distributions
 |
 \- basic/* : adds a few extra tools that make it feasible to tinker
     |
     \- pkgdev/* : adds essential tools for building packages
     |   |
     |   \- regina/* : adds all software required for building regina
     |
     \- desktop/* : a full desktop environment for users
     |
     \- archive/* : gives access to historical versions of regina

---------------------------------------------------------------------------
SETTING UP A DOCKER HOST MACHINE
---------------------------------------------------------------------------

To prepare a debian/stable host machine for building and using these images:

- fix root's .bashrc to ensure that /sbin and /usr/sbin are on the path,
  if this has not already been done

- apt-get install debootstrap zstd curl rpm
- apt-get install debian-keyring (should already be present)
- manually install a recent ubuntu-keyring package from an ubuntu mirror
- add extra symlinks in /usr/share/debootstrap/scripts/ for newer debian or
  ubuntu releases

- apt-get install docker.io
- add the ordinary user to the docker group, and log out / log in again

- for newer RPM-based distros, remember to add extra package lists in
  rinse/packages/

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

