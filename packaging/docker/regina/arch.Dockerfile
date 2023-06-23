FROM pkgdev/arch
RUN pacman --noconfirm --noprogressbar -Syy
RUN pacman --noconfirm --noprogressbar -Syu
RUN pacman --noconfirm --noprogressbar -S \
	cmake \
	desktop-file-utils \
	doxygen \
	gmp \
	graphviz \
	hicolor-icon-theme \
	libxml2 \
	libxslt \
	lmdb \
	python \
	qt6-base \
	qt6-svg \
	shared-mime-info \
	zlib
RUN pacman --noconfirm --noprogressbar -Scc
