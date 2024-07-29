#!/bin/sh
set -eux
source ./machine-setup.sh > /dev/null 2>&1
if [ $target = wcoss2 ]; then source ../versions/build.ver; fi
cwd=$(pwd)

if [[ $target =~ .*c5 ]] ; then target=gaea ; fi

sed 's,.*darshan.*,,g' hafs_forecast.fd/modulefiles/ufs_gaea.intel.lua hafs_forecast.fd/FV3/upp/modulefiles/gaea.lua

cd hafs_forecast.fd/tests

app=HAFSW
opts="-DAPP=HAFSW -DMOVING_NEST=ON -DCCPP_SUITES=FV3_global_nest_v1 -DFASTER=ON -D32BIT=ON"
./compile.sh "$target" "$opts" 32bit intel YES NO

exit
