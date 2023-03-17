FROM bab/opensuse:15.4
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
RUN chown -R build:build /home/build/rpmbuild

# Add a source repository to save us the trouble later.
RUN zypper addrepo http://download.opensuse.org/source/distribution/leap/15.4/repo/oss/ source
