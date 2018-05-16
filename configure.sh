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
color_blue="$(style ${text_blue})"

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

# Setup bashrc for root user
message="setup .bashrc for root user"
redirect sudo cp ${target_file} /root \
&& task_ok "${message}" \
|| task_fail "${message}"

# Setup conkyrc file
message="setup .conkyrc file"
redirect cp conkyrc.txt /home/${USER}/.conkyrc \
&& task_ok "${message}" \
|| task_fail "${message}"

# Setup correct time locale
message="setup currect time locale"
redirect timedatectl set-local-rtc 1 --adjust-system-clock \
&& task_ok "${message}" \
|| task_fail "${message}"

# Activate 'minimaze on click' option
message="minimaze on click option"
redirect gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "System configuration"

#-- Packages installation --#

print_title "Packages installation"

# Setup additional ppa
ppa_01="ppa:danielrichter2007/grub-customizer"
message="add custom repository: ${ppa_01}"
redirect sudo add-apt-repository "${ppa_01}" -y \
&& task_ok "${message}" \
|| task_fail "${message}"

ppa_02="deb https://download.sublimetext.com/ apt/stable/"
message="add custom repository: ${ppa_02}"
wget -q -O - https://download.sublimetext.com/sublimehq-pub.gpg | redirect sudo apt-key add - \
&& redirect sudo add-apt-repository "${ppa_02}" --yes \
&& task_ok "${message}" \
|| task_fail "${message}"

ppa_03="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
message="add custom repository: ${ppa_03}"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | redirect sudo apt-key add - \
&& echo "${ppa_03}" | redirect sudo tee /etc/apt/sources.list.d/google-chrome.list \
&& task_ok "${message}" \
|| task_fail "${message}"

ppa_04="ppa:otto-kesselgulasch/gimp"
message="add custom repository: ${ppa_04}"
redirect sudo add-apt-repository "${ppa_04}" -y \
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
chrome-gnome-shell \
clang \
cmake \
conky-all \
cu \
curl \
debootstrap \
doxygen \
exfat-fuse \
exfat-utils \
fonts-font-awesome \
filezilla \
flex \
g++-multilib \
gcc-multilib \
gconf-service \
gconf-service-backend \
gconf2-common \
gimp \
git \
gitk \
gnome-disk-utility \
gnome-shell-extensions \
gnome-tweak-tool \
gnupg \
google-chrome-stable \
gparted \
gperf \
grub-customizer \
gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-ugly \
gthumb \
gufw \
htop \
iptraf \
kazam \
keepass2 \
libcanberra-gtk-module:i386 \
libdvd-pkg \
libdvdnav4 \
libdvdread4 \
libgconf-2-4 \
mc \
meld \
memtest86+ \
minicom \
nautilus-dropbox \
net-tools \
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
qt5-qmake \
rar \
remmina \
repo \
sane-utils \
schroot \
sl \
ssh \
sublime-text \
texlive-extra-utils \
ubuntu-restricted-extras \
unrar \
vim \
vino \
virtualbox \
virtualbox-guest-additions-iso \
virtualbox-guest-x11 \
vlc \
wine-stable \
x11proto-core-dev \
xclip \
xrdp \
xterm \
zip \
zlib1g-dev \
"

print_warn "Installing software. This can take some time"

message="ubuntu deb packages installation"
sudo apt install ${software_list} -y \
&& task_ok "${message}" \
|| { task_fail "${message}"; print_fail "Packages install error"; }

