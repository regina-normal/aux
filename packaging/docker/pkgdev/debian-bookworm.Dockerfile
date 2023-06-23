FROM rolling/debian:bookworm
ADD apt-sources/bookworm /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-11 gcc-12 \
	g++-11 g++-12 \
	debhelper git vim
RUN apt-get clean

RUN useradd -U -s /bin/bash -m build
