FROM bab/fedora:36
RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf install -y -b --setopt=install_weak_deps=False \
	dnf-utils rpm-build libappstream-glib-builder \
	gcc gcc-c++ glibc-devel libstdc++-devel make \
	git vim wget
RUN dnf clean all

RUN useradd -U -s /bin/bash -m build
RUN mkdir /home/build/rpmbuild
RUN mkdir /home/build/rpmbuild/{SOURCES,SPECS}
RUN chown -R build.build /home/build/rpmbuild
