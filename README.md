# OpenDataCam
An implementation of [OpenDataCam 2.0.1](https://github.com/opendatacam/opendatacam) that is fully containerized and runs on balena + Jetson Nano.

This is working but still being improved - more information to follow soon.

## Getting Started

This project now uses our experimental [jetson-nano-cuda-cudnn-opencv](https://hub.docker.com/repository/docker/resinplayground/jetson-nano-cuda-cudnn-opencv) image, so you no longer need to download the NVIDIA SDK Manager. In fact, you can now deploy directly to your device using the button below! Simply download the image and flash it to your SD card using [Etcher](https://www.balena.io/etcher/). (You'll need to sign up for a free [balenaCloud](https://www.balena.io/cloud/) account if you don't already have one.)

[![](https://www.balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy)

Once the build is complete and the image has downloaded to your device, you can access OpenDataCam from your browser using the IP of your Nano. For instance: http://192.168.1.67 (it is currently set to use port 80, but you can change that with a device variable, see below.)


## Device Variables

You can set the following device variables in the balenaCloud dashboard to modify your OpenDataCam configuration:

**VIDEO_INPUT** - set to `usbcam` for an attached USB camera (default value) or `remote_cam` for an IP camera. If you set to `remote_cam` you need to also set the variable `CAM_IP`. The value `file` is also valid, in which case you also need to set the variable `VIDEO_FILE`.

**CAM_IP** - enter the entire IP/URL of a video stream, for instance `rtsp://192.168.1.168/0`- can be anything supported by OpenCV, such as .m3u8, MJPEG, etc...

**CAM_DEV** - sets the device name for the USB camera to use if `VIDEO_INPUT` is set to `usbcam` - default value is `video0`, in other words the camera device would be `/dev/video0` - you should not enter the `/dev/` part which is assumed.

**VIDEO_FILE** - set the full path and filename of a video file to use as the input when the value of `VIDEO_INPUT` is set to `file`.


