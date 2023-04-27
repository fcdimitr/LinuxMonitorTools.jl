#!/usr/bin/env bash

# see https://www.baeldung.com/linux/process-periodic-cpu-usage

MYPID=$1
MYLOG=$2
BPATH=$3

echo $MYPID
echo $MYLOG
echo $BPATH

while true; do
    DT=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$DT,$(ps   -o rss=  -p $MYPID)" >> ${BPATH}/${MYLOG}_${MYPID}_memrss.csv
    echo "$DT,$(ps   -o %cpu= -p $MYPID)" >> ${BPATH}/${MYLOG}_${MYPID}_cpu.csv
    # ps x -o rss= -p $MYPID >> /tmp/$2_$MYPID.log
    sleep 1.0
done
