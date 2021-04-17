FROM bab/opensuse:15.2

RUN rm /etc/zypp/repos.d/*.repo
RUN zypper ar -f -c http://download.opensuse.org/tumbleweed/repo/oss repo-oss
RUN zypper ar -f -c http://download.opensuse.org/tumbleweed/repo/non-oss repo-non-oss
RUN zypper ar -f -c http://download.opensuse.org/tumbleweed/repo/debug repo-debug
RUN zypper ar -f -c http://download.opensuse.org/update/tumbleweed/ repo-update
RUN zypper ar -f -c http://download.opensuse.org/tumbleweed/repo/src-oss repo-src-oss
RUN zypper ar -f -c http://download.opensuse.org/tumbleweed/repo/src-non-oss repo-src-non-oss
RUN zypper cc -a
RUN zypper refresh

# RPM cannot rebuild its database unless we move the database directory
# out of the bab/opensuse:15.2 read-only layer of the filesystem and into a
# new writeable layer.
#
# An strace() shows that the problem is rename() returning EXDEV when
# attempting to back up the original database.
#
# See: https://blog.cloud66.com/using-node-with-docker/
#
# To fix this, we need to move the database into the writeable layer
# _in_the_same_docker_command_ as the one where we do the dist-upgrade
# (which triggers the database rebuild).
RUN mv /usr/lib/sysimage/rpm /usr/lib/sysimage/rpm.tmp && \
  mv /usr/lib/sysimage/rpm.tmp /usr/lib/sysimage/rpm && \
  zypper update -y --allow-vendor-change rpm zypper && \
  rpm --rebuilddb

RUN zypper dist-upgrade -y --allow-vendor-change

# rpm-build needs gzip, not busybox-gzip, and this requires a zypper
# conflict resolution.  Do this now so we don't have to do it every time
# we want to build an RPM.
RUN zypper install -y --no-recommends --force-resolution gzip

RUN zypper clean
