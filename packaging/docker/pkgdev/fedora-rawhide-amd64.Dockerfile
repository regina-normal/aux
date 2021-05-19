FROM rolling/fedora:rawhide
RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf install -y -b --setopt=install_weak_deps=False \
	dnf-utils rpm-build libappstream-glib-builder \
	gcc gcc-c++ glibc-devel libstdc++-devel make \
	git vim
RUN dnf clean all

RUN useradd -U -s /bin/bash -m build
