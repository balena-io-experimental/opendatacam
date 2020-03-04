# OpenDataCam
An implementation of [OpenDataCam](https://github.com/opendatacam/opendatacam) that is fully containerized and runs on balena + Jetson Nano.

This is working but still being improved - more information to follow soon.

## Getting Started

[Download the Nvidia SDK Manager](https://developer.nvidia.com/nvidia-sdk-manager) and install it on your development computer. It will only run on Ubuntu 16 or Ubuntu 18 with a minimum of 8GB RAM. Once installed, open the SDK Manager and select your development environment. You only need to download the development files so you do not need to connect your Jetson to your computer and you should not use this tool to flash the device.

Make sure to select “Target Hardware” and click “Continue to step 02.” Once you get to step 02, make sure the “Jetson OS” box and the “Jetson SDK Components” boxes are checked. Take  note of the download folder (or change to one of your choice) so that we can find the downloaded files later. Also be sure to check the “Download now. Install later.” box to let the software know we will not be flashing the device right now. You must also consult and accept the license terms for all the packages you intend to install and use in your Jetson Nano project by checking the “accept” box.

Go ahead and [clone this repository](https://github.com/balena-io-playground/opendatacam) on your computer. You’ll notice a file named “prepare.sh” which we’ll use to copy some of the files we downloaded to our local repository. Since the downloaded file names will change with each version, you’ll need to edit this shell file on the line that begins `L4Tv=` (around line 10) to match the version of the Jetson file. You’ll need to do similar renaming of the files in the next line in the shell script, changing any file names to match the names that are downloaded (only the version numbers towards the end of the filename should need editing.)

Once you have updated the file names in the prepare.sh script, execute it (in your local repository folder) by providing the name of the folder that contains the downloaded files, for example:

`./prepare.sh /home/alan/Downloads/nvidia/sdkm_downloads`

If the script completes successfully, it will return `Done copying necessary files. You may now build the docker file`. Otherwise, re-check your file naming and try again.

At this point, you can follow the typical balenaCloud pattern of creating an application, downloading an image, flashing an SD card, inserting it in your Jetson Nano, and then powering it up. Once your Nano is showing up in the dashboard, do a `balena push` from the CLI. The Dockerfile is huge and installs a lot of dependencies, so the build may take a while.

Once the build is complete and the image has downloaded to you nano, you can access OpenDataCam from your browser on port 80.

## Device Variables

You can set the following device variables in the balenaCloud dashboard to modify your OpenDataCam configuration:

**VIDEO_INPUT** - set to `usbcam` for an attached USB camera (default value) or `remote_cam` for an IP camera. If you set to `remote_cam` you need to also set the variable `CAM_IP`.

**CAM_IP** - enter the entire IP/URL of a video stream, for instance `rtsp://192.168.1.168/0`- can be anything supported by OpenCV, such as .m3u8, MJPEG, etc...

**CAM_DEV** - sets the device name for the USB camera to use if `VIDEO_INPUT` is set to `usbcam` - default value is `video0`, in other words the camera device would be `/dev/video0` - you should not enter the `/dev/` part which is assumed.


