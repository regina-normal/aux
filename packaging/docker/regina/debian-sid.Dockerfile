FROM pkgdev/debian:sid
RUN apt-get update
RUN apt-get dist-upgrade -y
# Note: we need curl to download source tarballs.
RUN apt-get install -y --no-install-recommends \
	curl \
	dh-python \
	cmake \
	doxygen \
	libgmp-dev \
	libgraphviz-dev \
	libqt6svg6-dev \
	libtokyocabinet-dev \
	libxml2-dev \
	pkg-config \
	python3-all-dev \
	qt6-base-dev \
	shared-mime-info \
	xsltproc \
	zlib1g-dev
RUN apt-get clean
