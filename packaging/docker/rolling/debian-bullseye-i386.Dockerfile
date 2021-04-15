FROM snapshot/debian:bullseye_i386
ADD apt-sources/bullseye /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
