FROM bab/ubuntu:groovy
ADD apt-sources/groovy /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-7 gcc-8 gcc-9 gcc-10 \
	debhelper git vim
RUN apt-get clean

RUN useradd -U -s /bin/bash -m build
