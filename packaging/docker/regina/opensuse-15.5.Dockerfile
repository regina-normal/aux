FROM pkgdev/opensuse:15.5
RUN zypper refresh
RUN zypper dist-upgrade -y

# Qt6 cannot work with gcc7, which does not support std::filesystem.
RUN zypper install -y --no-recommends gcc12 gcc12-c++

RUN zypper install -y --no-recommends \
	cmake \
	doxygen \
	gcc12 gcc12-c++ \
	gmp-devel \
	graphviz-devel \
	libbz2-devel \
	libxml2-devel \
	libxslt-tools \
	lmdb-devel \
	pkg-config \
	python3-devel \
	qt6-base-devel \
	qt6-svg-devel \
	shared-mime-info \
	zlib-devel

# When adding new repositories via https, curl gives an SSL error about
# "unable to get local issuer certificate".  Running update-ca-certificates
# seems to fix this.
#
RUN zypper install -y --no-recommends ca-certificates ca-certificates-mozilla
RUN update-ca-certificates

# We also need to install packages from additional openSUSE repositories:
# - doxygen (from devel:tools), since the openSUSE 15.4 packages are too old.
ADD opensuse-devel.key /usr/local/regina/
RUN rpm --import /usr/local/regina/opensuse-devel.key
RUN zypper addrepo https://download.opensuse.org/repositories/devel:/tools/15.5/devel:tools.repo
RUN zypper refresh
RUN zypper update -y --no-recommends --allow-vendor-change doxygen
RUN zypper removerepo devel_tools
RUN zypper refresh

RUN zypper clean
