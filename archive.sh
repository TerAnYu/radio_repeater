#!/bin/bash


logfacility="/usr/bin/logger -t REPITER"

sleep 2
workdir="/opt/repeater/tmp"
rec_arch="/opt/repeater/archive/`date +%Y`/`date +%m`/`date +%d`"
timestamp="`date +%H:%M:%S`"
datetime="`date '+%F %T'`"

mkdir -p $rec_arch

cp $workdir/rec.wav $workdir/$timestamp.wav
rm $workdir/rec*
/usr/bin/lame -S -b 64 --tt "$datetime" --ta "АРК Томск" $workdir/$timestamp.wav $rec_arch/$timestamp.mp3

echo "ARCHIVE $datetime $timestamp $inethere" | $logfacility
