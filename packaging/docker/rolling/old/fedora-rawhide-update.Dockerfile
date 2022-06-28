FROM rolling/fedora:rawhide

RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf clean all
