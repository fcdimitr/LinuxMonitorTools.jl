#!/usr/bin/env bash

# see https://www.baeldung.com/linux/process-periodic-cpu-usage

MYPID=$1
MYLOG=$2
BPATH=$3

echo $MYPID
echo $MYLOG
echo $BPATH

while true; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') :: $(ps   -o rss=  -p $MYPID)" >> ${BPATH}/${MYLOG}_${MYPID}_memrss.log
    echo "$(date +'%Y-%m-%d %H:%M:%S') :: $(ps   -o %cpu= -p $MYPID)" >> ${BPATH}/${MYLOG}_${MYPID}_cputot.log
    top -n 1 -b -p $MYPID | awk \
    -v cpuLog="${BPATH}/${MYLOG}_${MYPID}_cpurt.log" -v pid="$MYPID" -v pname="myproc" '
    /^top -/{time = $3}
    $1+0>0 {printf "%s %s :: %d%%\n", \
            strftime("%Y-%m-%d"), time, $9 >> cpuLog
            fflush(cpuLog)}'
    # ps x -o rss= -p $MYPID >> /tmp/$2_$MYPID.log
    sleep 1
done
