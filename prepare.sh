#/bin/sh

if [ -z $1 ]; then
    echo "Please specify path to NVIdia SDK downloads directory"
    echo "eg: ./prepare.sh ~/Downloads/nvidia/sdkm_downloads/"

    exit 1
fi;

L4Tv="32.3.1"
FILE_LIST="cuda-repo-l4t-10-0-local-10.0.326_1.0-1_arm64.deb libcudnn7_7.6.3.28-1+cuda10.0_arm64.deb libcudnn7-dev_7.6.3.28-1+cuda10.0_arm64.deb libcudnn7-doc_7.6.3.28-1+cuda10.0_arm64.deb Jetson-210_Linux_R${L4Tv}_aarch64.tbz2"
DLPATH=$1

if [ ! -f "$DLPATH/Jetson-210_Linux_R${L4Tv}_aarch64.tbz2" ]; then
    echo "L4T files do not exist in specified folder! Exiting..."
fi;

if [ -d ./tmp/ ]; then
    rm -rf ./tmp/
fi

mkdir ./tmp/

for FILE in $FILE_LIST
do
    cp "${DLPATH}/${FILE}" ./tmp/
done

tar xjf ./tmp/Jetson-210_Linux_R${L4Tv}_aarch64.tbz2 -C ./tmp/
cp ./tmp/Linux_for_Tegra/nv_tegra/config.tbz2 ./tmp/
cp ./tmp/Linux_for_Tegra/nv_tegra/nvidia_drivers.tbz2 ./tmp/
rm -rf ./tmp/Linux_for_Tegra
rm ./tmp/Jetson-210_Linux_R${L4Tv}_aarch64.tbz2
mv ./tmp/* . && rm -rf ./tmp

echo "********************************************************************"
echo "* Done copying necessary files. You may now build the docker file. *"
echo "********************************************************************"
