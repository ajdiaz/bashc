#!/bin/bash
#
# build static bash because we need exercises in minimalism
# MIT licensed: google it or see robxu9.mit-license.org.
#
# For Linux, also builds musl for truly static linking.

bash_version="4.4"
bash_patch_level=18
musl_version="1.2.1"

platform=$(uname -s)


pushd "${0%/scripts/build.sh}" || exit 1

if [ -d build ]; then
  echo "= removing previous build directory"
  rm -rf build
fi

mkdir build # make build directory
pushd build || exit 1

# download tarballs
echo "= downloading bash"
curl -LO http://ftp.gnu.org/gnu/bash/bash-${bash_version}.tar.gz

echo "= extracting bash"
tar -xf bash-${bash_version}.tar.gz

echo "= patching bash"
bash_patch_prefix=$(echo "bash${bash_version}" | sed -e 's/\.//g')
pushd bash-${bash_version} || exit 1
for lvl in $(seq $bash_patch_level); do
    curl -L "http://ftp.gnu.org/gnu/bash/bash-${bash_version}-patches/${bash_patch_prefix}-$(printf '%03d' "$lvl")" | patch -p0
done
patch -p0 < "../../patch/hack-${bash_version}.diff"
popd || exit 1

if [[ "$platform" = "Linux" ]]; then
  echo "= downloading musl"
  curl -LO http://www.musl-libc.org/releases/musl-${musl_version}.tar.gz

  echo "= extracting musl"
  tar -xf musl-${musl_version}.tar.gz

  echo "= building musl"
  working_dir=$(pwd)

  install_dir=${working_dir}/musl-install

  pushd musl-${musl_version} || exit 1
  ./configure "--prefix=${install_dir}"
  make install || exit 1
  popd || exit 1 # musl-${musl-version}

  echo "= setting CC to musl-gcc"
  export CC=${working_dir}/musl-install/bin/musl-gcc
  export CFLAGS="-static"
  export LDFLAGS_FOR_BUILD="-static"
else
  echo "= WARNING: your platform does not support static binaries."
  echo "= (This is mainly due to non-static libc availability.)"
fi

echo "= building bash"

pushd bash-${bash_version} || exit 1
CFLAGS="$CFLAGS -Os" ./configure --without-bash-malloc
find . -name "Makefile" -exec sed -i 's:-rdynamic::g' {} \;
make
make tests
popd || exit 1 # bash-${bash_version}

popd || exit 1 # build

if [ ! -d releases ]; then
  mkdir releases
fi

echo "= extracting bash binary"
cp build/bash-${bash_version}/bash releases
strip -s releases/bash

echo "= creating bashc"
(
 cat releases/bash scripts/bashc.sh
 # shellcheck disable=SC2012
 printf "#%020i" "$(ls -l scripts/bashc.sh | awk '{print $5}')"
) > releases/bashc && chmod 755 releases/bashc

echo "= done"
