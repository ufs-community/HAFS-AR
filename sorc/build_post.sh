#!/bin/sh
set -eux
source ./machine-setup.sh > /dev/null 2>&1
if [ $target = wcoss2 ]; then source ../versions/build.ver; fi
cwd=$(pwd)

cd hafs_post.fd/tests
cp -fp $cwd/customizations/hafs_post.fd/gaea.lua ../modulefiles/.
./compile_upp.sh

exit
