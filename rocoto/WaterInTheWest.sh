#! /bin/bash
set -ue

HOMEhafs=$( cd $( dirname ${BASH_SOURCE[0]} ) ; cd .. ; pwd -P )
source ${HOMEhafs}/ush/hafs_pre_job.sh.inc
set -x

# NOTE: If you're running more than 24 hours, increase the wallclock limit in the rocoto/sites files.
#
# Hera: rocoto/sites/hera.ent
# GAEA C5: rocoto/sites/gaea_c5.ent
#
# Change the FORECAST_WALLTIME entity line:
#
#    <!ENTITY FORECAST_WALLTIME "<walltime>02:59:00</walltime>">
#
# To this:
#
#    <!ENTITY FORECAST_WALLTIME "<walltime>07:59:00</walltime>">

cd ${HOMEhafs}/rocoto
EXPT=$(basename ${HOMEhafs})
SUBEXPT=${EXPT}
opts="-t -f"
scrubopt="config.scrub_work=no config.scrub_com=no"

# Our target configuration, C768 128-level nested tile on a rotated stretched sphere:
conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC768.conf ../parm/WaterInTheWestL128C768.conf'

# See below for alternative conf= lines for other configurations.

# This command generates the workflow xml file and runs rocotorun.
./run_hafs.py ${opts} 2023022400 00L HISTORY \
    config.EXPT=${EXPT} config.SUBEXPT=${SUBEXPT} \
    config.NHRS=6 ${scrubopt} \
    $conf

# ---

# Alternative configurations

# C384 128-level nested tile on a rotated stretched sphere
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC384.conf ../parm/WaterInTheWestL128C384.conf'

# C192 128-level nested tile on a rotated stretched sphere
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC192.conf ../parm/WaterInTheWestL128.conf'

# C96 128-level nested tile on a rotated stretched sphere
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC96.conf ../parm/WaterInTheWestL128.conf'

# C384 128-level rotated stretched sphere with no nest
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC384.conf ../parm/WaterInTheWestL128.conf ../parm/WaterInTheWestC384NoNest.conf'

# C768 128-level rotated stretched sphere with no nest
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC768.conf ../parm/WaterInTheWestL128C768.conf ../parm/WaterInTheWestC768NoNest.conf'

# C384 128-level uniform sphere (like GFS)
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC384.conf ../parm/WaterInTheWestL128.conf ../parm/WaterInTheWestC384Uniform.conf'

# C768 128-level uniform sphere (like GFS)
# conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC768.conf ../parm/WaterInTheWestL128C768.conf ../parm/WaterInTheWestC768NoNest.conf'
