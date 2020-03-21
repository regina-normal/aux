#!/bin/sh
set -e

qtver=5.12.3
# gvdir="/c/Program Files/Graphviz2.38"
arch=`uname -m`

if [ "$arch" = x86_64 ]; then
  qtdir="/c/Qt/$qtver/mingw73_64"
elif [ "$arch" = i686 ]; then
  qtdir="/c/Qt/$qtver/mingw73_32"
else
  echo "ERROR: Unknown architecture: $arch"
  exit 1
fi

if [ -z "$gvdir" ]; then
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/bab/software/lib/pkgconfig"
else
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/bab/software/lib/pkgconfig:$gvdir/lib/pkgconfig"
fi

cmake -G 'MSYS Makefiles' -DQDBM=1 \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH="$qtdir" \
  -DCMAKE_INSTALL_PREFIX=/home/bab/software \
  -DREGINA_BOOST_DO_NOT_FIX_CONVERTERS=1 \
  -DPYTHON_CORE_IN_ZIP=1 \
  ..

