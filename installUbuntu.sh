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
    echo $1
    echo "========================================================"
    echo
}

function request () {
    echo
    echo "===================== TAKE ACTION! ====================="
    echo $1
    echo "========================================================"
    echo
}

# install 32-bit eagle (didn’t need any of the apt-get craziness on wiki)
banner "Installing Eagle..."
wget -O eagle-lin32-7.4.0.run http://web.cadsoft.de/ftp/eagle/program/7.4/eagle-lin32-7.4.0.run
sudo bash eagle-lin32-7.4.0.run


request "Eagle is is going to ask you to create a directory.  Say yes, then exit."

/opt/eagle-7.4.0/bin/eagle # click ok about creating the directory.

#install system-wide packages
banner "Installing system-wide packages (this will take a while)..."
sudo apt-get -y install python-pip libspatialindex-dev python-pygame libcgal-dev swig inkscape curl nodejs npm subversion emacs git cython python-lxml npm swig libpython-dev libxml2 libxml2-dev libxslt1-dev arduino vim
#sudo apt-get remove arduino #  It's the wrong version, but it gives us all the support libs (E.g., java)

banner "Get latest pip"
sudo -H pip install -U pip
sudo -H pip install -U pip

#Install latest version of arduino:
banner "Installing latest version of Arduino..."
wget -O arduino-1.6.4-linux32.tar.xz http://arduino.cc/download.php?f=/arduino-1.6.4-linux32.tar.xz
sudo tar xf arduino-1.6.4-linux32.tar.xz -C  /usr/local/ 
sudo ln -sf /usr/local/arduino-1.6.4/arduino /usr/local/bin/

#echo
#echo "Arduino is is going to ask you if you want be added to the dialout group.  Say yes, then exit."
#echo
#arduino  # click “add” when it asks you about the “dial up group”

banner "Installing python virtualenv..."
#install virtualenv
sudo -H pip install virtualenv

#banner "Installing cgal bindings (this will take a while)..."
#sudo pip install --upgrade --no-cache-dir --force-reinstall  cgal-bindings

#install global javascript resources
banner "Installing global javascript resources..."
sudo -H npm install -g bower tsd grunt grunt-cli 
# apt-get uses a non-standard name for the nodejs executable, which causes problems.
sudo ln -sf `which nodejs` /usr/local/bin/node 
sudo chown -R gadgetron ~/.npm
sudo chgrp -R gadgetron ~/.npm

banner "Installing python packages..."
# optionally install python stuff globally.
sudo pip install cython lxml pypng beautifulsoup4 requests svgwrite Mako clang bintrees numpy jinja2 Sphinx asciitree rtree pyparsing
#cgal-bindings

banner "Installing Google app engine..."

wget -O google_appengine_1.9.26.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.26.zip
unzip google_appengine_1.9.26.zip
sudo mv google_appengine /usr/local/
sudo bash -c 'echo PATH=\$PATH:/usr/local/google_appengine >> /etc/profile'

request "Making github work easily (say 'yes')"
git clone git@github.com:NVSL/gadgetron-vm-util.git
rm -rf gadgetron-vm-util
git clone git@github.com:NVSL/gadgetron-vm-util.git
rm -rf gadgetron-vm-util

banner Configuring ssh

#mkdir ~/.ssh
cat > ~/.ssh/config  <<EOF
Host bb-*
Port 425
Host bbfs-*
Port 425
EOF

chmod og-rwx -R ~/.ssh

echo export USE_VENV=yes >> ~/.bashrc

cat >> ~/.bashrc <<EOF
echo
echo "To start gadgetron installation, run './checkout_gadgetron'"
echo
EOF

banner "All done!!!"

request "Please log out and log back in."

