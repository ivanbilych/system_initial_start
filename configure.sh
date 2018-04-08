#!/bin/bash

#-- Script config --#

SECONDS=0
LINES=$(tput lines)
COLUMNS=$(tput cols)

# Attributes
attr_normal="0"
attr_bold="1"
attr_dim="2"
attr_underline="4"
attr_blink="5"
attr_reversed="7"
attr_hidden="8"

# Text color
text_black="30"
text_blue="34"
text_cyan="36"
text_green="32"
text_purple="35"
text_red="31"
text_white="37"
text_yellow="33"

# Background color
back_black="40"
back_blue="44"
back_cyan="46"
back_green="42"
back_purple="45"
back_red="41"
back_white="47"
back_yellow="43"

clear_color="00"

style() {
    if [ -z ${2} ]; then
        echo "\e[${1}m"
    else
        echo "\e[${2};${1}m"
    fi
}

color_normal="$(style ${clear_color})"
color_green="$(style ${text_green})"
color_green_b="$(style ${text_green} ${attr_bold})"
color_red="$(style ${text_red})"
color_red_b="$(style ${text_red} ${attr_bold})"
color_yellow="$(style ${text_yellow})"
color_purple="$(style ${text_purple})"

print_title() {
    echo -e "\n${color_purple}### ${1} ###${color_normal}\n"
}

print_warn() {
    echo -e "${color_yellow}### Warning: ${1} ###${color_normal}"
}

print_done() {
    duration=$SECONDS
    SECONDS=0

    echo -e "\n${color_green}### Done: ${1} [$(($duration/60)) min $(($duration%60)) sec] ###${color_normal}"
}

print_fail() {
    duration=$SECONDS
    SECONDS=0

    echo -e "\n${color_red}### Fail: ${1} [$(($duration/60)) min $(($duration%60)) sec] ###${color_normal}"

    exit 1
}

task_ok() {
    local shift_num=$(( ${COLUMNS}-${#1}%${COLUMNS}-2 ))

    printf "${1}${color_green_b}%${shift_num}s${color_normal}\n" "[OK]"
}

task_fail() {
    local shift_num=$(( ${COLUMNS}-${#1}%${COLUMNS}-2 ))

    printf "${1}${color_red_b}%${shift_num}s${color_normal}\n" "[FAIL]"
}

redirect() {
    if [ "${debug}" != "true" ]; then
        "$@" > /dev/null 2>&1
    else
        echo "> $@"
        "$@"
    fi
}

#-- System configuration --#

print_title "System configuration"

# Bashrc file configuration

target_file="/home/${USER}/.bashrc"
HISTSIZE=100000
HISTFILESIZE=200000
force_color_prompt=yes

message="set HISTSIZE=${HISTSIZE} in ${target_file}"
redirect sed -i 's|^\(HISTSIZE=\).*|\1'${HISTSIZE}'|' ${target_file} \
&& task_ok "${message}" \
|| task_fail "${message}"

message="set HISTFILESIZE=${HISTFILESIZE} in ${target_file}"
redirect sed -i 's|^\(HISTFILESIZE=\).*|\1'${HISTFILESIZE}'|' ${target_file} \
&& task_ok "${message}" \
|| task_fail "${message}"

message="set force_color_prompt=${force_color_prompt} in ${target_file}"
redirect sed -i 's|^\(force_color_prompt=\).*|\1'${force_color_prompt}'|' ${target_file} \
&& redirect sed -i '/force_color_prompt=/s/^# //g' ${target_file} \
&& task_ok "${message}" \
|| task_fail "${message}"

pattern="https://github.com/ivanbilych/system_initial_start"
message="append bashrc file with custom parameters in ${target_file}"
redirect grep "${pattern}" ${target_file}
if [ "$?" != "0" ]; then
    cat bashrc_append.txt >> ${target_file} \
    && task_ok "${message}" \
    || task_fail "${message}"
else
    print_warn "bashrc file was already appended"
fi

# Setup correct time locale

message="setup currect time locale"
redirect timedatectl set-local-rtc 1 --adjust-system-clock \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "System configuration"

#-- Packages installation --#

print_title "Packages installation"

ppa_01="ppa:danielrichter2007/grub-customizer"
message="add custom repository: ${ppa_01}"
redirect sudo add-apt-repository ${ppa_01} -y \
&& task_ok "${message}" \
|| task_fail "${message}"

ppa_02="ppa:webupd8team/sublime-text-3"
message="add custom repository: ${ppa_02}"
redirect sudo add-apt-repository ${ppa_02} -y \
&& task_ok "${message}" \
|| task_fail "${message}"

# Update repositories
message="update list of available packages"
redirect sudo apt update \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install software
software_list="
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
sublime-text \
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
"

print_warn "Installing software. This can take some time"

message="ubuntu deb packages installation"
redirect sudo apt install ${software_list} -y \
&& task_ok "${message}" \
|| { task_fail "${message}"; print_fail "Packages install error"; }

# Install glances
message="install glances tool"
wget -q -O- http://bit.ly/glances | redirect /bin/bash \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "Packages installation"

#-- Packages configuration --#

print_title "Packages configuration"

# git configuration
email="ivanbilych@gmail.com"
name="Ivan Bilych"
message="git configuration"
git config --global user.email ${email} && \
git config --global user.name ${name} \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "Packages configuration"