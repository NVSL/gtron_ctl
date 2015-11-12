#!/usr/bin/env bash

mkdir .tmp
pushd .tmp

if [ "$1." = "." ]; then
    branch=master
else
    branch=$1
fi

curl https://raw.githubusercontent.com/NVSL/gtron_devel/${branch}/repo/lib/install_util.sh > install_util.sh
curl https://raw.githubusercontent.com/NVSL/gtron_devel/${branch}/repo/lib/install_common.sh > install_common.sh

source install_util.sh
source install_common.sh

popd
#rm -rf .tmp

#echo  "Enter your NVSL lab username:"
#read nvsl_user

user=$nvsl_user
user=$nvsl

echo "Enter your password on this machine:"
sudo true

ensure_ssh_key

echo "Enter your github username:"
read github_user
push_ssh_key_to_github

start_ssh_agent

git clone -b ${branch} git@github.com:NVSL/gtron_devel.git
pushd gtron_devel

source repo/lib/install_util.sh
source repo/lib/install_common.sh

source gtron_env.sh
banner "Setting up global system configuration.  Ignore the following warnings about misconfiguration..."
gtron --force update_system --install-apps

banner "Setting up development environment (this make take a while).  Ignore errors about misconfiguration."
gtron --force setup_devel --github-user $github_user
activate_gadgetron

banner "Checking out everything"
gtron update
banner "Building everything"
gtron build
banner "Testing everything"
gtron test
popd

banner "Completed Gadgtron setup".

request "You need to do 'cd gtron_devel; source gtron_env.sh;'"

request "Then you can type ' (cd Gadgets/Tools/jet_2/; make run)' to start jet."

request "Type 'gtron full_docs' to learn how to use the 'gtron' utility to manage this workspace."
