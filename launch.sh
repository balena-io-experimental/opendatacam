#!/bin/bash

# Run the fan based on FAN_SPEED variable:
if [[ -z $FAN_SPEED ]]; then
  echo "FAN_SPEED value not set."
else
  echo $FAN_SPEED > /sys/devices/pwm-fan/target_pwm
  echo "FAN_SPEED set to "$FAN_SPEED
fi

# Copy config.json to persistent folder on first run
CONFIG=/data/odc/config.json
if test -f "$CONFIG"; then
  echo "Config file exists in persistent volume."
else
  echo "Moving default config file to persistent volume."
  cp /var/local/opendatacam/config.bak $CONFIG
fi

# Create a symlink to persistent config.json
ln -sf $CONFIG /var/local/opendatacam/config.json

# Modify config.json based on config vars (requires jq JSON processor utility installed via Dockerfile)

if [[ -z $VIDEO_INPUT ]]; then
  a=$(cat config.json | jq '.VIDEO_INPUT')
  echo 'Using video input value from config.json: '$a
else
  echo 'Updating config.json video input value from dashboard device variable: '$VIDEO_INPUT
  jq '.VIDEO_INPUT = env.VIDEO_INPUT' $CONFIG > "tmp" && mv "tmp" $CONFIG
fi

if [[ -z $INPUT_FILE ]]; then
  a=$(cat config.json | jq '.VIDEO_INPUTS_PARAMS.file')
  echo 'Using video input file value from config.json: '$a
else
  echo 'Updating config.json video input file value from dashboard device variable: '$INPUT_FILE
  jq '.VIDEO_INPUTS_PARAMS.file = env.INPUT_FILE' $CONFIG > "tmp" && mv "tmp" $CONFIG
fi

if [[ -z $INPUT_USBCAM ]]; then
  a=$(cat config.json | jq '.VIDEO_INPUTS_PARAMS.usbcam')
  echo 'Using video input usbcam value from config.json: '$a
else
  echo 'Updating config.json video input usbcam value from dashboard device variable: '$INPUT_USBCAM
  jq '.VIDEO_INPUTS_PARAMS.usbcam = env.INPUT_USBCAM' $CONFIG > "tmp" && mv "tmp" $CONFIG
fi

if [[ -z $INPUT_REMOTE_CAM ]]; then
  a=$(cat config.json | jq '.VIDEO_INPUTS_PARAMS.remote_cam')
  echo 'Using video input remote_cam value from config.json: '$a
else
  echo 'Updating config.json video input remote_cam value from dashboard device variable: '$INPUT_REMOTE_CAM
  jq '.VIDEO_INPUTS_PARAMS.remote_cam = env.INPUT_REMOTE_CAM' $CONFIG > "tmp" && mv "tmp" $CONFIG
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

