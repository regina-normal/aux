FROM bab/opensuse:15.2
RUN zypper refresh
RUN zypper dist-upgrade -y
RUN zypper install -y --no-recommends \
	rpm-build \
	cmake \
	cppunit-devel \
	doxygen \
	gcc \
	gcc-c++ \
	glibc-devel \
	gmp-devel \
	graphviz-devel \
	libbz2-devel \
	libjansson-devel \
	libqt5-qtbase-devel \
	libqt5-qtsvg-devel \
	libstdc++-devel \
	libxml2-devel \
	libxslt-tools \
	lmdb-devel \
	pkg-config \
	popt-devel \
	python3-devel \
	shared-mime-info \
	zlib-devel
RUN zypper clean

# Note: openSUSE 15.2 ships with gcc7 by default, but it also has packages
# for gcc8 and gcc9.  We are not (currently) installing or using them.

# Install my own patched RPM, to support %_topdir with spaces.
ADD regina-key.asc /usr/local/regina/
RUN rpm --import /usr/local/regina/regina-key.asc
RUN zypper addrepo https://people.debian.org/~bab/rpm/rpm-patches/opensuse/15.2/rpm-patches.repo
RUN zypper refresh
RUN zypper update -y --no-recommends --allow-vendor-change

# We also need to install packages from additional openSUSE repositories:
# - doxygen (from devel:tools), since the openSUSE 15.2 packages are too old.
ADD opensuse-devel.key /usr/local/regina/
RUN rpm --import /usr/local/regina/opensuse-devel.key
RUN zypper addrepo https://download.opensuse.org/repositories/devel:tools/openSUSE_Leap_15.2/devel:tools.repo
RUN zypper refresh
RUN zypper update -y --no-recommends --allow-vendor-change doxygen
RUN zypper removerepo devel_tools

RUN zypper refresh
RUN zypper clean
