FROM rolling/debian:sid

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get clean
