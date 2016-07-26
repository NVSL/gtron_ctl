#!/usr/bin/env bash

mkdir .tmp
pushd .tmp

if [ "$1." = "." ]; then
    branch=master
else
    branch=$1
fi

if ! curl https://raw.githubusercontent.com/NVSL/gtron_devel/${branch}/repo/lib/install_util.sh > install_util.sh; then
    echo couldn't download install_util.sh;
    exit 1
fi
    
if ! curl https://raw.githubusercontent.com/NVSL/gtron_devel/${branch}/repo/lib/install_common.sh > install_common.sh; then
    echo couldn't download install_util.sh;
    exit 1
fi

source install_util.sh
source install_common.sh

popd
#rm -rf .tmp

#echo  "Enter your NVSL lab username:"
#read nvsl_user

user=$nvsl_user
user=$nvsl

if ! [ "$(uname)." = "Darwin." ]; then
    echo "Enter your password on this machine:"
    sudo true
fi

ensure_ssh_key

echo "Enter your github username:"
read github_user
push_ssh_key_to_github

start_ssh_agent

if [ "$(uname)." = "Darwin." ]; then
    true;
else
    sudo apt-get install -y curl git
fi

if ! [ -d gtron_devel ]; then
    git clone -b ${branch} git@github.com:NVSL/gtron_devel.git
else
    (cd gtron_devel;
     git pull;
     git checkout ${branch};
     git pull
    )
fi

pushd gtron_devel

source repo/lib/install_util.sh
source repo/lib/install_common.sh

source gtron_env.sh
(cd repo/lib; install_global_python) # This will get us virtualenv. 


banner "Setting up development environment (this may take a while)."
gtron --force setup_devel --github-user $github_user
verify_success
activate_gadgetron

banner "Setting up global system configuration."
gtron --force update_system --install-apps
verify_success

source gtron_env.sh

if [ "$DEVEL_SETUP_ONLY." = "yes." ]; then
    exit 0
fi


banner "Checking out everything"
gtron update
banner "Building everything"
gtron build
banner "Testing everything"
gtron test
popd

banner "Completed Gadgtron setup".

request "You need to do 'cd gtron_devel; source gtron_env.sh;'"

request "Then you can type ' (cd Gadgets/Tools/jet_2/; utils/start_jet.sh)' to start jet."

request "Type 'gtron full_docs' to learn how to use the 'gtron' utility to manage this workspace."
