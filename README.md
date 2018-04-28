# Info
System setup routine after clean system install. Was tested on **Ubuntu 18.04**

# Instructions
Just run the script:
```
./configure.sh
```
use `debug=true` prefix in case debug output required

# Script actions
* System configuration
    * set HISTSIZE=100000 in /home/${USER}/.bashrc
    * set HISTFILESIZE=200000 in /home/${USER}/.bashrc
    * set force_color_prompt=yes in /home/${USER}/.bashrc
    * append bashrc file with custom parameters in /home/${USER}/.bashrc
    * setup currect time locale
    * setup bashrc for root user
* Packages installation
    * add custom repository: ppa:danielrichter2007/grub-customizer
    * add custom repository: ppa:webupd8team/sublime-text-3
    * update list of available packages
    * ubuntu deb packages installation
    * install glances tool
    * install repo tool
    * install telegram
    * install skype
    * install QT Creator
* Packages configuration
    * git configuration
