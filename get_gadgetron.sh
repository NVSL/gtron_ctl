#!/bin/bash
    
pushd ${0%/*}

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
    echo "===================== ERROR! ==========================="
    echo $@
    echo "========================================================"
    exit 1
}

# Get latest version
if ! [ "$1." = "up-to-date." ]; then
    wget --no-cache -O get_gadgetron.sh -o update.log https://github.com/NVSL/gadgetron-vm-util/raw/master/get_gadgetron.sh;
    chmod u+x get_gadgetron.sh;
    exec ./get_gadgetron.sh up-to-date
fi

# get sudo permision early.
sudo true

if ! [ -e "./Gadgetron" -a -e ~/.ssh/id_rsa.pub ]; then
    request "Enter your NVSL lab username:"
    read user
fi
    
if ! [ -e ~/.ssh/id_rsa.pub ]; then 
    request "Generating public key.  Please accept all the defaults"
    ssh-keygen
    eval `ssh-agent`
    ssh-add
    request "Provide NVSL password to transfer pub key to svn repo"
    cat .ssh/id_rsa.pub | ssh $user@bbfs-01.calit2.net "cat >> .ssh/authorized_keys"

    request  'Visit \n\nhttps://github.com/settings/ssh \n\nand add this key by copying and pasting it into the space provided.  Give it a meaningful name, like "Gadgetron Development Key"'
    cat .ssh/id_rsa.pub

    request "PRESS RETURN WHEN YOU HAVE DONE SO. (waiting...)"
    read junk
    
fi

eval `ssh-agent`
ssh-add

banner "Checking out and building gadgetron:"

if ! [ -d "Gadgetron" ]; then
    banner "Building Gadgetron for the first time takes a while, especially 'Gadgets/Tools/pyinstall'.  Be patient."
    mkdir Gadgetron
    (cd Gadgetron
    svn checkout -N svn+ssh://$user@bbfs-01.calit2.net/grw/Gordon/svn/trunk/branches/swanson/git-migration .
    ./initial_setup gadgets)
fi

source setup_gadgets

./update_system.sh
./setup_gadgetron.sh
./update_gadgetron.sh

banner Done!

request "You need to do 'source Gadgetron/setup_gadgets'"

request "Then you can type ' (cd Gadgetron/Gadgets/Tools/jet_2/; make run)' to start jet."


#sleep 1;
#nohup google-chrome http://localhost:8080 &
