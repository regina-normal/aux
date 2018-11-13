#!/bin/sh
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/bab/software/lib/pkgconfig:/c/Program Files/Graphviz2.38/lib/pkgconfig"
cmake -G 'MSYS Makefiles' -DQDBM=1 \
  -DCMAKE_PREFIX_PATH=/c/Qt/Qt5.11.2/5.11.2/mingw53_32 \
  -DCMAKE_INSTALL_PREFIX=/home/bab/software \
  -DREGINA_BOOST_DO_NOT_FIX_CONVERTERS=1 \
  ..
