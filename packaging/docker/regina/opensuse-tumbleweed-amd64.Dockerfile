FROM rolling/opensuse:tumbleweed
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

# Install my own patched RPM, to support %_topdir with spaces.
ADD regina-key.asc /usr/local/regina/
RUN rpm --import /usr/local/regina/regina-key.asc
RUN zypper addrepo https://people.debian.org/~bab/rpm/rpm-patches/opensuse/tumbleweed/rpm-patches.repo
RUN zypper refresh
RUN zypper update -y --no-recommends --allow-vendor-change

RUN zypper clean
