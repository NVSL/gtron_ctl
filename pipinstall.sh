#!/usr/bin/env bash

. ./install_util.sh

confirm_gadgetron

# this is necessary on unbuntu, it seems.
export CPATH=/usr/include/libxml2

banner "Setting up local build environment."

if ! [ -d $GADGETRON_VENV ]; then
    banner "Creating fresh Python virtual environment: $GADGETRON_VENV"
    virtualenv $GADGETRON_VENV | redirect venv.log
fi

confirm_venv

banner "Installing local python dependencies"
pip install -r config/local_python.txt | redirect local_python.log

#pip install -r $GADGETRON_ROOT/Tools/CbC/requirements.txt

banner "(re)building cgal bindings from git"
mkdir -p build
(if ! [ -d "cgal-bindings" ];then
     (cd build; git clone https://github.com/sciencectn/cgal-bindings.git)
 else
     (cd build/cgal-bindings; git pull)
 fi
 (cd build/cgal-bindings; python setup.py install)
) 2>&1 | redirect cgal-build.log

banner Success!
#./gitinstall.sh $GADGETRON_ROOT
