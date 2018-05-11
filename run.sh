#!/bin/bash
logfacility="/usr/bin/logger -t REPITER"
#gpio -g mode 7 in <--  переключить в чтение
#gpio -g read 7 
#если высокий уровень, то отключить запись, если низкий, то включить

echo "RUN SCRIPT STARTED"| $logfacility

recdir=/opt/repeater/tmp
repdir=/opt/repeater

export AUDIODEV="hw:1"
#4й пин через транзистор и 2 реле включает передачу на радиостанции
/usr/local/bin/gpio -g mode 4 out
/usr/local/bin/gpio -g write 4 0
#на 7й пин подключен шумодав через транзистор. если шумодав открывается, то начинается запись
/usr/local/bin/gpio -g mode 7 in
play -q ./sounds/roger.wav 

/usr/bin/amixer -q -c 1 -- sset Mic CAPTURE 60%
/usr/bin/amixer -q -c 1 -- sset "Auto Gain Control" off
/usr/bin/amixer -q -c 1 -- sset Headphone playback -27.50dB #-27.50 max

while [ 1 ]; do
   #проверяем открыт ли шумодав
   SIGNAL=`/usr/local/bin/gpio -g read 7`
   if [ $SIGNAL -eq 0 ] 
    then
    $repdir/wait_end.sh &
    $repdir/led/record 1
    /usr/bin/rec -q -b 16 -c 1 $recdir/rec.wav trim 0 30
    #фильтруем шумы от оборудования
    #/usr/bin/sox $recdir/rectmp.wav $recdir/rec.wav noisered $repdir/noise-profile 0.3
    #mv $recdir/rectmp.wav $recdir/rec.wav
    #sleep 1
    #срезаем мелкие пшики, минимальная длина сообщения 3 секунды.
    durationfloat=$(/usr/bin/soxi -D $recdir/rec.wav)
    #если вдруг ошибка
    if [ "$?" -ne "0" ]; then
	echo "Duration failed" |$logfacility
	durationfloat=0
    fi
    duration=${durationfloat%.*}
    echo "REC $durationfloat"| $logfacility
    $repdir/led/record 0
    if [ $duration -ge 3 ]  &&  [ $duration -le 31 ] 
	then 
	    $repdir/led/play 1
	    touch last_activity
	    #/usr/bin/amixer -q -c 1 -- sset Mic 30% mute
	    echo "PLAY $duration"| $logfacility
	    /usr/local/bin/gpio -g write 4 1
	    $repdir/led/transmit 1
	    /usr/bin/play -G -q --norm=-7 $recdir/rec.wav
	    /usr/bin/play -G -q  ./sounds/roger.wav 
	    /usr/local/bin/gpio -g write 4 0
	    $repdir/led/transmit 0
	    $repdir/archive.sh &
	    touch last_activity
	    #/usr/bin/amixer -q -c 1 -- sset Mic 60%
	    $repdir/led/play 0
	else
	    rm $recdir/rec.wav
	fi
    fi
   sleep 0.1
done 
