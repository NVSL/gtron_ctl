#!/usr/bin/env bash

# this script installs everything necessary to run the gadgetron tool chain.
#
# It assumes you start with a clean, default ubuntu 15.04 installation.
#
# It was built to prepare a VM for gadgetron develompent.  It's probably not
# safe to run this on an existing machine, but it should provide a good roadmap
# for installation in general.

function banner () {
    echo
    echo "========================================================"
    echo $@
    echo "========================================================"
    echo
}

function request () {
    echo
    echo "===================== TAKE ACTION! ====================="
    echo $@
    echo "========================================================"
    echo
}

function error () {
    echo
    echo "===================== FAILURE: ========================="
    echo $@
    echo "========================================================"
    exit
}


if ! [ -e /usr/local/bin/brew ]; then
    request "You need to install brew.  \nThis will clash if you have another package manager installed, so I am not going to do it automatically.\nYou can do it with 'ruby -e \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"'"
    exit ;
fi

banner Installing Brew packages

brew tap homebrew/x11
brew install python spatialindex cgal swig sdl sdl_image sdl_mixer sdl_ttf portmidi hg inkscape curl nodejs libxml2 libxslt wget || error Brew failed

# install 32-bit eagle (didn’t need any of the apt-get craziness on wiki)
banner "Installing Eagle..."
wget -O eagle-mac64-7.4.0.zip http://web.cadsoft.de/ftp/eagle/program/7.4/eagle-mac64-7.4.0.zip || error Downloading eagle failed
unzip eagle-mac64-7.4.0.zip || error Uncompressing eagle failed
open eagle-mac64-7.4.0.pkg

request "Please complete the Eagle installer, and then press return"
read junk

#Install latest version of arduino:
banner "Installing latest version of Arduino..."
wget -O arduino-1.6.4-macosx.zip http://arduino.cc/download.php?f=/arduino-1.6.4-macosx.zip || error Downloading Arduino failed.
unzip arduino-1.6.4-macosx.zip || error Unzipping Arduino failed.
mv Arduino.app /Applications/ || error Installing ARduino failed.


banner "Installing python virtualenv..."
#install virtualenv
pip install virtualenv || error Installing virtualenv failed.

#install global javascript resources
banner "Installing global javascript resources..."
npm install -g bower tsd grunt grunt-cli  || error NPM installs failed.

#banner "Installing python packages..."
pip install --upgrade pip setuptools || error pip upgrade failed.
pip install cython lxml pypng beautifulsoup4 requests svgwrite Mako clang bintrees numpy jinja2 Sphinx asciitree rtree pyparsing || error pip install failed.

banner "Installing Google app engine..."

wget -O GoogleAppEngineLauncher-1.9.27.dmg https://storage.googleapis.com/appengine-sdks/featured/GoogleAppEngineLauncher-1.9.27.dmg || error Downloading GAE failed
open GoogleAppEngineLauncher-1.9.27.dmg || error Mounting GAE Disk image failed.

request "Copy the Google App Engine Launcher app into the your Applications folder.  Press return when done"
read junk

request "Click 'yes' when Google App Engine asks about creating symlinks."

open /Applications/GoogleAppEngineLauncher.app

if ! [ -e ~/.ssh/config ] || ! grep bb- ~/.ssh/config; then 
    banner Configuring ssh
    cat >> ~/.ssh/config  <<EOF
Host bb-*
Port 425
Host bbfs-*
Port 425
EOF
    chmod og-rwx -R ~/.ssh
else
    banner Your ssh seems to be configured correctly for the NVSL cluster
fi

echo export USE_VENV=yes >> ~/.bashrc

banner "All done!!!"


