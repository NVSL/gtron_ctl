#!/bin/bash

#if ! [ "$1." = "up-to-date." ]; then
#    wget --no-cache -O checkout_gadgetron -o update.log https://github.com/NVSL/gadgetron-vm-util/raw/master/checkout_gadgetron;
#    chmod u+x checkout_gadgetron ;
#    exec ./checkout_gadgetron up-to-date
#fi

if [ "$(uname)." = "Darwin." ]; then
    true;
else
    echo Installing git...
    sudo apt-get -y install git > git_install.log
fi

if ! [ -d gtron_devel ]; then
    echo Checking out gtron_devel
    git clone https://github.com/NVSL/gtron_devel.git > checkout_gtron_devel.log
else
    echo Updating out gtron_devel
    (cd gtron_devel; git pull) > gtron_devel/repo/logs/update_gtron_devel.log
fi

mkdir -p gtron_devel/repo/logs
if [ -e git_install.log ]; then
    mv git_install.log gtron_devel/repo/logs/
fi
if [ -e checkout_gtron_devel.log ]; then
    mv checkout_gtron_devel.log gtron_devel/repo/logs/;
fi

cd gtron_devel

source gtron_env.sh

source repo/lib/install_util.sh
source repo/lib/install_common.sh


if ! [ -e "./Gadgets" -a -e "~/.ssh/id_rsa.pub" ]; then
    request "Enter your NVSL lab username:"
    read user
fi

if ensure_ssh_key; then
    push_ssh_key_to_bb_cluster
    push_ssh_key_to_github
fi

start_ssh_agent

repo/bin/update_system.sh --install
repo/bin/setup_gadgetron.sh
repo/bin/update_gadgetron.sh

banner Done!

request "You need to do 'cd gtron-devel; source gtron_env.sh; activate_gadgetron"

request "Then you can type ' (cd Gadgets/Tools/jet_2/; make run)' to start jet."
