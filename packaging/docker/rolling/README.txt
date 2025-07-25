Build and continue to update rolling releases.


DEBIAN SID
----------

To build the first image (only needs to be done once):
  - docker build -t rolling/debian:sid -f debian-sid-init.Dockerfile .

To update the existing image (should be done periodically):
  - docker build --no-cache -t rolling/debian:sid -f debian-sid-update.Dockerfile .

Each update builds on the previous update, so these should not be done
very frequently (otherwise the docker image history will become enormous).


ARCH LINUX
----------

This is a special case, since there is no past fixed release that we can
use as our starting point.

To build an initial snapshot/arch image (only needs to be done once):
  - follow the manual instructions in arch-setup.txt.

To convert the snapshot into an up-to-date image (should be done periodically):
  - docker build --no-cache -t rolling/arch -f arch.Dockerfile .

Here the updates always build directly from snapshot, so they can be done as
often as you like.  From time to time it is probably worth deleting everything
and creating a fresh snapshot from a newer starting point.


FORTHCOMING DEBIAN / UBUNTU RELEASES
------------------------------------

These are images for "real" releases of debian or ubuntu that are still being
finalised (e.g., debian testing).

Here we begin with a snapshot/DIST:VERSION image and then update this
with a single rolling/DIST:VERSION image.  The rolling images can be
rebuilt regularly (since they build directly on the snapshot), and the
base snapshot image can remain fixed.  Once the distribution is properly
released, they should all be removed and replaced with a more typical
"fixed release" docker image as we do for older distributions.

To create the initial snapshot, run as root from the directory ../bare/ :
  - ./mkimage.sh -t snapshot/DIST:VERSION debootstrap --arch=amd64 VERSION
  - ./mkimage.sh -t snapshot/DIST:VERSION_i386 debootstrap --arch=i386 VERSION

To create the subsequent up-to-date image, run from this directory as user bab:
  - docker build --no-cache -t rolling/DIST:VERSION -f DIST-VERSION.Dockerfile .
  - docker build --no-cache -t rolling/DIST:VERSION_i386 -f DIST-VERSION-i386.Dockerfile .

Currently (DIST, VERSION) must be (debian, trixie).
