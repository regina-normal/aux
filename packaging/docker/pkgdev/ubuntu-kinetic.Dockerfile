FROM bab/ubuntu:kinetic

ADD apt-sources/ubuntu-gen /etc/apt/ubuntu-gen
RUN /etc/apt/ubuntu-gen kinetic > /etc/apt/sources.list; \
    cat /etc/apt/sources.list; \
    rm /etc/apt/ubuntu-gen

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential devscripts fakeroot lintian gnupg autopkgtest \
	gcc-9 gcc-10 gcc-11 gcc-12 \
	g++-9 g++-10 g++-11 g++-12 \
	debhelper git vim
RUN apt-get clean

RUN useradd -U -s /bin/bash -m build
