FROM snapshot/opensuse:tumbleweed

RUN zypper refresh
RUN zypper dist-upgrade -y --allow-vendor-change
RUN zypper clean
