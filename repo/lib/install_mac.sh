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
    
    (brew tap homebrew/x11 &&
     brew install python spatialindex cgal swig sdl sdl_image sdl_mixer sdl_ttf portmidi hg inkscape curl nodejs libxml2 libxslt wget) 2>&1 | save_log install_brew_packages
    verify_success
}

# install 32-bit eagle (didn’t need any of the apt-get craziness on wiki)
function install_eagle() {
    banner "Installing Eagle..."
    (wget -O eagle-mac64-7.4.0.zip http://web.cadsoft.de/ftp/eagle/program/7.4/eagle-mac64-7.4.0.zip &&
    unzip eagle-mac64-7.4.0.zip &&
    open eagle-mac64-7.4.0.pkg) 2>&1 | save_log install_eagle
    verify_success

    while ! [ -e /Applications/EAGLE-7.4.0/EAGLE.app/Contents/MacOS/EAGLE ]; do
	request "Please complete the Eagle installer.";
	sleep 5;
    done

}

function install_arduino() {
    #Install latest version of arduino:
    banner "Installing latest version of Arduino..."
    (wget -O arduino-1.6.4-macosx.zip http://arduino.cc/download.php?f=/arduino-1.6.4-macosx.zip &&
    unzip arduino-1.6.4-macosx.zip &&
    mv Arduino.app /Applications/ ) 2>&1 | save_log install_arduino
}

function install_GAE() {
    banner "Installing Google app engine..."

    (wget -O GoogleAppEngineLauncher-1.9.27.dmg https://storage.googleapis.com/appengine-sdks/featured/GoogleAppEngineLauncher-1.9.27.dmg &&
    open GoogleAppEngineLauncher-1.9.27.dmg ) 2>&1 | save_log install_gae
    

    while ! [ -e /Applications/GoogleAppEngineLauncher.app ]; do
	  request "Copy the Google App Engine Launcher app into the your Applications folder.  Press return when done"
	  sleep 5
    done

    open /Applications/GoogleAppEngineLauncher.app
    while ! [ -e /usr/local/bin/dev_appserver.py ]; do
	request "Complete GAE installation. Click 'yes' to symlinks."
	sleep 5
    done
}


function fix_up() {
    true
}
