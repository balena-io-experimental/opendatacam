FROM balenalib/jetson-nano-ubuntu:bionic

WORKDIR /usr/src/app

# Rename the four files below to match the ones you downloaded from the SDK (if they are different)
COPY ./cuda-repo-l4t-10-0-local-10.0.326_1.0-1_arm64.deb .
COPY ./libcudnn7_7.6.3.28-1+cuda10.0_arm64.deb .
COPY ./libcudnn7-dev_7.6.3.28-1+cuda10.0_arm64.deb .
COPY ./libcudnn7-doc_7.6.3.28-1+cuda10.0_arm64.deb .

ENV DEBIAN_FRONTEND noninteractive

## Install runtime & build libraries and build opencv
RUN \
    dpkg -i cuda-repo-l4t-10-0-local-10.0.326_1.0-1_arm64.deb && \
    apt-key add /var/cuda-repo-10-0-local-10.0.326/*.pub && \
    dpkg -i libcudnn7_7.6.3.28-1+cuda10.0_arm64.deb \
    libcudnn7-dev_7.6.3.28-1+cuda10.0_arm64.deb \
    libcudnn7-doc_7.6.3.28-1+cuda10.0_arm64.deb && \
    apt-get update && \
    apt-get install cuda-compiler-10-0 \
    cuda-samples-10-0 \
    lbzip2 xorg-dev \
    git wget unzip \
    cmake automake build-essential \
    autoconf libtool \
    libgtk2.0-dev pkg-config \
    libavcodec-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    ffmpeg \
    gstreamer1.0-plugins-good \
    libdc1394-22-dev -y --no-install-recommends && \
    rm -rf ./*.deb && \
    dpkg --remove cuda-repo-l4t-10-0-local-10.0.326 && \
    dpkg -P cuda-repo-l4t-10-0-local-10.0.326 && \
    echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf \
    && ldconfig && \
    wget https://github.com/opencv/opencv/archive/3.4.3.zip && \
    unzip 3.4.3.zip && rm 3.4.3.zip

RUN \
    wget https://github.com/opencv/opencv_contrib/archive/3.4.3.zip -O opencv_modules.3.4.3.zip && \
    unzip opencv_modules.3.4.3.zip && rm opencv_modules.3.4.3.zip && \
    mkdir -p opencv-3.4.3/build && cd opencv-3.4.3/build && \
    cmake -D WITH_CUDA=ON -D CUDA_ARCH_BIN="5.3"  -D BUILD_LIST=cudev,highgui,videoio,video,cudaimgproc,ximgproc -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.4.3/modules -D CMAKE_INSTALL_PREFIX=/usr/local CMAKE_BUILD_TYPE=Release -D WITH_GSTREAMER=ON -D WITH_GSTREAMER_0_10=OFF -D WITH_CUDA=OFF -D WITH_TBB=ON -D WITH_LIBV4L=ON WITH_FFMPEG=ON .. && make -j8 && make install && \
    cp /usr/src/app/opencv-3.4.3/build/bin/opencv_version /usr/src/app/ && \
    cd /usr/src/app/ && rm -rf /usr/src/app/opencv-3.4.3 && \
    rm -rf /usr/src/app/opencv_contrib-3.4.3

# set paths
ENV CUDA_HOME=/usr/local/cuda-10.0/
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV UDEV=1

# Some CUDA libraries are very large and not
# all examples need them. Free up some more space
RUN rm -rf /usr/local/cuda-10.0/doc
    
COPY ./nvidia_drivers.tbz2 .
COPY ./config.tbz2 .

ENV DEBIAN_FRONTEND noninteractive

# Prepare minimum of runtime libraries
RUN apt-get update && apt-get install -y lbzip2 pkg-config && \
    tar xjf nvidia_drivers.tbz2 -C / && \
    tar xjf config.tbz2 -C / --exclude=etc/hosts --exclude=etc/hostname && \
    echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && ldconfig && \
    rm -rf *.tbz2

# Start Darknet Install

# working directory
WORKDIR /darknet

# build repo
RUN git clone --depth 1 -b opendatacam https://github.com/opendatacam/darknet

WORKDIR darknet/
COPY ./Makefile ./

RUN     make

#get weights
RUN wget https://pjreddie.com/media/files/yolov3-tiny.weights >/dev/null 2>&1

# Since we are building for Jetson Nano, we won't copy over these weights to save space.
# If you are on a more powerful device, add them back in	
#wget https://pjreddie.com/media/files/yolo-voc.weights >/dev/null 2>&1 && \
#wget https://pjreddie.com/media/files/yolov3.weights >/dev/null 2>&1

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

RUN git clone --depth 1 -b v2.1.0 https://github.com/opendatacam/opendatacam /opendatacam

WORKDIR /opendatacam

RUN npm install
RUN npm run build

# Install Mongodb
# NB: for some reason this needs to be at the end otherwise mongod command isn't installed
# https://github.com/dockerfile/mongodb#run-mongod-w-persistentshared-directory
# ENV DEBIAN_FRONTEND noninteractive
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-get update && apt-get install -y openssl libcurl3 mongodb-org
VOLUME ["/data/db"]

EXPOSE 8080 8070 8090 27017

COPY config.json .

# # Because we want to run mongodb and the node.js app
# # See https://docs.docker.com/config/containers/multi-service_container/
COPY docker-start-mongo-and-opendatacam.sh docker-start-mongo-and-opendatacam.sh
RUN chmod 777 docker-start-mongo-and-opendatacam.sh
CMD ["./docker-start-mongo-and-opendatacam.sh"]
