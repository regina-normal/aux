FROM pkgdev/opensuse:tumbleweed
RUN zypper refresh
RUN zypper dist-upgrade -y

RUN zypper install -y --no-recommends \
	cmake \
	cppunit-devel \
	doxygen \
	gmp-devel \
	graphviz-devel \
	libbz2-devel \
	libjansson-devel \
	libqt6-qtbase-devel \
	libqt6-qtsvg-devel \
	libxml2-devel \
	libxslt-tools \
	lmdb-devel \
	pkg-config \
	popt-devel \
	python3-devel \
	shared-mime-info \
	zlib-devel

# When adding new repositories via https, curl gives an SSL error about
# "unable to get local issuer certificate".  Running update-ca-certificates
# seems to fix this.
#
RUN update-ca-certificates

# Install my own patched RPM, to support %_topdir with spaces.
#
ADD regina-key.asc /usr/local/regina/
RUN rpm --import /usr/local/regina/regina-key.asc
RUN zypper addrepo https://people.debian.org/~bab/rpm/rpm-patches/opensuse/tumbleweed/rpm-patches.repo
RUN zypper refresh
RUN zypper update -y --no-recommends --allow-vendor-change

RUN zypper clean
