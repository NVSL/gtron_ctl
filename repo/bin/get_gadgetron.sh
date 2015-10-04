#!/bin/bash

if [ "$(uname)." = "Darwin." ]; then
    true;
else
    sudo apt-get -y install git
fi

if ! [ -d gtron_devel ]; then
    git clone https://github.com/NVSL/gtron_devel.git
else
    (cd gtron_devel; git pull)
fi

cd gtron_devel

. gtron_env.sh

if ! [ -e "./Gadgets" -a -e ~/.ssh/id_rsa.pub ]; then
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
