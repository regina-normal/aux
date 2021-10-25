FROM snapshot/debian:bullseye
ADD apt-sources/bullseye /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
