#!/bin/bash
########## https://t.me/peace_data_bot
########## License: WTFPL
########## Source: https://github.com/Overtorment/peace_data_bot

# script should run every 30 min
# */30 * * * *  bash script.sh

USERID="60433198"
KEY=`cat key`
TIMEOUT="3"
URL="https://api.telegram.org/bot$KEY/sendMessage"
URL2="https://api.telegram.org/bot$KEY/getUpdates"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BTCUSD=`curl --max-time $TIMEOUT --retry 3 --retry-max-time 10 https://www.bitstamp.net/api/v2/ticker/btcusd/ 2>/dev/null  | sed  's/\,/\n/g' | grep last | awk  -F':' '{print $2}'  | sed 's/\"//g'  | sed 's/ //g' `
if [ -z $BTCUSD ];
then
    exit
fi

#fetching update id
UPDATE_ID=`curl -s --max-time $TIMEOUT --retry 3 --retry-max-time 10 $URL2 2>/dev/null | sed 's/,/\n/g'  | sed 's/{/\n/g' | grep update_id | awk -F":" '{print $2}' | sort -n | tail -n 1` 
UPDATE_ID=`expr $UPDATE_ID + 1`


# fetching user's ids
IDS=`curl -s --max-time $TIMEOUT --retry 3 --retry-max-time 10 $URL2 2>/dev/null | sed 's/,/\n/g'  | sed 's/{/\n/g' | grep -v update_id | grep -v message_id  | grep id | awk -F":" '{print $2}' |  sort -u ` 
for ID in $IDS
do
    echo $ID >> $DIR/userids.log
done
##

# ACK
curl -s --max-time $TIMEOUT --retry 3 --retry-max-time 10 "$URL2?offset=$UPDATE_ID" >/dev/null


echo $BTCUSD
echo $BTCUSD >> $DIR/btcusd.log
echo $USERID >> $DIR/userids.log
cat $DIR/userids.log | sort -u > $DIR/userids.log.uniq
mv $DIR/userids.log.uniq $DIR/userids.log

HIGHEST=`cat $DIR/btcusd.log | sort -n | tail -n 1`
if [ $HIGHEST = $BTCUSD ]
then
    TEXT=`awk 'NR % 2 == 0' $DIR/btcusd.log | tail -n 22 | /usr/local/bin/spark`
    TEXT="Новый Хай! \$$BTCUSD Дневка: $TEXT"
    for ID in `cat $DIR/userids.log`
    do
        curl -s --max-time $TIMEOUT -d "chat_id=$ID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null    
    done
    exit
fi


LOWEST=`cat $DIR/btcusd.log | tail -n 336 | sort -n | head -n 1`
if [ $LOWEST = $BTCUSD ]
then
    TEXT=`awk 'NR % 14 == 0' $DIR/btcusd.log | tail -n 22 | /usr/local/bin/spark`
    TEXT="ВРЕМЯ ЗАКУПАТЬСЯ! Лучшая цена за неделю: \$$BTCUSD Неделя: $TEXT"
    for ID in `cat $DIR/userids.log`
    do
        curl -s --max-time $TIMEOUT -d "chat_id=$ID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null    
    done
    exit
fi



LOWEST=`cat $DIR/btcusd.log | tail -n 96 | sort -n | head -n 1`
if [ $LOWEST = $BTCUSD ]
then
    TEXT=`awk 'NR % 4 == 0' $DIR/btcusd.log | tail -n 22 | /usr/local/bin/spark`
    TEXT="Пора закупаться! Лучшая цена за 48ч: \$$BTCUSD Двухдневка: $TEXT"
    for ID in `cat $DIR/userids.log`
    do
        curl -s --max-time $TIMEOUT -d "chat_id=$ID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null    
    done
    exit
fi



LOWEST=`cat $DIR/btcusd.log | tail -n 48 | sort -n | head -n 1`
if [ $LOWEST = $BTCUSD ]
then
    TEXT=`awk 'NR % 2 == 0' $DIR/btcusd.log | tail -n 24 | /usr/local/bin/spark`
    TEXT="Пора закупаться! Лучшая цена за 24ч: \$$BTCUSD Дневка: $TEXT"
    for ID in `cat $DIR/userids.log`
    do
        curl -s --max-time $TIMEOUT -d "chat_id=$ID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null    
    done
    exit
fi