# Upgrade distro packages
message="ubuntu distro update"
sudo apt dist-upgrade -y \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install glances
message="install glances tool"
wget -q -O- http://bit.ly/glances | redirect /bin/bash \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install repo tool
message="install repo tool"
redirect mkdir -p ~/.bin \
&& curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo \
&& redirect chmod a+x ~/.bin/repo \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install telegram
message="install telegram app"
redirect sudo snap install telegram-desktop \
&& redirect sudo snap install telegram-cli \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install skype
tmp_dir="$(mktemp -d)"
app="skypeforlinux-64.deb"
message="install skype app"
redirect mkdir -p ~/.bin \
&& wget -q -O ${tmp_dir}/${app} https://go.skype.com/skypeforlinux-64.deb \
&& redirect sudo dpkg -i ${tmp_dir}/${app} \
&& redirect sudo apt install -f \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install QT5 packages
software_list="
libqt5bluetooth5 \
libqt5concurrent5 \
libqt5contacts5 \
libqt5core5a \
libqt5dbus5 \
libqt5designer5 \
libqt5designercomponents5 \
libqt5gui5 \
libqt5help5 \
libqt5location5 \
libqt5multimedia5 \
libqt5network5 \
libqt5nfc5 \
libqt5opengl5 \
libqt5opengl5-dev \
libqt5organizer5 \
libqt5positioning5 \
libqt5printsupport5 \
libqt5qml5 \
libqt5quick5 \
libqt5quickparticles5 \
libqt5quicktest5 \
libqt5quickwidgets5 \
libqt5script5 \
libqt5scripttools5 \
libqt5sensors5 \
libqt5sensors5-dev \
libqt5serialport5 \
libqt5serialport5-dev \
libqt5sql5 \
libqt5svg5 \
libqt5svg5-dev \
libqt5test5 \
libqt5webkit5 \
libqt5webkit5-dev \
libqt5websockets5 \
libqt5websockets5-dev \
libqt5widgets5 \
libqt5x11extras5 \
libqt5x11extras5-dev \
libqt5xml5 \
libqt5xmlpatterns5 \
libqt5xmlpatterns5-dev \
qtbase5-dev \
qtconnectivity5-dev \
qtdeclarative5-dev \
qtmultimedia5-dev \
qtpositioning5-dev \
qtscript5-dev \
qttools5-dev \
"

print_warn "Installing software. This can take some time"

message="QT5 deb packages installation"
sudo apt install ${software_list} -y \
&& task_ok "${message}" \
|| { task_fail "${message}"; print_fail "Packages install error"; }

# Install QT Creator
tmp_dir="$(mktemp -d)"
app="qt-opensource-linux-x64.run"
message="install QT Creator"
print_warn "Installing QT Creator. This can take some time. User input actions required"
{
    is_done="false"

    for major in {6..0}; do
        for minor in {12..0}; do
            for release in {5..0}; do
                wget -q -O ${tmp_dir}/${app} http://download.qt.io/official_releases/qt/${major}.${minor}/${major}.${minor}.${release}/qt-opensource-linux-x64-${major}.${minor}.${release}.run

                if [ "$?" == "0" ]; then
                    is_done="true"
                    break
                fi
            done

            if [ ${is_done} == "true" ]; then
                break
            fi
        done

        if [ ${is_done} == "true" ]; then
            break
        fi
    done
} \
&& redirect chmod +x ${tmp_dir}/${app} \
&& redirect ${tmp_dir}/${app} \
&& task_ok "${message} version ${major}.${minor}.${release}" \
|| task_fail "${message} version ${major}.${minor}.${release}"

# Install dropbox
tmp_dir="$(mktemp -d)"
app="dropbox.tar.gz"
message="install dropbox app"
redirect mkdir -p ~/.bin \
&& wget -q -O ${tmp_dir}/${app} https://www.dropbox.com/download?plat=lnx.x86_64 \
&& redirect tar xzf ${tmp_dir}/${app} -C ${tmp_dir} \
&& redirect cp -rf ${tmp_dir}/.dropbox-dist/* ~/.bin \
&& task_ok "${message}" \
|| task_fail "${message}"

# Install additional drivers
message="Install additional drivers"
sudo ubuntu-drivers autoinstall \
&& task_ok "${message}" \
|| task_fail "${message}"

# Remove unused packages
message="remove unused packages"
redirect sudo apt autoremove -y \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "Packages installation"

#-- Packages configuration --#

print_title "Packages configuration"

# git configuration
echo -en "${color_blue}please enter user name:${color_normal} "
read name
echo -en "${color_blue}please enter user email:${color_normal} "
read email
message="git configuration"
git config --global user.email "${email}" \
&& git config --global user.name "${name}" \
&& task_ok "${message}" \
|| task_fail "${message}"

# sublime-text-3 configuration
message="sublime-text-3 configuration"
rm -rf /home/${USER}/.config/sublime-text-3/Packages/User \
&& mkdir -p /home/${USER}/Dropbox/Backup/sublime-text-3/User \
&& mkdir -p /home/${USER}/.config/sublime-text-3/Packages \
&& ln -s /home/${USER}/Dropbox/Backup/sublime-text-3/User /home/${USER}/.config/sublime-text-3/Packages/User \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "Packages configuration"

#-- Packages uninstall --#

print_title "Packages uninstall"

# Uninstall software
software_list="
ubuntu-web-launchers \
"

message="ubuntu deb packages uninstall"
redirect sudo apt purge ${software_list} -y \
&& task_ok "${message}" \
|| task_fail "${message}"

print_done "Packages uninstall"
