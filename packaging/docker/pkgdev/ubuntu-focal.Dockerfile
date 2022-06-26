FROM bab/ubuntu:focal

ADD apt-sources/ubuntu-gen /etc/apt/ubuntu-gen
RUN /etc/apt/ubuntu-gen focal > /etc/apt/sources.list; \
    cat /etc/apt/sources.list; \
    rm /etc/apt/ubuntu-gen

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-7 gcc-8 gcc-9 gcc-10 \
	g++-7 g++-8 g++-9 g++-10 \
	debhelper git vim
RUN apt-get clean

RUN useradd -U -s /bin/bash -m build
