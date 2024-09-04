#! /bin/bash
set -ue

HOMEhafs=$( cd $( dirname ${BASH_SOURCE[0]} ) ; cd .. ; pwd -P )
source ${HOMEhafs}/ush/hafs_pre_job.sh.inc
set -x

cd ${HOMEhafs}/rocoto
EXPT=$(basename ${HOMEhafs})
SUBEXPT=${EXPT}
opts="-t -f"
scrubopt="config.scrub_work=no config.scrub_com=no"

# Our target configuration, C768 128-level nested tile on a rotated stretched sphere:
conf='../parm/WaterInTheWest.conf ../parm/WaterInTheWestC768.conf ../parm/WaterInTheWestL128C768.conf'

# NOTE: If you're running 24 hours or less, consider reducing the wallclock limit.
# In rocoto/sites/gaea_c5.ent or rocoto/sites/hera.ent, change the walltime line:
#    <!ENTITY FORECAST_WALLTIME "<walltime>07:59:00</walltime>">
# Three hours should be enough for short forecasts.
#    <!ENTITY FORECAST_WALLTIME "<walltime>02:59:00</walltime>">

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

# Run run_hafs.py to generate the workflow xml file and runs the workflow.
./run_hafs.py ${opts} 2023022400 00L HISTORY \
    config.EXPT=${EXPT} config.SUBEXPT=${SUBEXPT} \
    config.NHRS=6 ${scrubopt} \
    $conf
