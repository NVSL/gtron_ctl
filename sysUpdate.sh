#!/usr/bin/env bash

# Install the non-python dependencies

echo Updating system packages

if [ "$(uname)." = "Darwin." ]; then
    brew install $(cat brew_packages.txt)
    pip install --upgrade $(cat global_python.txt)
else
    sudo -H apt-get -y $(cat ubuntu_packages.txt)
    sudo -H pip install --upgrade $(cat global_python.txt)
fi
