FROM snapshot/debian:trixie
ADD apt-sources/trixie /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
