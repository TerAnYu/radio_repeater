#!/bin/sh

#подпрограмма ожидания выключения шумоподавителя. останавливает запись сообщения.

#gpio -g mode 7 in <--  переключить в чтение
#gpio -g read 7 
#если высокий уровень, то отключить запись, если низкий, то включить

/usr/local/bin/gpio -g mode 7 in
SIGNAL=`/usr/local/bin/gpio -g read 7`
while [ $SIGNAL -eq 0 ]; do
   SIGNAL=`/usr/local/bin/gpio -g read 7`
   sleep 1
done 
/usr/bin/killall rec
