FROM pkgdev/debian:sid
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
	python3-all-dev \
	qtbase5-dev \
	shared-mime-info \
	xsltproc \
	zlib1g-dev
RUN apt-get clean
