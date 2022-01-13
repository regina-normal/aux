FROM bab/ubuntu:impish
ADD apt-sources/impish /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-8 gcc-9 gcc-10 gcc-11 \
	g++-8 g++-9 g++-10 g++-11 \
	debhelper git vim
RUN apt-get clean

RUN useradd -U -s /bin/bash -m build
