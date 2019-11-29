#!/bin/bash

time=$(date +%m)

DB_USER=`awk -F "'" '{if (NR==10) {gsub(",","");print $4}}' /var/www/pn/sites/default/settings.php`
DB_NAME=`awk -F "'" '{if (NR==9) {gsub(",","");print $4}}' /var/www/pn/sites/default/settings.php`
DB_PASS=`awk -F "'" '{if (NR==11) {gsub(",","");print $4}}' /var/www/pn/sites/default/settings.php`
SCP_USER=user
SCP_HOST=address
DUMP_PATH=/var/backup/db/
DUMP=`date +%Y_%m_%d_00_00`.sql.gz
LOG=/var/log/update.log

cd /var/www/pn

echo "Remove dir1 & dir2" | rm -rf /var/www/dir1 /var/www/dir2 >> $LOG 2>&1
echo "Create dir1 & dir2" | mkdir /var/www/dir1 /var/www/dir2 && chmod 755 /var/www/dir1 /var/www/dir2 && sudo chown www-data:www-data /var/www/dir1 /var/www/dir2 >> $LOG 2>&1

echo "Drop & create database" | mysql -u $DB_USER -p$DB_PASS -e "drop database $DB_NAME; create database $DB_NAME character set utf8 collate utf8_general_ci;" >> $LOG 2>&1

echo "Copy base from archive" | su backuper -s /bin/bash -c "scp $SCP_USER@$SCP_HOST:$DUMP_PATH$DUMP /var/backup/" >> $LOG 2>&1

echo "Unzip dump & update DB" | gunzip < /var/backup/$DUMP | mysql -u $DB_USER -p$DB_PASS $DB_NAME >> $LOG 2>&1

echo "Execute shell commands" | su www-data -s /bin/bash -c "some shell commands" >> $LOG 2>&1

echo $(($(date +%m)-$time))

