#!/bin/bash

# shell script for maintain $MAX_INSTANCES of consumer
# can be used to maintain a certain number of threads of something

MAX_INSTANCES=6
CURRENT_INSTANCES=0

while (( "$CURRENT_INSTANCES" != "$MAX_INSTANCES" ))
do
    sleep 5
    CURRENT_INSTANCES=$(ps ax | grep -v grep | grep -ie ":[0-9]\{2\} php /var/www/scoring_2/artisan consume --persistent" 
| wc -l)

    if (( "$CURRENT_INSTANCES" > "$MAX_INSTANCES" ))
	then
        DIFF_INSTANCES=$(( $CURRENT_INSTANCES - $MAX_INSTANCES ))
	PIDS=$(ps -ef | grep -v grep | grep ":[0-9]\{2\} php /var/www/scoring_2/artisan consume --persistent" | awk 
'{print $2}' | head -n $DIFF_INSTANCES)
	kill -9 $PIDS
	exit 0;
    elif (( "$CURRENT_INSTANCES" < "$MAX_INSTANCES" ))
	then
        php /var/www/scoring_2/artisan consume --persistent &
    fi
done
