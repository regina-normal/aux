#!/usr/bin/env bash
set -e

# TODO: Change these
tag=rolling/fedora:rawhide
arch=amd64
distribution=fedora-rawhide

dir="$(mktemp -d ${TMPDIR:-/var/tmp}/docker-mkimage.XXXXXXXXXX)"
rootfsDir="$dir/rootfs"
tarFile="$dir/rootfs.tar.xz"

echo '----- Bootstrapping distribution -----'

mkdir -p "$rootfsDir"
rinse --directory "$rootfsDir" --arch "$arch" --distribution "$distribution"

if [ -d "$rootfsDir/etc/sysconfig" ]; then
	# allow networking init scripts inside the container to work without extra steps
	echo 'NETWORKING=yes' > "$rootfsDir/etc/sysconfig/network"
fi

echo '----- Creating /etc/resolv.conf -----'

# make sure /etc/resolv.conf has something useful in it
mkdir -p "$rootfsDir/etc"
rm -f "$rootfsDir/etc/resolv.conf"
cat > "$rootfsDir/etc/resolv.conf" <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo '----- Updating distribution -----'

chroot "$rootfsDir" dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
chroot "$rootfsDir" dnf clean all

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
