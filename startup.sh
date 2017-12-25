#!/bin/bash

# -------------------- #
# System configuration #
# -------------------- #

echo -e "> System configuration START"

# Install custom bash_rc file
cp -b bashrc.txt ~/.bashrc \
&& echo -e ">> bashrc edit OK" \
|| echo -e ">> bashrc edit FAIL"

# Set correct timing zone
timedatectl set-local-rtc 1 --adjust-system-clock \
&& echo -e ">> setting correct timing zone OK" \
|| echo -e ">> setting correct timing zone FAIL"

echo -e "> System configuration DONE"

# --------------------- #
# Packages installation #
# --------------------- #

echo -e "> Packages installation START"

# Add custom ppa
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y \
&& echo -e ">> add custom ppa OK" \
|| echo -e ">> add custom ppa FAIL"

# Update repositories
sudo apt update \
&& echo -e ">> packages update OK" \
|| echo -e ">> packages update FAIL"

# Install software
sudo apt install \
android-tools-adb \
android-tools-fastboot \
build-essential \
ccache \
clang \
cmake \
cu \
curl \
debootstrap \
doxygen \
exfat-fuse \
exfat-utils \
flex \
g++-multilib \
gcc-multilib \
gimp \
git \
gitk \
gnome-disk-utility \
gnupg \
gparted \
gperf \
grub-customizer \
gthumb \
htop \
iptraf \
keepass2 \
mc \
meld \
memtest86+ \
minicom \
network-manager-openconnect \
network-manager-openconnect-gnome \
network-manager-openvpn \
network-manager-openvpn-gnome \
openconnect \
pcregrep \
poppler-utils \
python-pip \
python3-pip \
qbittorrent \
rar \
remmina \
repo \
sane-utils \
schroot \
sl \
ssh \
unrar \
vim \
vino \
vlc \
wine-stable \
x11proto-core-dev \
xclip \
xrdp \
zip \
zlib1g-dev \
-y \
&& echo -e ">> packages installation OK" \
|| echo -e ">> packages installation FAIL"

# Install glances
wget -O- http://bit.ly/glances | /bin/bash \
&& echo -e ">> glances installation OK" \
|| echo -e ">> glances installation FAIL"

echo -e "> Packages installation DONE"

# ---------------------- #
# Packages configuration #
# ---------------------- #

echo -e "> Packages configuration START"

# git configuration
git config --global user.email "ivanbilych@gmail.com" && \
git config --global user.name "Ivan Bilych" \
&& echo -e ">> git configuration OK" \
|| echo -e ">> git configuration FAIL"

echo -e "> Packages configuration DONE"

