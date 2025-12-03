#!/bin/bash
set -e

if [ -z "$@" ]; then
  echo "If this intended to be an official upstream release, press Ctrl-C now"
  echo "and rerun with an extra argument: -DBUILD_INFO='...'"
  echo
  echo "If this is an ad-hoc build or a user making their own Windows build,"
  echo "press [Enter] to continue."
  read
fi

qtver=6.9.1
# gvdir="/c/Program Files/Graphviz2.38"
# arch=`uname -m`
arch="$MSYSTEM_CARCH"

if [ "$arch" = x86_64 ]; then
  qtdir="/c/Qt/$qtver/mingw_64"
  msys=/c/msys64
  mingw=/mingw64
elif [ "$arch" = i686 ]; then
  qtdir="/c/Qt/$qtver/mingw_32"
  msys=/c/msys32
  mingw=/mingw32
elif [ "$arch" = aarch64 ]; then
  msys=/c/msys64
  mingw=/clangarm64
else
  echo "ERROR: Unknown architecture: $arch"
  exit 1
fi

if [ -n "$USER" ]; then
  export PREFIX="/home/$USER/software-$arch"
elif [ -n "$USERNAME" ]; then
  export PREFIX="/home/$USERNAME/software-$arch"
else
  export PREFIX=~/"software-$arch"
fi

if [ -z "$gvdir" ]; then
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig"
else
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$gvdir/lib/pkgconfig"
fi

cmake -G 'MSYS Makefiles' -DPACKAGING_MODE=1 \
  -DREGINA_KVSTORE=lmdb \
  -DCMAKE_PREFIX_PATH="$qtdir" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DPython_EXECUTABLE="$mingw/bin/python.exe" \
  -DPYTHON_CORE_IN_ZIP=1 \
  "$@" ..

