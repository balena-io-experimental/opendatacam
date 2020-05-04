FROM resinplayground/jetson-nano-cuda-cudnn-opencv:v0.1

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y git wget

# Start Darknet Install

# working directory
WORKDIR /darknet

# build repo
RUN git clone --depth 1 -b opendatacam https://github.com/opendatacam/darknet

WORKDIR darknet/
COPY ./Makefile ./

RUN     make

#get weights
RUN wget https://pjreddie.com/media/files/yolov3-tiny.weights > /dev/null 2>&1

# Since we are building for Jetson Nano, we won't copy over these weights to save space.
# If you are on a more powerful device, add them back in	
#wget https://pjreddie.com/media/files/yolo-voc.weights > /dev/null 2>&1 && \
#wget https://pjreddie.com/media/files/yolov3.weights > /dev/null 2>&1

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

RUN git clone --depth 1 -b v2.1.0 https://github.com/opendatacam/opendatacam /opendatacam

WORKDIR /opendatacam

RUN npm install
RUN npm run build

EXPOSE 8080 8070 8090

COPY config.json .

COPY launch.sh launch.sh
RUN chmod 777 launch.sh
CMD ["./launch.sh"]
