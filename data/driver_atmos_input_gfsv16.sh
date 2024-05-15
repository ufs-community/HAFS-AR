#!/bin/sh --login

# GFSv16 retrospective tests: https://docs.google.com/presentation/d/1OxT0UUNhFBdiRA04alMUMOGEffmJ5BSWUwm9jtcF880/edit?usp=sharing

# Usage
if [ $# -lt 1 ]; then
  echo "Driver script to submit the job_atmos_input.sh jobs to pull the HAFS needed GFSv16 input data."
  echo "Usage: $0 startcycle [endcycle]"
  echo "       $0 yyyymmddhh [yyyymmddhh]"
  echo "e.g.:  $0 2020090100"
  echo "or:    $0 2020090100 2020090218"
  exit
fi

set -x

if [[ -e /lfs/h2/emc ]]; then
 #WCOSS2
# module load ips/18.0.1.163
 module load prod_util/2.0.13
 BSUB="qsub"
# cd /lfs/h2/emc/hafstemp/hafs-input/COMGFSv16
elif [[ -e /scratch1/NCEPDEV/hwrf ]]; then
 #Hera
 module use /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
 module load prod_util/1.1.0
 #BSUB="sbatch --job-name=job --account=hurricane --qos=batch --partition=service --ntasks=1 -o job.log.%j -e job.log.%j -t 12:00:00"
 BSUB="sbatch --job-name=job --account=zrtrr --qos=batch --partition=service --ntasks=1 -t 12:00:00"
# cd /scratch1/NCEPDEV/hwrf/noscrub/Zhan.Zhang/hafs-input/COMGFSv16
elif [[ -e /mnt/lfs4/HFIP ]]; then
 #Jet
 module use /lfs4/HFIP/hfv3gfs/nwprod/hpc-stack/libs/modulefiles/stack
 module load hpc/1.1.0
 module load hpc-intel/18.0.5.274
 module load prod_util/1.2.2
 #BSUB="sbatch --job-name=job --account=hwrfv3 --qos=batch --partition=service --ntasks=1 -o job.log.%j -e job.log.%j -t 12:00:00"
 BSUB="sbatch --job-name=job --account=hwrfv3 --qos=batch --partition=service --ntasks=1 -t 12:00:00"
# cd /mnt/lfs1/HFIP/hwrf-data/hafs-input/COMGFSv16
else
 echo "Unknown platform. Exiting."
 exit
fi

 NDATE=${NDATE:-/gpfs/hps/nco/ops/nwprod/prod_util.v1.0.28/exec/ndate}

 bdate=${1:-2020090700}
 edate=${2:-${bdate-:2020090700}}


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
  #${BSUB} -o logs/job.log.${ymdh} -e logs/job.log.${ymdh} < ./${JOBSH} -v ymdh=${ymdh}
#  ${BSUB} -o logs/job.log.${ymdh} -e logs/job.log.${ymdh} < ./${JOBSH} -V
  ${BSUB} -o logs/job.log.${ymdh} -e logs/job.log.${ymdh} ./${JOBSH} -V
  cdate=$(${NDATE} +6 ${cdate})
done

echo 'done'

