#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

./configure --prefix=$PREFIX
make -j${CPU_COUNT}
if "${target_platform}" != osx-*  ]]; then
  make check -j${CPU_COUNT}
else
  # on osx test 20 Stable component GUIDs fails
  # due a bogus keypath difference
  make check -j${CPU_COUNT} || true
fi
make install
