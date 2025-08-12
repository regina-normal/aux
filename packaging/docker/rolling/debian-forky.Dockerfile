FROM snapshot/debian:forky
ADD apt-sources/forky /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
