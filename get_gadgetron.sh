#!/bin/bash

pushd ${0%/*}

# Get latest version
#if ! [ "$1." = "up-to-date." ]; then
#    wget --no-cache -O get_gadgetron.sh -o update.log https://github.com/NVSL/gadgetron-vm-util/raw/master/get_gadgetron.sh;
#    chmod u+x get_gadgetron.sh;
#    exec ./get_gadgetron.sh up-to-date
#fi

source lib/install_util.sh
source lib/install_commmon.sh

if ! [ -e "./Gadgetron" -a -e ~/.ssh/id_rsa.pub ]; then
    request "Enter your NVSL lab username:"
    read user
fi

if ensure_ssh_key; then
    push_ssh_key_to_bb_cluster
    push_ssh_key_to_github
fi

start_ssh_agent

checkout_gadgetron_root

source setup_gadgets

popd

./update_system.sh
./setup_gadgetron.sh
./update_gadgetron.sh

banner Done!

request "You need to do 'cd Gadgetron; source setup_gadgets'"

request "Then you can type ' (cd Gadgetron/Gadgets/Tools/jet_2/; make run)' to start jet."
