FROM pkgdev/fedora:35
RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf install -y -b --setopt=install_weak_deps=False \
	cmake \
	cppunit-devel \
	desktop-file-utils \
	doxygen \
	gmp-devel \
	graphviz-devel \
	jansson-devel \
	libxml2-devel \
	libxslt \
	pkgconfig \
	popt-devel \
	python3-devel \
	qt5-qtbase-devel \
	qt5-qtsvg-devel \
	shared-mime-info \
	tokyocabinet-devel \
	zlib-devel
RUN dnf clean all

# Patch RPM and friends to work when topdir contains spaces:
ADD regina-key.asc /usr/local/regina/
RUN rpm --import /usr/local/regina/regina-key.asc
RUN dnf config-manager --add-repo https://people.debian.org/~bab/rpm/rpm-patches/fedora/35/rpm-patches.repo
RUN dnf upgrade -y -b --refresh --setopt=install_weak_deps=False
RUN dnf clean all
