FROM bab/ubuntu:bionic
ADD apt-sources/bionic /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg \
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
ADD kitware-key.asc /usr/local/regina/
RUN apt-get install -y --no-install-recommends software-properties-common
RUN apt-key add /usr/local/regina/kitware-key.asc
RUN apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main'
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends unzip
RUN apt-get clean
ADD apidocs-sample.zip /usr/local/regina/