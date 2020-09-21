# OpenDataCam
An implementation of [OpenDataCam 3.0.1](https://github.com/opendatacam/opendatacam) that is fully containerized and runs on balena + Jetson Nano/TX2/Xavier. This version uses one of our standard balena Jetson base images along with Debian packages that provide all necessary JetPack components (CUDA, cuDNN, etc...) so you do not need to download the NVIDIA SDK Manager or install the JetPack.

A detailed tutorial is available [here](https://www.balena.io/blog/using-opendatacam-and-balena-to-quantify-the-world-with-ai/).

## Getting Started

You can use the deploy button below to create and build the application in your [balenaCloud](https://www.balena.io/cloud/) account. (balenaCloud allows you to remotely monitor, update and manage your device. You can add your first 10 devices for free!)

[![](https://www.balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy)

Be sure to select "Nvidia Jetson Nano" (or another Jetson device) as the device type. click "add device" to download the image and burn it to an SD card using [Etcher](https://www.balena.io/etcher/). Alternatively, you can use the balena CLI to push this code to your application.

Once the build is complete and the image has downloaded to your device, you can access OpenDataCam from your browser using the IP of your Nano. For instance: http://192.168.1.67:8080 (The web interface is on port 8080)


## Configuring OpenDataCam

Opendatacam is configured via the /var/local/opendatacam/config.json file. It is a symlink to /data/odc/config.json which is located on a persistent volume. Any changes to the file will be saved even if the container restarts. You can see all of the customizations available on [this page](https://github.com/opendatacam/opendatacam/blob/master/documentation/CONFIG.md).

You can set the device variables below in the balenaCloud dashboard which will modify your OpenDataCam config.json file. 


**VIDEO_INPUT** - set to `usbcam` for an attached USB camera (default value) or `remote_cam` for an IP camera. If you set to `remote_cam` you need to also set the variable `INPUT_REMOTE_CAM`. The value `file` is also valid, in which case you also need to set the variable `VIDEO_FILE`. (Note that this setup currently does not support `raspberrycam`.)

**INPUT_REMOTE_CAM** - enter the entire IP/URL of a video stream, for instance `rtsp://192.168.1.168/0`- can be anything supported by OpenCV, such as .m3u8, MJPEG, etc...

**INPUT_USBCAM** - set the full value of the `VIDEO_INPUT_PARAMS` for the `usbcam` element. Default value for a typical usb camera is `"v4l2src device=/dev/video0 ! video/x-raw, framerate=30/1, width=640, height=360 ! videoconvert ! appsink"` - mainly used to change the device name if it's not `/dev/video0`.

**VIDEO_FILE** - set the full path and filename of a video file to use as the input when the value of `VIDEO_INPUT` is set to `file`.

**FAN_SPEED** - set to a value between 0 - 255 to control the speed of a compatible PWM fan, if attached. 0 (the default value) is stopped and 255 is the fastest speed. Unlike the other variables above, this one is not part of the config.json file.

