FROM bab/debian:buster
ADD apt-sources/buster /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian \
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
	python-dev \
	qtbase5-dev \
	shared-mime-info \
	xsltproc \
	unzip \
	zlib1g-dev
ADD regina-key.asc /usr/local/regina/
RUN apt-get install -y --no-install-recommends software-properties-common
RUN apt-key add /usr/local/regina/regina-key.asc
RUN apt-add-repository -y 'deb https://people.debian.org/~bab/backports buster/'
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
