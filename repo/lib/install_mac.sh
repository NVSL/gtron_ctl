#!/usr/bin/env bash

# this script installs everything necessary to run the gadgetron tool chain.
#
# It assumes you start with a clean, default Yosemite installation with brew
# for package management.
#
# It was built to prepare a VM for gadgetron develompent.  It's probably not
# safe to run this on an existing machine, but it should provide a good roadmap
# for installation in general.

function check_for_package_manager() {

    if ! [ -e /usr/local/bin/brew ]; then
	request "You need to install brew.  \nThis will clash if you have another package manager installed, so I am not going to do it automatically.\nYou can do it with 'ruby -e \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"'"
	exit 1;
    fi
}

function install_system_packages() {
    banner Installing Brew packages
    
    brew tap homebrew/x11
    brew install python spatialindex cgal swig sdl sdl_image sdl_mixer sdl_ttf portmidi hg inkscape curl nodejs libxml2 libxslt wget || error Brew failed
}

# install 32-bit eagle (didn’t need any of the apt-get craziness on wiki)
function install_eagle() {
    banner "Installing Eagle..."
    wget -O eagle-mac64-7.4.0.zip http://web.cadsoft.de/ftp/eagle/program/7.4/eagle-mac64-7.4.0.zip || error Downloading eagle failed
    unzip eagle-mac64-7.4.0.zip || error Uncompressing eagle failed
    open eagle-mac64-7.4.0.pkg

    request "Please complete the Eagle installer, and then press return"
    read junk
}

function install_arduino() {
    #Install latest version of arduino:
    banner "Installing latest version of Arduino..."
    wget -O arduino-1.6.4-macosx.zip http://arduino.cc/download.php?f=/arduino-1.6.4-macosx.zip || error Downloading Arduino failed.
    unzip arduino-1.6.4-macosx.zip || error Unzipping Arduino failed.
    mv Arduino.app /Applications/ || error Installing ARduino failed.
}

function install_GAE() {
    banner "Installing Google app engine..."

    wget -O GoogleAppEngineLauncher-1.9.27.dmg https://storage.googleapis.com/appengine-sdks/featured/GoogleAppEngineLauncher-1.9.27.dmg || error Downloading GAE failed
    open GoogleAppEngineLauncher-1.9.27.dmg || error Mounting GAE Disk image failed.
    
    request "Copy the Google App Engine Launcher app into the your Applications folder.  Press return when done"
    read junk

    request "Click 'yes' when Google App Engine asks about creating symlinks."
    
    open /Applications/GoogleAppEngineLauncher.app
}


function fix_up() {
    true
}
