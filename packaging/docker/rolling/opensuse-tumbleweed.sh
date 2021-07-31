#!/usr/bin/env bash
set -e

# TODO: Change these
tag=rolling/opensuse:tumbleweed
arch=amd64
distribution=opensuse-tumbleweed

dir="$(mktemp -d ${TMPDIR:-/var/tmp}/docker-mkimage.XXXXXXXXXX)"
rootfsDir="$dir/rootfs"
tarFile="$dir/rootfs.tar.xz"

echo '----- Bootstrapping distribution -----'

mkdir -p "$rootfsDir"
rinse --directory "$rootfsDir" --arch "$arch" --distribution "$distribution"

echo '----- Updating distribution -----'

chroot "$rootfsDir" zypper refresh
chroot "$rootfsDir" zypper update -y
chroot "$rootfsDir" zypper clean

echo '----- Removing /dev and /proc -----'

# Docker mounts tmpfs at /dev and procfs at /proc so we can remove them
rm -rf "$rootfsDir/dev" "$rootfsDir/proc"
mkdir -p "$rootfsDir/dev" "$rootfsDir/proc"

echo '----- Creating Dockerfile -----'

cat > "$dir/Dockerfile" <<EOF
FROM scratch
ADD $(basename "$tarFile") /
CMD ["/bin/bash"]
RUN echo '%vendor Regina' >> /etc/rpm/macros
EOF

echo '----- Bundling filesystem -----'

tar -c -f "$tarFile" --numeric-owner --auto-compress -C "$rootfsDir" --transform='s,^./,,' .
rm -rf "$rootfsDir"

echo '----- Building docker image -----'

docker build -t "$tag" "$dir"
rm -rf "$dir"

echo '----- Done -----'

exit 0
