#!/bin/bash

# GFSv16 retrospective tests: https://docs.google.com/presentation/d/1OxT0UUNhFBdiRA04alMUMOGEffmJ5BSWUwm9jtcF880/edit?usp=sharing

# Usage
if [ $# -lt 1 ]; then
  echo "Driver script to submit the job_atmos_input.sh jobs to pull the HAFS needed GFSv16 input data."
  echo "Usage: $0 ACCOUNT_NAME startcycle [endcycle]"
  echo "       $0 ACCOUNT_NAME yyyymmddhh [yyyymmddhh]"
  echo "e.g.:  $0 ACCOUNT_NAME 2020090100"
  echo "or:    $0 ACCOUNT_NAME 2020090100 2020090218"
  echo "Where ACCOUNT_NAME is a scheduler account you can use (hurricane, wrfruc, etc.)"
  exit
fi

set -x

ACCOUNT=$1

if [[ -e /lfs/h2/emc ]]; then
 #WCOSS2
 BSUB="qsub"
elif [[ -e /scratch1/NCEPDEV/hwrf ]]; then
 #Hera
 BSUB="sbatch --job-name=job --account=$ACCOUNT --qos=batch --partition=service --ntasks=1 -t 12:00:00"
elif [[ -e /mnt/lfs4/HFIP ]]; then
 #Jet
 BSUB="sbatch --job-name=job --account=$ACCOUNT --qos=batch --partition=service --ntasks=1 -t 12:00:00"
else
 echo "Unknown platform. Exiting."
 exit
fi

 bdate=${2:-2020090700}
 edate=${3:-${bdate-:2020090700}}

add_six_hours() {
    local yyyy mm dd hh posix
    yyyy=${1:0:4}
    mm=${1:4:2}
    dd=${1:6:2}
    hh=${1:8:2}
    posix="${yyyy}-${mm}-${dd}t${hh}:00:00 UTC"
    date -d "$posix + 6 hours" +%Y%m%d%H
}

#export hpssgfspararoot=${hpssgfspararoot:-/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_D/gfsv16/v16rt2}
#export hpssgfsprodroot=${hpssgfsprodroot:-/NCEPPROD/hpssprod/runhistory}
#export hpssgfspararoot=${hpssgfspararoot:-/NCEPPROD/hpssprod/runhistory}
#export hpssgfsprodroot=${hpssgfsprodroot:-/NCEPPROD/hpssprod/runhistory}

 export pull_obsbufr=no
 export pull_gfs=yes
 export pull_gdas=no
 export pull_enkfgdas=no
 export pull_wave=no

cdate=${bdate}

while [[ ${cdate} -le ${edate} ]];
do
  echo ${cdate}
  ymdh=${cdate}
  export ymdh=${ymdh}

  if [[ ${cdate} -ge "2021032200" ]]; then
    hpssgfspararoot=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_D/gfsv16/v16rt2
    hpssgfsprodroot=/NCEPPROD/hpssprod/runhistory
    JOBSH="job_atmos_input_gfsv16prod.sh"
  else
    JOBSH="job_atmos_input_gfsv16retro.sh"
  fi

  if [[ ${cdate} -ge "2020082018" ]]; then
    export atmstr="atmos/"
  else
    export atmstr=""
  fi

  # For pulling the EMC parallel version GFSv16 input data from its default location
  if [[ ${cdate} -ge "2019101706" ]] && [[ ${cdate} -le "2020122300" ]]; then
    export hpssgfspararoot=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_D/gfsv16/v16rt2
  fi

  # For pulling the NCO parallel version GFSv16 input data between 2020122300 and 2021032506
  if [[ ${cdate} -ge "2020122300" ]] && [[ ${cdate} -le "2021032506" ]]; then
    export hpssgfspararoot=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_D/gfsv16/v16rt2n
  fi
  # For pulling the HDOBS version GFSv16 input data between 2020060106 and 2020060812
  if [[ ${cdate} -ge "2020060106" ]] && [[ ${cdate} -le "2020060812" ]]; then
    export hpssgfspararoot=/NCEPDEV/emc-global/5year/glopara/HERA/gfsv16/v16hdobs
  fi
  # For pulling the HDOBS version GFSv16 input data between 2019082318 and 2019100212
  if [[ ${cdate} -ge "2019082318" ]] && [[ ${cdate} -le "2019100212" ]]; then
    export hpssgfspararoot=/NCEPDEV/emc-global/5year/glopara/HERA/gfsv16/v16hdobs
  fi
  # For pulling the GFSv16 input data between 20180831 and 20181013
  if [[ ${cdate} -ge "2018083100" ]] && [[ ${cdate} -le "2018101300" ]]; then
    export hpssgfspararoot=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_D/gfsv16/v16retro5e
  fi
  mkdir -p logs
  rm -f logs/job.log.${ymdh}
  cat ./${JOBSH} | sed "s,_ACCOUNT_NAME_,$ACCOUNT,g" | \
      ${BSUB} -o logs/job.log.${ymdh} -e logs/job.log.${ymdh}

  cdate=$( add_six_hours $cdate )
done

echo 'done'

