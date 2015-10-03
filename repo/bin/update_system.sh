#!/usr/bin/env bash

# this script installs everything necessary to run the gadgetron tool chain.
#
# It assumes you start with a clean, default ubuntu 15.04 installation.
#
# OR
#
# It assumes you start with a clean, default Yosemite installation with brew
# for package management.
#
# It was built to prepare a VM for gadgetron develompent.  It's probably not
# safe to run this on an existing machine, but it should provide a good roadmap
# for installation in general. In particular, if you source the .sh file
# referenced below, you can install each piece mannually and see how it goes.

pushd ${0%/*}

source ../lib/install_util.sh

source ../lib/install_common.sh

if [ "$(uname)." = "Darwin." ]; then
    source ../lib/install_mac.sh
else
    source ../lib/install_ubuntu.sh
    SUDO="sudo -H"
fi

check_for_package_manager
install_system_packages 
install_global_python 
install_global_javascript 
install_eagle 
install_arduino 
install_GAE 
init_github 
setup_user_ssh 
fix_up

banner "All done!!!"
