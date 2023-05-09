FROM pkgdev/opensuse:15.4
RUN zypper refresh
RUN zypper dist-upgrade -y

# Qt6 cannot work with gcc7, which does not support std::filesystem.
RUN zypper install -y --no-recommends gcc11 gcc11-c++

RUN zypper install -y --no-recommends \
	cmake \
	cppunit-devel \
	doxygen \
	gcc11 gcc11-c++ \
	gmp-devel \
	graphviz-devel \
	libbz2-devel \
	libjansson-devel \
	libxml2-devel \
	libxslt-tools \
	lmdb-devel \
	pkg-config \
	popt-devel \
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

# Install a newer doxygen also.  The one shipped with openSUSE is ancient
# (so ancient that Regina can't use it).
#
# In the past this newer doxygen came from the openSUSE devel:tools repository,
# but in their wisdom the openSUSE people now ship 15.4 doxygen packages that
# require a newer libstdc++ that was originally shipped with openSUSE Leap 15.4.
# Installing this newer libstdc++ on the build machine will, as a side-effect,
# presumably mean that Regina's packages depend on this newer libstdc++ also.
# I don't know how new it is, or if "ordinary" 15.4 users are likely to have it,
# and so I'd rather Regina didn't depend on it.
#
# I avoid this problematic dependency by building a newer doxygen myself (using
# an out-of-the-box 15.4 installation as the build machine).
#
ADD regina-key.asc /usr/local/regina/
RUN rpm --import /usr/local/regina/regina-key.asc
RUN zypper addrepo https://people.debian.org/~bab/rpm/doxygen/opensuse/15.4/doxygen.repo
RUN zypper refresh
RUN zypper update -y --no-recommends --allow-vendor-change

# We also need to install packages from additional openSUSE repositories:
# - doxygen (from devel:tools), since the openSUSE 15.4 packages are too old.
# ADD opensuse-devel.key /usr/local/regina/
# RUN rpm --import /usr/local/regina/opensuse-devel.key
# RUN zypper addrepo https://download.opensuse.org/repositories/devel:/tools/15.4/devel:tools.repo
# RUN zypper refresh
# RUN zypper update -y --no-recommends --allow-vendor-change doxygen
# RUN zypper removerepo devel_tools
# RUN zypper refresh

RUN zypper clean
