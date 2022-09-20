wget https://nodejs.org/dist/v12.13.0/node-v12.13.0-linux-arm64.tar.xz
tar -xJf node-v12.13.0-linux-arm64.tar.xz
cd node-v12.13.0-linux-arm64
sudo cp -R * /usr/local/
cd ..
sudo apt update
sudo apt install -y gcc g++ make build-essential pkg-config libglib2.0-dev libexpat1-dev sox v4l-utils libjpeg-turbo8-dev
wget https://github.com/libvips/libvips/releases/download/v8.12.1/vips-8.12.1.tar.gz
tar xf vips-8.12.1.tar.gz
cd vips-8.12.1
./configure
make -j
sudo make install
sudo ldconfig
sudo npm install edge-impulse-cli -g --unsafe-perm=true
sudo npm install edge-impulse-linux -g --unsafe-perm=true
