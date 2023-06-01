FROM pkgdev/ubuntu:focal
RUN apt-get update
RUN apt-get dist-upgrade -y
# Note: we need curl to download source tarballs.
RUN apt-get install -y --no-install-recommends \
	curl \
	dh-python \
	cmake \
	doxygen \
	libcppunit-dev \
	libgmp-dev \
	libgraphviz-dev \
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
	clang-6.0

RUN apt-get clean
