#!/bin/bash

# Shell script to manage a pool of consumer processes

MAX_INSTANCES=6
LOCK_FILE=/var/run/consumer_pool.lock

# Check if lock file exists
if [ -f "$LOCK_FILE" ]; then
  echo "Lock file exists, exiting."
  exit 1
fi

# Create lock file
touch "$LOCK_FILE"

# Cleanup function to remove lock file
function cleanup {
  rm -f "$LOCK_FILE"
}

# Register cleanup function to run on exit
trap cleanup EXIT

# Start consumers
while true; do
  CURRENT_INSTANCES=$(ps ax | grep -v grep | grep -ie ":[0-9]\{2\} php /var/www/app/artisan consume --persistent" | wc -l)

  if (( CURRENT_INSTANCES < MAX_INSTANCES )); then
    php /var/www/app/artisan consume --persistent >> /var/log/consumer.log 2>&1 &
  fi

  # Wait a bit before checking again
  sleep 5
done
