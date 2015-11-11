#!/usr/bin/env bash

cd ${0%/*}

if [ ".$1" = "." ]; then
    echo "usage: setup_gadgetron.sh  <github username>"
fi 

#gtron --force config_set nvsl_user $1
gtron --force config_set github_user $1
#gtron --force config_set branch master

source ../lib/install_util.sh

confirm_gadgetron

# this is necessary on unbuntu, it seems.
export CPATH=/usr/include/libxml2

banner "Setting up local build environment."

if ! [ -d $GADGETRON_VENV ]; then
    banner "Creating fresh Python virtual environment: $GADGETRON_VENV"
    mkdir -p $GADGETRON_VENV
    virtualenv $GADGETRON_VENV | save_log create_venv
    newVenv=yes
fi

source $GADGETRON_VENV/bin/activate

confirm_venv

banner "Installing local python dependencies"
pip install -r ../config/local_python.txt | save_log local_python

banner "(re)building cgal bindings from git"
mkdir -p ../build
(cd ../build
 if ! [ -d "cgal-bindings" ];then
     git clone https://github.com/sciencectn/cgal-bindings.git
 else
     (cd cgal-bindings; git pull)
 fi
 (cd cgal-bindings; python setup.py install)
) 2>&1 | save_log build_cgal

banner Success!

if [ "$newVenv." = "yes." ]; then
    request "You need to do 'activate_gadgetron' in this shell."
fi

