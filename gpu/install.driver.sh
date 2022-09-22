#https://github.com/NVIDIA/apt-packaging-fabric-manager#Building-Manually
#https://docs.nvidia.com/datacenter/tesla/pdf/fabric-manager-user-guide.pdf
# Check /usr/share/nvidia/nvswitch/fabricmanager.cfg

nvdiainfo=`modinfo -F version nvidia`
IFS='. ' read -r -a array <<< "${nvdiainfo}"
echo "${array[0]}"

sudo apt-get install cuda-drivers-fabricmanager-${array[0]}

sudo systemctl --now enable nvidia-fabricmanager