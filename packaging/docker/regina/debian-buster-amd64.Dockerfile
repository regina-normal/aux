FROM pkgdev/debian:buster
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
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

# Use buster as a platform for testing against old versions of clang.
# This also requires python3, since clang will not build python2 under C++17.
RUN apt-get install -y --no-install-recommends clang python3 python3-dev

ADD regina-key.asc /usr/local/regina/
RUN apt-get install -y --no-install-recommends software-properties-common
RUN apt-key add /usr/local/regina/regina-key.asc
RUN apt-add-repository -y 'deb https://people.debian.org/~bab/backports buster/'
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
