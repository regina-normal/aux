#!/bin/bash
set -e

qtver=6.4.0
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
  qtdir="/c/Qt/$qtver/mingw_64"
  msys=/c/msys64
  mingw=/mingw64
elif [ "$arch" = i686 ]; then
  qtdir="/c/Qt/$qtver/mingw_32"
  msys=/c/msys32
  mingw=/mingw32
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
  -DREGINA_KVSTORE=lmdb \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH="$qtdir" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DPython_EXECUTABLE="$mingw/bin/python.exe" \
  -DPYTHON_CORE_IN_ZIP=1 \
  "$@" ..

