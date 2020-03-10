#!/bin/bash

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

if [[ -z $VIDEO_FILE ]]; then
  echo 'Video file not specified - defaulting to /data/demo.mp4'
  sed -i 's|zz4|\/data\/demo.mp4|' config.json
else
  echo 'Video file set to '$VIDEO_FILE
  sed -i "s;zz4;$VIDEO_FILE;" config.json
fi

# Change local URLs to container name
sed -i "s;parsedUrl\[0\];'opendatacam';" server/utils/urlHelper.js

# Sleep 5s to let mongod some time to initialize
sleep 5

# Start the OpenDataCam process
npm run start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start npm run start: $status"
  exit $status
fi

