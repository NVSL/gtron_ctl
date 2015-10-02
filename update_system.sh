#!/usr/bin/env bash

# Install the non-python dependencies

pushd ${0%/*}

. install_util.sh

banner Updating system-wide packages

deactivate # leave the virtual environment
which python

if [ "$(uname)." = "Darwin." ]; then
    brew install $(cat config/brew_packages.txt)
    pip install --upgrade $(cat config/global_python.txt)
else
    sudo -H apt-get -y $(cat config/ubuntu_packages.txt)
    sudo -H pip install --upgrade $(cat config/global_python.txt)
fi

