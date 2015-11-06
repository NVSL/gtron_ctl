#!/usr/bin/env bash

cd ${0%/*}

source ../lib/install_util.sh
source ../lib/install_common.sh

request "Enter your NVSL lab username:"
read nvsl
request "Enter your github username:"
read github

if ensure_ssh_key; then
    push_ssh_key_to_bb_cluster
    push_ssh_key_to_github
fi

start_ssh_agent

git clone -b develop git@github.com:NVSL/gtron_devel.git
pushd gtron_devel

source gtron_env.sh
gtron --force update_system --install-apps
gtron --force setup_devel --nvsl-user $nvsl --git-user $github
activate_gadgetron

gtron update
gtron build
gtron test
popd

banner Done!

request "You need to do 'cd gtron_devel; source gtron_env.sh;'"

request "Then you can type ' (cd Gadgets/Tools/jet_2/; make run)' to start jet."

request "See https://sites.google.com/a/eng.ucsd.edu/gadgetron/getting-started/gadgetron-svn for more details about how to use the 'gtron' utility to manage this workspace."
