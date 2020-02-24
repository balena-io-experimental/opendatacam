#!/bin/bash

# THIS RUNS INSIDE THE DOCKER CONTAINER (it is copied to the docker container at build time)
# Using: https://docs.docker.com/config/containers/multi-service_container/
# systemd isn't available on ubuntu inside docker
# Maybe can use pm2 inside a docker container

# Modify config.json based on config vars
if [[ -z $VIDEO_INPUT ]]; then
  echo 'Video input not specified - defaulting to usbcam'
  sed -i 's/zz1/usbcam/' config.json
else
  echo 'Video input set to '$VIDEO_INPUT
  sed -i "s/zz1/$VIDEO_INPUT/" config.json
fi

if [[ -z $CAM_DEV ]]; then
  echo 'Camera not specified - defaulting to video0'
  sed -i 's/zz2/video0/' config.json
else
  echo 'Camera name set to '$CAM_DEV
  sed -i "s;zz2;$CAM_DEV;" config.json
fi

if [[ -z $CAM_IP ]]; then
  echo 'Camera IP not specified - defaulting to none'
  sed -i 's/zz3/none/' config.json
else
  echo 'Camera IP set to '$CAM_IP
  sed -i "s;zz3;$CAM_IP;" config.json
fi

#if [[ -z $DC_PORT ]]; then
#  echo 'Port not specified - defaulting to 8080'
#else
#  echo 'Port set to '$DC_PORT
#  sed -i "s;PORT=8080;PORT=$DC_PORT;" package.json
#fi

sed -i "s;parsedUrl\[0\];'opendatacam';" server/utils/urlHelper.js

# Start the first process
mongod &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start mongod: $status"
  exit $status
fi

# Sleep 5s to let mondod some time to initialize
sleep 5

# Start the second process
#npm run start
#status=$?
#if [ $status -ne 0 ]; then
#  echo "Failed to start npm run start: $status"
#  exit $status
#fi
sleep infinity

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

# while sleep 60; do
#   ps aux |grep my_first_process |grep -q -v grep
#   PROCESS_1_STATUS=$?
#   ps aux |grep my_second_process |grep -q -v grep
#   PROCESS_2_STATUS=$?
#   # If the greps above find anything, they exit with 0 status
#   # If they are not both 0, then something is wrong
#   if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
#     echo "One of the processes has already exited."
#     exit 1
#   fi
# done
