FROM pkgdev/fedora:37
RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf install -y -b --setopt=install_weak_deps=False \
	cmake \
	desktop-file-utils \
	doxygen \
	gmp-devel \
	graphviz-devel \
	libxml2-devel \
	libxslt \
	pkgconfig \
	python3-devel \
	qt6-qtbase-devel \
	qt6-qtsvg-devel \
	shared-mime-info \
	tokyocabinet-devel \
	zlib-devel
RUN dnf clean all
