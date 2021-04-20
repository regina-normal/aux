FROM bab/opensuse:15.2
RUN zypper refresh
RUN zypper dist-upgrade -y
RUN zypper install -y --no-recommends \
	rpm-build appstream-glib \
	gcc gcc-c++ glibc-devel libstdc++-devel \
	git vim

# Note: openSUSE 15.2 ships with gcc7 by default, but it also has packages
# for gcc8 and gcc9.  We are not (currently) installing or using them.

RUN zypper clean

RUN useradd -U -s /bin/bash -m build
