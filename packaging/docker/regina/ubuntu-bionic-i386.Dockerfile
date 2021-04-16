FROM bab/ubuntu:bionic_i386
ADD apt-sources/bionic /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-7 gcc-8 \
	debhelper \
	dh-python \
	cmake \
	doxygen \
	libcppunit-dev \
	libgmp-dev \
	libgraphviz-dev \
	libjansson-dev \
	libpopt-dev \
	libqt5svg5-dev \
	libtokyocabinet-dev \
	libxml2-dev \
	pkg-config \
	python3-all-dev \
	qtbase5-dev \
	shared-mime-info \
	xsltproc \
	zlib1g-dev
ADD regina-key.asc /usr/local/regina/
RUN apt-get install -y --no-install-recommends software-properties-common
RUN apt-key add /usr/local/regina/regina-key.asc
RUN apt-add-repository -y 'deb https://people.debian.org/~bab/backports bionic/'
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
