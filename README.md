# OpenDataCam
An implementation of [OpenDataCam 3.0.2](https://github.com/opendatacam/opendatacam) that is fully containerized and can be deployed in one click on the balena platform. Supports Jetson Nano, TX2, AGX Xavier, and AGX Orin.

A detailed tutorial is available [here](https://www.balena.io/blog/using-opendatacam-and-balena-to-quantify-the-world-with-ai/).

## Getting Started

You can use the deploy button below to create and build the application in your [balenaCloud](https://www.balena.io/cloud/) account. (balenaCloud allows you to remotely monitor, update and manage a fleet of one or more devices. You can add your first 10 devices for free!)

[![](https://www.balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/balenalabs-incubator/opendatacam)

Be sure to select your NVIDIA Jetson device type as the default device type. click "add device" to download the image and follow the directions to flash your Jetson board. Alternatively, you can use the balena CLI to push this code to your application.

Once the build is complete and the image has downloaded to your device, you can access OpenDataCam from your browser using the IP of your device. For instance: http://192.168.1.67:8080 (The web interface is on port 8080)


## Configuring OpenDataCam

Opendatacam is configured via the `/var/local/opendatacam/config.json` file. It is a symlink to `/data/odc/config.json` which is located on a persistent volume. Any changes to the file will be saved even if the container restarts. You can see all of the customizations available on [this page](https://github.com/opendatacam/opendatacam/blob/master/documentation/CONFIG.md).

We've exposed the most popular variables as [device variables](https://www.balena.io/docs/learn/manage/variables/) which you can set on the balenaCloud dashboard for one device or a whole fleet at once. Setting these variables will modify your OpenDataCam config.json file. 


**VIDEO_INPUT** - set to `usbcam` for an attached USB camera (default value) or `remote_cam` for an IP camera. If you set to `remote_cam` you need to also set the variable `INPUT_REMOTE_CAM`. The value `file` is also valid, in which case you also need to set the variable `VIDEO_FILE`. (Note that this setup currently does not support `raspberrycam`.)

**INPUT_REMOTE_CAM** - enter the entire IP/URL of a video stream, for instance `rtsp://192.168.1.168/0`- can be anything supported by OpenCV, such as .m3u8, MJPEG, etc...

**INPUT_USBCAM** - set the full value of the `VIDEO_INPUT_PARAMS` for the `usbcam` element. Default value for a typical usb camera is `"v4l2src device=/dev/video0 ! video/x-raw, framerate=30/1, width=640, height=360 ! videoconvert ! appsink"` - mainly used to change the device name if it's not `/dev/video0`.

**VIDEO_FILE** - set the full path and filename of a video file to use as the input when the value of `VIDEO_INPUT` is set to `file`.

**FAN_SPEED** - set to a value between 0 - 255 to control the speed of a compatible PWM fan, if attached. 0 (the default value) is stopped and 255 is the fastest speed. Unlike the other variables above, this one is not part of the config.json file.

