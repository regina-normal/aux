FROM rolling/arch
RUN pacman --noconfirm --noprogressbar -Syy
RUN pacman --noconfirm --noprogressbar -Syu
RUN pacman --noconfirm --noprogressbar -S git base-devel devtools namcap
RUN pacman --noconfirm --noprogressbar -Scc

RUN useradd -U -s /bin/bash -m build
