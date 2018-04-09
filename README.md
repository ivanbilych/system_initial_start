# Info
System setup routine after clean system install. Was tested on **Ubuntu 17.10**

# Instructions
Just run the script:
```
./configure.sh
```

# Script actions
* System configuration
    * set HISTSIZE=100000 in /home/ivan/.bashrc
    * set HISTFILESIZE=200000 in /home/ivan/.bashrc
    * set force_color_prompt=yes in /home/ivan/.bashrc
    * append bashrc file with custom parameters in /home/ivan/.bashrc
    * setup currect time locale
    * setup bashrc for root user
* Packages installation
    * add custom repository: ppa:danielrichter2007/grub-customizer
    * add custom repository: ppa:webupd8team/sublime-text-3
    * update list of available packages
    * ubuntu deb packages installation
    * install glances tool
    * Install repo tool
    * Install telegram
    * Install skype
    * Install QT Creator
* Packages configuration
    * git configuration

