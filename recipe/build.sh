#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

./configure --prefix=$PREFIX
make -j${CPU_COUNT}
# on osx test 20 Stable component GUIDs fails
#if "${target_platform}" != osx-*  ]]; then
  make check -j${CPU_COUNT}
#fi
make install
