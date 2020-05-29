#!/bin/bash

# Modify config.json based on config vars
# returning soon!

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

