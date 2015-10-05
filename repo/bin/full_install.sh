#!/usr/bin/env bash

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
