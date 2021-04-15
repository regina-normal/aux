FROM snapshot/arch
RUN pacman --noconfirm --noprogressbar -Syy
RUN pacman --noconfirm --noprogressbar -Syu
RUN pacman --noconfirm --noprogressbar -S vim
RUN pacman --noconfirm --noprogressbar -Scc

# Remember to mark the packager for all builds in all arch images.
RUN echo 'PACKAGER="Ben Burton <bab@debian.org>"' >> /etc/makepkg.conf
