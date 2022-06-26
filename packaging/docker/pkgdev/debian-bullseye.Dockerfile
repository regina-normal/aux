FROM bab/debian:bullseye
ADD apt-sources/bullseye /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-9 gcc-10 \
	g++-9 g++-10 \
	debhelper git vim
RUN apt-get clean

RUN useradd -U -s /bin/bash -m build
