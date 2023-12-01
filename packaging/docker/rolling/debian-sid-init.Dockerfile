FROM base/debian:bookworm

ADD apt-sources/sid /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
