Build freshly-updated rolling releases from older snapshot versions.

To build each docker image, run from this directory:

docker build -t rolling/DIST:VERSION -f DIST-VERSION-amd64.Dockerfile .
docker build -t rolling/DIST:VERSION_i386 -f DIST-VERSION-i386.Dockerfile .

Here DIST should be debian/fedora/opensuse/ubuntu, and VERSION should be a
debian/ubuntu release name (bullseye/sid/hirsute/etc.) or a
fedora/opensuse version (33, tumbleweed, etc.).
