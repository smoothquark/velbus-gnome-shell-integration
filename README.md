# velbus-gnome-shell-integration
A Gnome Shell integration for Velbus

Allows Velbus (https://www.velbus.eu/) Lights and Temperature settings for a room to be accessed via the Gnome shell. Tested on Debian 10 Buster + Gnome 3.30.2.

# Requirements
* Gnome Shell
* The Argos Gnome Shell Extension from https://extensions.gnome.org/extension/1176/argos/
* openHAB

Note that installation of the Argos Gnome Shell Extension may require the Gnome Shell Extension version validation to be disabled:
```
gsettings set org.gnome.shell disable-extension-version-validation "true"
```
Further information and options are available from https://www.maketecheasier.com/disable-extension-version-checks-gnome/

# Installation
The script has to be made executable and installed in ~/.config/argos/. The openHAB server, Room, Light and Thermostat Items are defined by changing the relevant constants in the script. 1s in the file name refers to the refresh time. This can be changed by changing the file name accordingly. The script will create a folder ~/.config/argos/.cache-icons where icons for lights on and off will be downloaded from the openHAB site. The classic icon set will be used by default but this can be changed to modifying the script.

# Acknowledgement
Inspiration for this script was from this link on openHAB: https://community.openhab.org/t/control-openhab-via-gnome-shell-linux-macos-menu-bar-argos-bitbar/27585
