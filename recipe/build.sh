#!/usr/bin/env bash
set -euo pipefail

# make GCab introspection visible under the name libgcab-1.0 (aliasing)
# Meson: libgcab = dependency('libgcab-1.0', version: '>= 0.1.10')

# GIR
if [[ -f "${PREFIX}/share/gir-1.0/GCab-1.0.gir" ]] && [[ ! -f "${PREFIX}/share/gir-1.0/libgcab-1.0.gir" ]]; then
  ln -s "${PREFIX}/share/gir-1.0/GCab-1.0.gir" "${PREFIX}/share/gir-1.0/libgcab-1.0.gir"
fi

# typelib
if [[ -f "${PREFIX}/lib/girepository-1.0/GCab-1.0.typelib" ]] && [[ ! -f "${PREFIX}/lib/girepository-1.0/libgcab-1.0.typelib" ]]; then
  ln -s "${PREFIX}/lib/girepository-1.0/GCab-1.0.typelib" "${PREFIX}/lib/girepository-1.0/libgcab-1.0.typelib"
fi

# pkg-config alias (if pc exists under gcab-1.0 name)
for d in "${PREFIX}/lib/pkgconfig" "${PREFIX}/share/pkgconfig"; do
  if [[ -f "${d}/gcab-1.0.pc" && ! -f "${d}/libgcab-1.0.pc" ]]; then
    ln -s "${d}/gcab-1.0.pc" "${d}/libgcab-1.0.pc"
  fi
done

# Ensure valac/gir discovery see these dirs
export GI_TYPELIB_PATH="${PREFIX}/lib/girepository-1.0:${GI_TYPELIB_PATH:-}"
export VAPIDIR="${PREFIX}/share/vala/vapi:${BUILD_PREFIX}/share/vala/vapi"
export XDG_DATA_DIRS="${PREFIX}/share:${BUILD_PREFIX}/share:${XDG_DATA_DIRS:-}"
export VALAFLAGS="${VALAFLAGS:-} --vapidir=${PREFIX}/share/vala/vapi --vapidir=${BUILD_PREFIX}/share/vala/vapi"

# Refresh config.sub/config.guess
for f in config.sub config.guess; do
  if [[ -f "build-aux/${f}" ]]; then
    cp -f "${BUILD_PREFIX}/share/gnuconfig/${f}" "build-aux/${f}"
  elif [[ -f "${f}" ]]; then
    cp -f "${BUILD_PREFIX}/share/gnuconfig/${f}" "${f}"
  fi
done

# Make sure pkg-config sees host/target deps
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# Meson configure
meson setup builddir \
  --prefix="${PREFIX}" \
  --libdir=lib \
  --buildtype=release \
  --wrap-mode=nofallback \
  -Ddefault_library=shared \
  -Db_ndebug=true

# Show final configuration
meson configure builddir

# Build + install
meson compile -C builddir -j "${CPU_COUNT:-1}" -v
meson install -C builddir
