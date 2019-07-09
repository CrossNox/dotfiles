sudo dnf install -y kernel-devel
mkdir ~/cudnn
cd ~/cudnn
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/430.26/NVIDIA-Linux-x86_64-430.26.run
chmod +x ./NVIDIA-Linux-x86_64-430.26.run
sudo ./NVIDIA-Linux-x86_64-430.26.run
