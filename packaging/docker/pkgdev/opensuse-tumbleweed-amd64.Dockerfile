FROM rolling/opensuse:tumbleweed
RUN zypper refresh
RUN zypper dist-upgrade -y

RUN zypper install -y --no-recommends \
	rpm-build appstream-glib \
	gcc gcc-c++ glibc-devel libstdc++-devel \
	git vim wget

RUN zypper clean

RUN useradd -U -s /bin/bash -m build
RUN mkdir /home/build/rpmbuild
RUN mkdir /home/build/rpmbuild/{SOURCES,SPECS}
RUN chown -R build.build /home/build/rpmbuild
