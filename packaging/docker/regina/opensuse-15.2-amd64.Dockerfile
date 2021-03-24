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
	pkg-config \
	popt-devel \
	python3-devel \
	shared-mime-info \
	zlib-devel
RUN zypper clean

# Note: openSUSE 15.2 ships with gcc7 by default, but it also has packages
# for gcc8 and gcc9.  We are not (currently) installing or using them.

ADD opensuse-devel.key /usr/local/regina/
RUN rpm --import /usr/local/regina/opensuse-devel.key
RUN zypper addrepo https://download.opensuse.org/repositories/devel:libraries:c_c++/openSUSE_Leap_15.2/devel:libraries:c_c++.repo
RUN zypper refresh
RUN zypper install -y --no-recommends libtokyocabinet9 libtokyocabinet-devel
RUN zypper removerepo devel_libraries_c_c++
RUN zypper refresh
RUN zypper clean

ADD apidocs-sample.zip /usr/local/regina/
RUN zypper install -y --no-recommends unzip
RUN zypper clean
