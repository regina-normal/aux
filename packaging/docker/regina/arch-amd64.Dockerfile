FROM bab/arch
RUN pacman --noconfirm --noprogressbar -Syy
RUN pacman --noconfirm --noprogressbar -Syu
RUN pacman --noconfirm --noprogressbar -S vim git base-devel namcap
RUN pacman --noconfirm --noprogressbar -S \
	cmake \
	cppunit \
	desktop-file-utils \
	doxygen \
	gmp \
	graphviz \
	hicolor-icon-theme \
	jansson \
	libxml2 \
	libxslt \
	lmdb \
	popt \
	python \
	qt5-base \
	qt5-svg \
	shared-mime-info \
	zlib
RUN pacman --noconfirm --noprogressbar -Scc
