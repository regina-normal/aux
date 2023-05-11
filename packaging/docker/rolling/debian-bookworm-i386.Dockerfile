FROM snapshot/debian:bookworm_i386
ADD apt-sources/bookworm /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
