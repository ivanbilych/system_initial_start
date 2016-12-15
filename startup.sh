#!/bin/bash

# -------------------- #
# System configuration #
# -------------------- #

# Remove guest session
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'

# Set correct timing zone
timedatectl set-local-rtc 1 --adjust-system-clock

# --------------------- #
# Packages installation #
# --------------------- #

# Add custom ppa
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo add-apt-repository ppa:webupd8team/java -y
sudo add-apt-repository ppa:openjdk-r/ppa -y

# Update repositories
sudo apt update

# Install software
sudo apt install \
android-tools-adb \
apcupsd \
bison \
build-essential \
ccache \
clang \
cmake \
cowsay \
cu \
curl \
debootstrap \
flex \
fortune \
funny-manpages \
g++-multilib \
gcc-4.8 \
gcc-4.8-multilib \
gcc-4.9 \
gcc-4.9-multilib \
gcc-multilib \
gimp \
git \
git-core \
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
lib32ncurses5-dev \
lib32z-dev \
lib32z1 \
libbz2-1.0:i386 \
libc6-dev-i386 \
libc6:i386 \
libgl1-mesa-dev \
libncurses5:i386 \
libreoffice \
libstdc++6:i386 \
libx11-dev \
libxml2-utils \
mc \
meld \
memtest86+ \
minicom \
network-manager-openconnect \
openconnect \
oracle-java6-installer \
oracle-java7-installer \
oracle-java8-installer \
oracle-java9-installer \
pcregrep \
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
unity-tweak-tool \
unrar \
vim \
vino \
vlc \
wine \
x11proto-core-dev \
xclip \
xcowsay \
xrdp \
zip \
zlib1g-dev \
-y

# Install glances
wget -O- http://bit.ly/glances | /bin/bash

# ---------------------- #
# Packages configuration #
# ---------------------- #

git config --global user.email "ivanbilych@gmail.com"
git config --global user.name "Ivan Bilych"
