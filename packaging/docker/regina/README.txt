To build each docker image, run from this directory:

docker build -t regina/DIST:VERSION -f DIST-VERSION-amd64.Dockerfile .
docker build -t regina/DIST:VERSION_i386 -f DIST-VERSION-i386.Dockerfile .

Here DIST should be debian/fedora/opensuse/ubuntu, and VERSION should be a
debian/ubuntu release name (buster/bionic/focal/groovy/etc.) or a
fedora/opensuse version (32, 33, 15.2, etc.).
