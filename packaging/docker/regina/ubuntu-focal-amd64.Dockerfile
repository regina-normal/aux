FROM pkgdev/ubuntu:focal
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

# Use focal as a platform for testing against old versions of clang.
RUN apt-get install -y --no-install-recommends \
	clang-10 \
	clang-9 \
	clang-8 \
	clang-7 \
	clang-6

RUN apt-get clean
