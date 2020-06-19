# OpenDataCam
An implementation of [OpenDataCam 3.0.0-beta.3](https://github.com/opendatacam/opendatacam) that is fully containerized and runs on balena + Jetson Nano.

A more detailed tutorial will be available soon.

## Getting Started

This project now uses our experimental [jetson-nano-cuda-cudnn-opencv](https://hub.docker.com/repository/docker/resinplayground/jetson-nano-cuda-cudnn-opencv) image, so you no longer need to download the NVIDIA SDK Manager. You can use the deploy button below to create and build the application in your [balenaCloud](https://www.balena.io/cloud/) account. (balenaCloud allows you to remotely monitor, update and manage your device. You can add your first 10 devices for free!) - NOTE: The delpoy button is still tied to version 2.0.1 until this branch is merged. To use version 3.0.0 you'll need to download this code and [deploy manually](https://www.balena.io/docs/learn/deploy/deployment/).

[![](https://www.balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy)

Be sure to select "Nvidia Jetson Nano" as the device type. click "add device" to download the image and burn it to an SD card using [Etcher](https://www.balena.io/etcher/). Alternatively, you can use the balena CLI to push this code to your application.

Once the build is complete and the image has downloaded to your device, you can access OpenDataCam from your browser using the IP of your Nano. For instance: http://192.168.1.67:8080 (The web interface is on port 8080)


## Device Variables

You can set the device variables below in the balenaCloud dashboard to modify your OpenDataCam configuration. Setting a variable value will modify your OpenDataCam config.json file each time your container starts, before OpenDataCam loads. If you don't set any variables, it will not modify the config.json file. If you delete a variable in the dashboard, that setting will revert back to its value in the config.json file.


**VIDEO_INPUT** - set to `usbcam` for an attached USB camera (default value) or `remote_cam` for an IP camera. If you set to `remote_cam` you need to also set the variable `INPUT_REMOTE_CAM`. The value `file` is also valid, in which case you also need to set the variable `VIDEO_FILE`. (Note that this setup currently does not support `raspberrycam`.)

**INPUT_REMOTE_CAM** - enter the entire IP/URL of a video stream, for instance `rtsp://192.168.1.168/0`- can be anything supported by OpenCV, such as .m3u8, MJPEG, etc...

**INPUT_USBCAM** - set the full value of the `VIDEO_INPUT_PARAMS` for the `usbcam` element. Default value for a typical usb camera is `"v4l2src device=/dev/video0 ! video/x-raw, framerate=30/1, width=640, height=360 ! videoconvert ! appsink"` - mainly used to change the device name if it's not `/dev/video0`.

**VIDEO_FILE** - set the full path and filename of a video file to use as the input when the value of `VIDEO_INPUT` is set to `file`.

