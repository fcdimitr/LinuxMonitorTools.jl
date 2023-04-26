#!/usr/bin/env bash

# see https://www.baeldung.com/linux/process-periodic-cpu-usage

MYPID=$1
MYLOG=$2
BPATH=$3

echo $MYPID
echo $MYLOG
echo $BPATH

while true; do
    DT=$(date +'%Y-%m-%d %H:%M:%S.%3N')
    echo "$DT,$(ps   -o rss=  -p $MYPID)" >> ${BPATH}/${MYLOG}_${MYPID}_memrss.csv
    echo "$DT,$(ps   -o %cpu= -p $MYPID)" >> ${BPATH}/${MYLOG}_${MYPID}_cputot.csv
    top -n 1 -b -p $MYPID | awk \
    -v cpuLog="${BPATH}/${MYLOG}_${MYPID}_cpurt.csv" -v pid="$MYPID" -v pname="myproc" -v dt="$DT" \ '
    /^top -/{time = $3}
    $1+0>0 {printf "%s, %d\n", \
            dt, $9 >> cpuLog
            fflush(cpuLog)}'
    # ps x -o rss= -p $MYPID >> /tmp/$2_$MYPID.log
    sleep 0.5
done
