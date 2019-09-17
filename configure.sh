#!/bin/bash

print_help() {
    echo -e "${YELLOW}NAME${NONE}

    ${0} - Ubuntu system configure/install script.

${YELLOW}USAGE${NONE}

    configure.sh [-h, --help]

${YELLOW}DESCRIPTION${NONE}

    -v, --verbose
        Verbose mode. Print all command output. Useful for debug;

    -h, --help
        Print this help message.
"
}

ctrl_c() {
    echo ""
    warn "Script work was canceled with CTRL+C"
    process_fail
}

parse_command_line() {
    local long_opts="verbose,help"
    local getopt_cmd=$(getopt -o vh --long "${long_opts}" -n $(basename ${0}) -- "$@") || \
        { err "Getopt failed. Extra args"; print_help; exit 1; }

    eval set -- "${getopt_cmd}"

    while true; do
        case "${1}" in
            -v|--verbose) VERBOSE="true";;
            -h|--help) print_help; exit 0;;
            --) shift; break;;
        esac
        shift
    done
}

configure_system() {
    title "System configuration"

    # Bashrc file configuration
    bashrc_file="/home/${USER}/.bashrc"
    HISTSIZE=100000
    HISTFILESIZE=200000

    redirect 'sed -i "s|^\(HISTSIZE=\).*|\1${HISTSIZE}|" ${bashrc_file}'
    test_task "Set HISTSIZE=${HISTSIZE} in ${bashrc_file}"

    redirect 'sed -i "s|^\(HISTFILESIZE=\).*|\1${HISTFILESIZE}|" ${bashrc_file}'
    test_task "set HISTFILESIZE=${HISTFILESIZE} in ${bashrc_file}"

    redirect 'sed -i "/^#.*force_color_prompt=/s/^#//" ${bashrc_file}' \
    && redirect 'sed -i "s|^\(force_color_prompt=\).*|\1yes|" ${bashrc_file}'
    test_task "set force_color_prompt=${force_color_prompt} in ${bashrc_file}"

    redirect 'grep "This confogurations was inserted by script" ${bashrc_file}'
    if [ "$?" != "0" ]; then
        echo "" >> {bashrc_file} \
        && cat bashrc_append.txt >> ${bashrc_file}
        test_task "append bashrc file with custom parameters"
    fi

    # Setup bashrc for root user
    warn "sudo user access required"
    redirect sudo cp ${bashrc_file} /root
    test_task "setup .bashrc for root user"

    # Setup correct time locale
    redirect timedatectl set-local-rtc 1 --adjust-system-clock
    test_task "setup currect time locale"

    # Activate 'minimaze on click' option
    redirect gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    test_task "minimaze on click option"
}

install_packages() {
    title "Packages installation"

    # Setup additional ppa


    # Update repositories
    redirect sudo apt update
    test_task "update list of available packages"

    # Install software
    software_list="
    android-tools-adb \
    android-tools-fastboot \
    build-essential \
    ccache \
    chrome-gnome-shell \
    chromium-browser \
    clang \
    cmake \
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
    gparted \
    gperf \
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
    qbittorrent \
    qt5-qmake \
    rar \
    remmina \
    repo \
    sane-utils \
    schroot \
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
    xdotool \
    xrdp \
    xterm \
    zip \
    zlib1g-dev \
    "

    info "Installing software. This can take some time."
    redirect sudo apt install ${software_list} -y
    test_task "ubuntu deb packages installation"

    # Upgrade distro packages
    redirect sudo apt dist-upgrade -y
    test_task "ubuntu distro update"

    # Install repo tool
    redirect mkdir -p ~/.bin \
    && curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo \
    && redirect chmod a+x ~/.bin/repo
    test_task "install repo tool"

    # Install additional drivers
    redirect sudo ubuntu-drivers autoinstall
    test_task "Install additional drivers"

    # Remove unused packages
    redirect sudo apt autoremove -y
    test_task "remove unused packages"
}

configure_packages() {
    title "Packages configuration"

    # git configuration
    info "git configuration"
    echo -en "please enter user name: "
    read name
    echo -en "please enter user email: "
    read email

    git config --global user.email "${email}" \
    && git config --global user.name "${name}"
    test_task "git configuration"
}

uninstall_packages() {
    title "Packages uninstall"

    # Uninstall software
    software_list="
    ubuntu-web-launchers \
    "

    redirect sudo apt purge ${software_list} -y
    test_task "ubuntu deb packages uninstall"
}

configuration_steps() {
    configure_system || return 1
    install_packages || return 1
    configure_packages || return 1
    uninstall_packages || return 1
}

main() {
    trap ctrl_c INT

    parse_command_line "${@}"

    configuration_steps

    return ${?}
}

#
# Script helpers
#

C_NONE="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[34m"
C_PURPLE="\e[35m"
C_CYAN="\e[36m"
C_CYAN_U="\e[36;4m"

print() {
    echo -e "${@}"
}

log() {
    local timestamp="$(date '+%H:%M:%S.%3N')"
    local topic=$(printf "${1}%7s${C_NONE}" "${2}")

    shift 2

    echo -e "${timestamp}" "${topic}" "${@}"
}

info() {
    log "${C_NONE}" "info" "${@}"
}

warn() {
    log "${C_YELLOW}" "warning" "${C_YELLOW}${@}${C_NONE}"
}

err() {
    log "${C_RED}" "error" "${C_RED}${@}${C_NONE}"
}

ok() {
    log "${C_GREEN}" "ok" "${@}"
}

cmd() {
    log "${C_CYAN}" "command" "${@}"
}

title() {
    log "${C_NONE}" "" "${C_PURPLE}${@}${C_NONE}"
}

get_finish_time() {
    date -ud @${SECONDS} +%H:%M:%S
}

process_fail() {
    log "${C_NONE}" "" "${C_RED}Process FAILED. Duration $(get_finish_time) (hh:mm:ss)${C_NONE}"

    exit 1
}

process_success() {
    log "${C_NONE}" "" "${C_GREEN}Process SUCCEEDED. Duration $(get_finish_time) (hh:mm:ss)${C_NONE}"

    exit 0
}

redirect() {
    if [[ "${VERBOSE}" ]]; then
        cmd "${@}"
        eval "${@} 2>&1"
    else
        eval "${@} 2>&1" > /dev/null 2>&1
    fi
}

test_task() {
    local status="${?}"
    local task_description="${1}"

    if [[ ${status} == 0 ]]; then
        ok "${task_description}"
    else
        err "${task_description}"
    fi

    return ${status}
}

main "${@}" && process_success || process_fail
