#!/bin/bash
set -e

qtver=5.15.2
# gvdir="/c/Program Files/Graphviz2.38"
arch=`uname -m`

if [ -n "$USER" ]; then
  export PREFIX="/home/$USER/software"
elif [ -n "$USERNAME" ]; then
  export PREFIX="/home/$USERNAME/software"
else
  export PREFIX=~/software
fi

if [ "$arch" = x86_64 ]; then
  qtdir="/c/Qt/$qtver/mingw81_64"
  msys=/c/msys64
elif [ "$arch" = i686 ]; then
  qtdir="/c/Qt/$qtver/mingw81_32"
  msys=/c/msys32
else
  echo "ERROR: Unknown architecture: $arch"
  exit 1
fi

if [ -z "$gvdir" ]; then
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig"
else
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$gvdir/lib/pkgconfig"
fi

cmake -G 'MSYS Makefiles' -DPACKAGING_MODE=1 \
  -DQDBM=1 \
  -DCMAKE_PREFIX_PATH="$qtdir" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DPYTHON_CORE_IN_ZIP=1 \
  ..

