#!/bin/bash

time=$(date +%m)

# Load configuration from file
source /etc/myconfig.conf

# Drop and create database
echo "Drop and create database" >> $LOG 2>&1
mysql -u $DB_USER -p$DB_PASS -e "drop database $DB_NAME; create database $DB_NAME character set utf8 collate utf8_general_ci;" >> $LOG 2>&1

# Copy database dump from remote host
echo "Copy database dump from remote host" >> $LOG 2>&1
sudo -u backuper scp $SCP_USER@$SCP_HOST:$DUMP_PATH$DUMP /var/backup/ >> $LOG 2>&1

# Unzip dump and update database
echo "Unzip dump and update database" >> $LOG 2>&1
gunzip < /var/backup/$DUMP | mysql -u $DB_USER -p$DB_PASS $DB_NAME >> $LOG 2>&1

# Execute shell commands
echo "Execute shell commands" >> $LOG 2>&1
sudo -u www-data some shell commands >> $LOG 2>&1

echo $(($(date +%m)-$time))
