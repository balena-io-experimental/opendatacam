# AGX Orin, Orin NX and Orin Nano use the same T234 platform, therefore base images can be used
# interchangeably as long as nvidia.list contains the right apt repositoy
FROM ubuntu:jammy-20250404

WORKDIR /usr/src/app

# Install extras for base image 
RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo \
  ca-certificates \
  findutils \
  gnupg \
  dirmngr \
  inetutils-ping \
  netbase \
  curl \
  udev \
  kmod \
  nano
  
# Prevent apt-get prompting for input
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb https://repo.download.nvidia.com/jetson/common r36.4 main" >  /etc/apt/sources.list.d/nvidia.list \
       && echo "deb https://repo.download.nvidia.com/jetson/t234 r36.4 main" >>  /etc/apt/sources.list.d/nvidia.list \
       && apt-key adv --fetch-key http://repo.download.nvidia.com/jetson/jetson-ota-public.asc \
       && mkdir -p /opt/nvidia/l4t-packages/ && touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

# Download and install BSP binaries for L4T 36.4.3 - Jetpack 6.2
RUN \
    apt-get update && apt-get install -y wget tar lbzip2 binutils xz-utils zstd qemu-user-static cpio git && \
    cd /tmp/ && wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.3/release/Jetson_Linux_r36.4.3_aarch64.tbz2 && \
    tar xf Jetson_Linux_r36.4.3_aarch64.tbz2 && \
    cd Linux_for_Tegra && \
    mkdir -p /tmp/Linux_for_Tegra/rootfs/boot/ && \
    mkdir -p /tmp/Linux_for_Tegra/rootfs/usr/bin && \
    mkdir -p /tmp/Linux_for_Tegra/rootfs/etc && touch /tmp/Linux_for_Tegra/rootfs/etc/resolv.conf && \
    sed -i 's/config.tbz2\"/config.tbz2\" --exclude=etc\/hosts --exclude=etc\/hostname/g' apply_binaries.sh && \
    sed -i 's/CheckPackage qemu-user-static/#CheckPackage qemu-user-static/g' tools/l4t_update_initrd.sh && \
    sed -i 's/trap CleanupVirEnv/#trap CleanupVirEnv/g' tools/l4t_update_initrd.sh&& \
    sed -i 's|cp /usr/bin/qemu-aarch64-static|#cp /usr/bin/qemu-aarch64-static|g' tools/l4t_update_initrd.sh && \
    sed -i 's|^UpdateInitrd|#UpdateInitrd|g' tools/l4t_update_initrd.sh && \
    sed -i 's|^UpdateBackToBaseInitrd|#UpdateBackToBaseInitrd|g' tools/l4t_update_initrd.sh && \
    sed -i 's|cp /etc/resolv.conf|#cp /etc/resolv.conf|g' tools/l4t_update_initrd.sh && \
    sed -i 's|mv "${LDK_ROOTFS_DIR}/etc/resolv.conf"|cp "${LDK_ROOTFS_DIR}/etc/resolv.conf"|g' tools/l4t_update_initrd.sh && \
    sed -i 's|	PrepareVirEnv|#PrepareVirEnv|g' tools/l4t_update_initrd.sh && \
    sed -i 's/install --owner=root --group=root \"${QEMU_BIN}\" \"${L4T_ROOTFS_DIR}\/usr\/bin\/\"/#install --owner=root --group=root \"${QEMU_BIN}\" \"${L4T_ROOTFS_DIR}\/usr\/bin\/\"/g' nv_tegra/nv-apply-debs.sh && \
    sed -i 's/chroot . \//  /g' nv_tegra/nv-apply-debs.sh && \
    cd /tmp/Linux_for_Tegra/ && ./apply_binaries.sh -r / --target-overlay && cd .. && \
    rm -rf Linux_for_Tegra && \
    echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && ldconfig


ENV LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/tegra

# Install CUDA and confirmation utility
RUN apt-get update && apt-get install -y -o Dpkg::Options::="--force-confdef" nvidia-l4t-cuda nvidia-cuda build-essential cuda-nvcc-12-6 && git clone https://github.com/NVIDIA/cuda-samples.git && cd cuda-samples && git checkout 7ce058b4796783b3b7ca8196c25d5f5b9c380ec4 && cd Samples/1_Utilities/deviceQuery && make 

# Install some more requirements
RUN apt-get update && apt-get install -y  \
    nvidia-cuda-dev cudnn9-cuda-12-6 libcudnn9-dev-cuda-12 \
    unzip jq \
    cmake \
    libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev \
    libwebp-dev libtbb2 libtbb-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-good \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-dev -y --no-install-recommends
    

# Download and install OpenCV 4.8.1    
RUN \
    wget https://github.com/opencv/opencv_contrib/archive/4.8.1.zip -O opencv_modules.4.8.1.zip && \
    unzip opencv_modules.4.8.1.zip && rm opencv_modules.4.8.1.zip && \
    wget https://github.com/opencv/opencv/archive/4.8.1.zip -O opencv.4.8.1.zip && \
    unzip opencv.4.8.1.zip && rm opencv.4.8.1.zip && \
    mkdir -p opencv-4.8.1/build && cd opencv-4.8.1/build && \
    cmake -D WITH_CUDA=ON -D WITH_CUDNN=ON -D CUDA_ARCH_BIN="8.7"  -D BUILD_LIST=cudev,highgui,videoio,cudaimgproc,ximgproc -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.8.1/modules -D CUDA_ARCH_PTX="" -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_TESTS=ON -D BUILD_PERF_TESTS=ON -D BUILD_SAMPLES=ON -D BUILD_EXAMPLES=ON -D CMAKE_BUILD_TYPE=RELEASE -D WITH_GTK=on -D BUILD_DOCS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_GENERATE_PKGCONFIG=YES .. && make -j32 && make install && \
    rm -rf /usr/src/app/opencv_contrib-4.8.1


WORKDIR /

# Download and build Darknet
RUN \
  git clone https://github.com/AlexeyAB/darknet.git

WORKDIR /darknet

COPY ./Makefile ./Makefile

RUN make && ldconfig

# get weights and cfg for yolov4/yolov4-tiny
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights --no-check-certificate > /dev/null 2>&1 && \
    wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights --no-check-certificate > /dev/null 2>&1
    
COPY ./yolov4-416x416.cfg /darknet/cfg/yolov4-416x416.cfg

# Install node.js
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y curl \
    && curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install --no-install-recommends --no-install-suggests -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install OpenDataCam
RUN \
  git clone --depth 1 https://github.com/opendatacam/opendatacam.git  /var/local/opendatacam

WORKDIR /var/local/opendatacam

RUN \
  npm install && \
  npm run build

EXPOSE 8080 8070 8090

COPY entry.sh .
COPY launch.sh .
RUN chmod +x /var/local/opendatacam/launch.sh
COPY config.json .
RUN cp /var/local/opendatacam/config.json /var/local/opendatacam/config.bak

CMD ["/bin/bash", "/var/local/opendatacam/entry.sh"]
