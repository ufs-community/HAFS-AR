#!/bin/sh

#SBATCH --job-name=job
#SBATCH --account=_ACCOUNT_NAME_
#SBATCH -o job.log.%j
#SBATCH -e job.log.%j
#SBATCH --ntasks=1
#SBATCH --qos=batch
#SBATCH --partition=service
#SBATCH -t 06:00:00
#SBATCH -D .

#WCOSS Dell
#module load HPSS/5.0.2.5
#Hera
#module load hpss/hpss
#Jet
#module load hpss

module load hpss
module list

set -x

which hsi
which htar

#HTAR="htar -Hnostage"
HTAR="htar"

date

NDATE=${NDATE:-/gpfs/hps/nco/ops/nwprod/prod_util.v1.0.28/exec/ndate}

ymdh=${ymdh:-${1:-2023010100}}
ymdh6=$(${NDATE} +6 ${ymdh})
atmstr=${atmstr:-${2:-}}

ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymdh | cut -c1-4`
mm=`echo $ymdh | cut -c5-6`
dd=`echo $ymdh | cut -c7-8`
hh=`echo $ymdh | cut -c9-10`
hh6=`echo $ymdh6 | cut -c9-10`


export pull_obsbufr=${pull_obsbufr:-yes}
export pull_gfs=${pull_gfs:-yes}
export pull_gdas=${pull_gdas:-yes}
export pull_enkfgdas=${pull_enkfgdas:-yes}

export CHGRP_CMD=${CHGRP_CMD:-"chgrp ${group_name:-rstprod}"}

#HPSS locations
hpssgfspararoot=${hpssgfspararoot:-/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_D/gfsv16/v16rt2}
hpssgfsprodroot=${hpssgfsprodroot:-/NCEPPROD/hpssprod/runhistory}
hpssgfspara=${hpssgfspararoot}/${ymdh}
hpssgfsprod=${hpssgfsprodroot}/rh$yyyy/${yyyy}${mm}/${ymd}
hpssgfsprod2=${hpssgfsprodroot}/2year/rh$yyyy/${yyyy}${mm}/${ymd}
hpssgfsprod5=${hpssgfsprodroot}/5year/rh$yyyy/${yyyy}${mm}/${ymd}

#===============================================================================
# Observaton related files from gfs prod/dump

if [ ${pull_obsbufr} = "yes" ]; then
#obsbufr="./gfs.$ymd/$hh/gfs.t${hh}z.*bufr ./gfs.$ymd/$hh/gfs.t${hh}z.*bufr_d ./gfs.$ymd/$hh/gfs.t${hh}z.*.nr"
#bufr="./gfs.$ymd/$hh/gfs.t${hh}z.prepbufr ./gfs.$ymd/$hh/gfs.t${hh}z.nsstbufr"
#bufr_d="./gfs.$ymd/$hh/gfs.t${hh}z.*bufr_d"
#bufr_nr="./gfs.$ymd/$hh/gfs.t${hh}z.*.nr"
prepbufr_nr="./gfs.$ymd/$hh/atmos/gfs.t${hh}z.prepbufr.nr"
prepbufr="./gfs.$ymd/$hh/atmos/gfs.t${hh}z.prepbufr"
#nsstbufr="./gfs.$ymd/$hh/gfs.t${hh}z.nsstbufr"
nsstbufr=""

bufr_d_all="1bamua 1bhrs4 1bmhs adpsfc adpupa aircar aircft airsev amsr2 ascatt ascatw atmsdb atms avcsam avcspm bathy crisf4 crsfdb dbuoyb esamua esatms eshrs3 esiasi esmhs geoimr goesfv gome gpsipw gpsro iasidb mbuoyb mtiasi omi ompsn8 ompst8 osbuv8 proflr rassda saphir satwnd sevasr sevcsr sfcshp ssmisu tesac trkob vadwnd"
bufr_d_pub="1bamua 1bhrs4 1bmhs adpupa airsev amsr2 ascatt ascatw atmsdb atms avcsam avcspm bathy crisf4 crsfdb dbuoyb esamua esatms eshrs3 esiasi esmhs geoimr goesfv gome gpsro iasidb mbuoyb mtiasi omi ompsn8 ompst8 osbuv8 proflr rassda satwnd sevasr sevcsr ssmisu tesac trkob vadwnd"
#bufr_d_nr="adpsfc aircar aircft gpsipw saphir sfcshp"
bufr_d_nr=""

filelist=""

file=${prepbufr_nr}
if [ ! -e ${file} ]; then
  filelist="${filelist} ${file}"
fi

#for obstype in ${bufr_d_all};
for obstype in ${bufr_d_pub};
do
  file="./gfs.$ymd/$hh/atmos/gfs.t${hh}z.${obstype}.tm00.bufr_d"
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done

for obstype in ${bufr_d_nr};
do
  file="./gfs.$ymd/$hh/atmos/gfs.t${hh}z.${obstype}.tm00.bufr_d.nr"
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done

#tcvitals
tcvitals="./gfs.$ymd/$hh/gfs.t${hh}z.syndata.tcvitals.tm00"
filelist="${filelist} ${tcvitals}"

if [ ! -z "${filelist}" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_obsproc_v1.0_gfs.${ymd}_${hh}.obsproc_gfs.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gfs.${ymd}_${hh}.gfs.tar ${filelist}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gfs.${ymd}_${hh}.gfs.tar ${filelist}
fi

# Set group permission for rstprod files
$CHGRP_CMD $prepbufr $nsstbufr
chmod 640 $prepbufr $nsstbufr

for obstype in ${bufr_d_nr};
do
  file="./gfs.$ymd/$hh/atmos/gfs.t${hh}z.${obstype}.tm00.bufr_d"
  $CHGRP_CMD $file
  chmod 640 $file
done

# Link files into the atmos subdir
#mkdir -p ./gfs.$ymd/$hh/atmos
#cd ./gfs.$ymd/$hh/atmos
#ln -sf ../* ./
#cd -

fi #if [ ${pull_obsbufr} = "yes" ]; then
date

#===============================================================================
# Files from gfs prod/para/test

if [ ${pull_gfs} = "yes" ]; then

# Bufr files
# Do not pull the restricted version of bufr data
#prepbufr="./gfs.$ymd/$hh/gfs.t${hh}z.prepbufr"
#nsstbufr="./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.nsstbufr"
prepbufr=""
nsstbufr=""

atmanl="./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.atmanl.nc"
#atmfhr=$(seq -f ./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.atmf%03.3g.nc 0 3 126)
#atmfhr=./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.atmf000.nc

sfcanl="./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.sfcanl.nc"
#sfcfhr=./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.sfcf000.nc
#sfcfhr=$(seq -f ./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.sfcf%03.3g.nc 0 3 126)

pgrb2fhr=$(seq -f ./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.pgrb2.0p25.f%03.3g 0 3 129)
pgrb2bfhr=$(seq -f ./gfs.$ymd/$hh/${atmstr}gfs.t${hh}z.pgrb2b.0p25.f%03.3g 0 3 129)

filelist=""
for file in ${atmanl} ${sfcanl}
do
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done
if [ ! -z "$filelist" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gfs.${ymd}_${hh}.gfs_nca.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gfs.${ymd}_${hh}.gfs_nca.tar ${filelist}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gfs.${ymd}_${hh}.gfs_nca.tar ${filelist}
fi

filelist=""
for file in ${prepbufr} ${nsstbufr};
do
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done
if [ ! -z "$filelist" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_obsproc_v1.0_gfs.${ymd}_${hh}.obsproc_gfs.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gfs.${ymd}_${hh}.gfs.tar ${filelist}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gfs.${ymd}_${hh}.gfs.tar ${filelist}
fi

filelist=""
for file in ${pgrb2fhr};
do
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done
if [ ! -z "$filelist" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gfs.${ymd}_${hh}.gfs_pgrb2.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gfs.${ymd}_${hh}.gfs_pgrb2.tar ${filelist}
fi

filelist=""
for file in ${pgrb2bfhr};
do
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done
if [ ! -z "$filelist" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gfs.${ymd}_${hh}.gfs_pgrb2b.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gfs.${ymd}_${hh}.gfs_pgrb2b.tar ${filelist}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gfs.${ymd}_${hh}.gfs_pgrb2b.tar ${filelist}
fi

# Set group permission for rstprod files
$CHGRP_CMD $prepbufr $nsstbufr
chmod 640 $prepbufr $nsstbufr

# Link files into the atmos subdir
#mkdir -p ./gfs.$ymd/$hh/atmos
#cd ./gfs.$ymd/$hh/atmos
#ln -sf ../* ./
#cd -

fi # if [ ${pull_gfs} = "yes" ]; then

date

#===============================================================================
# Files from gdas prod/para/test

if [ ${pull_gdas} = "yes" ]; then

#atmanl="./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.atmanl.nc"
atmanl=""
atmfhr=$(seq -f ./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.atmf%03.3g.nc 3 3 9)

#sfcanl="./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.sfcanl.nc"
sfcanl=""
sfcfhr=$(seq -f ./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.sfcf%03.3g.nc 3 3 9)

#pgrb2fhr=$(seq -f ./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.pgrb2.0p25.f%03.3g 0 3 9)
pgrb2fhr=""

filelist=""
for file in ${atmanl} ${atmfhr} ${sfcanl} ${sfcfhr} ${pgrb2fhr};
do
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done
if [ ! -z "$filelist" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gdas.${ymd}_${hh}.gdas_nc.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gdas.${ymd}_${hh}.gdas_nc.tar ${filelist}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gdas.${ymd}_${hh}.gdas_nc.tar ${filelist}
fi

abias="./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.abias ./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.abias_air ./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.abias_int ./gdas.$ymd/$hh/${atmstr}gdas.t${hh}z.abias_pc"

filelist=""
for file in ${abias};
do
  if [ ! -e ${file} ]; then
    filelist="${filelist} ${file}"
  fi
done
if [ ! -z "$filelist" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gdas.${ymd}_${hh}.gdas.tar ${filelist} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gdas.${ymd}_${hh}.gdas.tar ${filelist}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gdas.${ymd}_${hh}.gdas.tar ${filelist}
fi

# Link files into the atmos subdir
#mkdir -p ./gdas.$ymd/$hh/atmos
#cd ./gdas.$ymd/$hh/atmos
#ln -sf ../* ./
#cd -

fi # if [ ${pull_gdas} = "yes" ]; then

date

#===============================================================================
# Files from enkfgdas prod/para/test

if [ ${pull_enkfgdas} = "yes" ]; then

for ngrp in $(seq 1 1 8);
do
  date
  grp=$(printf %01.1g $ngrp)
  atminc=""; atmfhr=""; sfcfhr=""
  for mem in $( seq -f %03.3g $((${ngrp} * 10 - 9)) 1 $((${ngrp} * 10)) );
  do
    if [[ ${ngrp} -le 4 ]]; then
      if [ ! -e ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.ratminc.nc ]; then
        atminc="${atminc} ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.ratminc.nc"
      fi
      #for fhhh in $( seq -f %03.3g 3 3 9);
    # for fhhh in 003 009;
    # do
    #   if [ ! -e ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.atmf${fhhh}.nc ]; then
    #     atmfhr="${atmfhr} ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.atmf${fhhh}.nc"
    #   fi
    # done
      #for fhhh in $( seq -f %03.3g 3 3 9);
      for fhhh in 006;
      do
        if [ ! -e ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.sfcf${fhhh}.nc ]; then
          sfcfhr="${sfcfhr} ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.sfcf${fhhh}.nc"
        fi
      done
    fi
    #for fhhh in 006;
    for fhhh in $( seq -f %03.3g 3 3 9);
    do
      if [ ! -e ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.atmf${fhhh}.nc ]; then
        atmfhr="${atmfhr} ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.atmf${fhhh}.nc"
      fi
    done
  # #for fhhh in $( seq -f %03.3g 3 3 9);
  # for fhhh in 006;
  # do
  #   if [ ! -e ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.sfcf${fhhh}.nc ]; then
  #     sfcfhr="${sfcfhr} ./enkfgdas.$ymd/$hh/${atmstr}mem${mem}/gdas.t${hh}z.sfcf${fhhh}.nc"
  #   fi
  # done
  done

  #${HTAR} -xpf ${hpssgfspara}/com_gfs_v16.2_enkfgdas.${ymd}_${hh}.enkfgdas_grp${grp}.tar ${atminc} ${atmfhr} ${sfcfhr}
  #if [[ ! -z "${atminc}" ]] || [[ ! -z "${atmfhr}" ]] || [[ ! -z "${sfcfhr}" ]]; then
  if [[ ! -z "${atmfhr}" ]]; then
    ${HTAR} -xpf ${hpssgfsprod5}/com_gfs_v16.2_enkfgdas.${ymd}_${hh}.enkfgdas_grp${grp}.tar ${atmfhr} || \
    ${HTAR} -xpf ${hpssgfsprod5}/com_gfs_prod_enkfgdas.${ymd}_${hh}.enkfgdas_grp${grp}.tar ${atmfhr}
    ${HTAR} -xpf ${hpssgfsprod5}/com_gfs_v16.3_enkfgdas.${ymd}_${hh}.enkfgdas_grp${grp}.tar ${atmfhr}
  fi

done

# Link files into the atmos subdir
#mkdir -p ./enkfgdas.$ymd/$hh/atmos
#cd ./enkfgdas.$ymd/$hh/atmos
#ln -sf ../* ./
#cd -

fi #if [ ${pull_enkfgdas} = "yes" ]; then

##########################
if [ ${pull_wave} = "yes" ]; then
ww3ibp="./gfs.$ymd/$hh/wave/station/gfswave.t${hh}z.ibp_tar"
#ww3rst=$(seq -f --include=gdas.$ymd/$hh/wave/restart/*.%02.2g0000.restart.gnh_10m 0 6 18)
ww3rst="./gdas.$ymd/$hh/wave/restart/$ymd.${hh6}0000.restart.gnh_10m"

if [ ! -z "${ww3ibp}" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gfs.${ymd}_${hh}.gfswave_output.tar ${ww3ibp} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gfs.${ymd}_${hh}.gfswave_output.tar ${ww3ibp}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gfs.${ymd}_${hh}.gfswave_output.tar ${ww3ibp}
fi

if [ ! -z "${ww3rst}" ]; then
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.2_gdas.${ymd}_${hh}.gdaswave_keep.tar ${ww3rst} || \
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_prod_gdas.${ymd}_${hh}.gdaswave_keep.tar ${ww3rst}
  ${HTAR} -xpf ${hpssgfsprod}/com_gfs_v16.3_gdas.${ymd}_${hh}.gdaswave_keep.tar ${ww3rst}
fi

fi #if [ ${pull_wave} = "yes" ]; then

date

#===============================================================================
# Summary of the staged input files
echo === gfs obs files ===
find gfs.$ymd/$hh -type f -name "gfs*bufr*" | xargs ls -l
echo === gfs grib2 files ===
find gfs.$ymd/$hh -type f -name "gfs*pgrb2*" | xargs ls -l
echo === gfs netcdf files ===
find gfs.$ymd/$hh -type f -name "gfs*nc" | xargs ls -l
echo === gdas files ===
find gdas.$ymd/$hh -type f -name "gdas*" | xargs ls -l
echo === enkfgdas files ===
find enkfgdas.$ymd/$hh -type f -name "gdas*" | xargs ls -l

ngfsobs=$(find gfs.$ymd/$hh -type f -name "gfs*bufr*" | wc -l)
ngfsgrb=$(find gfs.$ymd/$hh -type f -name "gfs*pgrb2*" | wc -l)
ngfsnc=$(find gfs.$ymd/$hh -type f -name "gfs*nc" | wc -l)
ngdasf=$(find gdas.$ymd/$hh -type f -name "gdas*" | wc -l)
nenkff=$(find enkfgdas.$ymd/$hh -type f -name "gdas*" | wc -l)

echo === files with wrong time stamps ===
find *.$ymd/$hh -type f -mtime -1 -ls
ntfile=$(find *.$ymd/$hh -type f -mtime -1 -ls | wc -l)

echo "summary: ngfsobs=$ngfsobs; ngfsgrb=$ngfsgrb; ngfsnc=$ngfsnc; ngdasf=$ngdasf; nenkff=$nenkff"
if [[ $ntfile -gt 0 ]]; then
  echo "Warning: Number of $ntfile files potentially have wrong time stamps."
fi

exit

#===============================================================================

