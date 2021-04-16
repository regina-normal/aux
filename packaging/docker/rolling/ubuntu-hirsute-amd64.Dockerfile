FROM snapshot/ubuntu:hirsute
ADD apt-sources/hirsute /etc/apt/sources.list
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
