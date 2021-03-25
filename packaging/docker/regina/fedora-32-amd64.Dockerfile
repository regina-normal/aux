FROM bab/fedora:32
RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf install -y -b --setopt=install_weak_deps=False \
	rpm-build \
	cmake \
	cppunit-devel \
	desktop-file-utils \
	doxygen \
	gcc \
	gcc-c++ \
	glibc-devel \
	gmp-devel \
	graphviz-devel \
	jansson-devel \
	libstdc++-devel \
	libxml2-devel \
	libxslt \
	make \
	pkgconfig \
	popt-devel \
	python3-devel \
	qt5-qtbase-devel \
	qt5-qtsvg-devel \
	shared-mime-info \
	tokyocabinet-devel \
	zlib-devel
RUN dnf clean all
RUN echo '%_vendor fedora32' > /etc/rpm/macros
