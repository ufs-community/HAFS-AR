Running the HAFS global requires GFS physics (sfc) and dynamics (atm)
files at the initialization time. The atm_ic job will interpolate this
to the grid of interest.

Unfortunately, the HAFS workflow lacks a job to pull the data it needs
from HPSS. Typically, a role account (emc.hurdata) owns the data
everyone needs. That data is maintained by one or two people manually.

This directory has the scripts they use. These scripts are not
elegant, polished, workflow scripts intended for general
consumption. They're personal scripts used by a few HAFS developers.

To use them...

1. Pick a directory in a location with lots of disk space.

    mkdir -p /path/to/big/place

2. Copy the three scripts into that location. Be certain to preserve execution flags (cp -p)

    cp -fp /path/to/HAFS/data/*.sh /path/to/big/place/.

3. cd to that location

    cd /path/to/big/place

4. Run the driver script. You can run it for one cycle or a range of cycles. Be sure to
   pick an account you can use, with access to the service queue (hurricane, wrfruc, etc.)

    ./driver_atmos_input_gfsv16.sh some_account_name FIRST-CYCLE LAST-CYCLE
    ./driver_atmos_input_gfsv16.sh some_account_name ONLY-CYCLE

   Where FIRST-CYCLE, LAST-CYCLE, and ONLY-CYCLE have this syntax

     2020090100
     YYYYMMDDHH

     Year 2020, month 9 (September), day 1 of month, hour 0 of day.

5. Wait for it to complete.

NOTE: The log files will have many errors from HTAR due to how the script
works. It will try to pull from a list of tape locations until it
finds the right path. Hence, for each wrong path, HTAR will give an error.

6. Check for the output. It should be in gfs.YYYYMMDD/HH/atmos/ subdirectories.

7. Edit system.conf. Change this line:

   COMgfs=/scratch2/BMC/wrfruc/Samuel.Trahan/westwater/hafs-input/COMGFSv16

Replace it with the /path/to/big/place where you ran the script.

8. Run the workflow, and enjoy your new input case.
