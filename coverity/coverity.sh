#!/bin/bash
#
# Coverity scan script for https://scan.coverity.com/projects/etlegacy-etlegacy
# See https://scan.coverity.com/download
#
# Runs in the docker builder at etlegacy.com
#
# Folder structure:
# - coverity.sh
# - etlegacy
#  ... built code
# - github.com
#   - etlegacy
#     - etlegacy
#      ... source code
#     - coverity
#       - etlegacy-cov
#         - cov-analysis-linux64-2019.03
#         - cov-int
#
srcdir="$HOME/github.com/etlegacy/etlegacy"
covdir="$HOME/github.com/etlegacy/coverity/etlegacy-cov"
covver="linux64-2019.03" 

# account
token=xxxxxxxxxxxxxxxxxxxxxx
email=xxxxxxxxxxxx@xxxxx.xxx

# ensure we are on master branch
cd $srcdir
git stash
git checkout master
git pull
git submodule update --init --recursive

# cleanup
[[ -e $srcdir/build ]] && rm -rf $srcdir/build

# build
[[ ! -e $srcdir/build ]] && mkdir -p $srcdir/build
cd "$srcdir/build" 

cmake .. \
    -DCMAKE_BUILD_TYPE='Debug' \
    -DCMAKE_INSTALL_PREFIX= \
    -DCMAKE_LIBRARY_PATH=/usr/lib \
    -DCMAKE_INCLUDE_PATH=/usr/include \
    -DCROSS_COMPILE32=0 \
    -DINSTALL_DEFAULT_BASEDIR=. \
    -DINSTALL_DEFAULT_BINDIR=. \
    -DINSTALL_DEFAULT_MODDIR=. \
    -DBUNDLED_LIBS=1 \
    -DINSTALL_EXTRA=0

# version check
version=$(git describe --always | sed -r 's/^v//;s/-/./g;')
version=${version:${#version} - 7}

# build
$covdir/cov-analysis-${covver}/bin/cov-build --dir $covdir/cov-int make -j 4

cd $covdir
tar -czvf etlegacy-${version}.tgz cov-int

# upload
curl -k \
     --form token=${token} \
     --form email=${email} \
     --form file=@etlegacy-${version}.tgz \
     --form version="${version}" \
     --form description="development" \
    https://scan.coverity.com/builds?project=etlegacy%2Fetlegacy

# cleanup
rm ${covdir}/etlegacy-${version}.tgz
#[[ -e "$HOME/github.com/etlegacy/coverity/cov-int" ]] &&  rm -rf "${covdir}/cov-int"

# vim:set ts=4 sw=2 et:
