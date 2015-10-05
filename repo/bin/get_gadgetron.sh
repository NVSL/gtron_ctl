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

cd gtron_devel

repo/bin/full_install.sh

