#!/bin/bash

CDIR=`pwd`

. gtron_env_core.sh

#export GADGETRON_ROOT=$PWD/Gadgets
export GADGETRON_VENV=$PWD/repo/venv/Gadgetron

export USE_VENV=yes

#  Setup the PATH
PATH=$GADGETRON_ROOT/Tools/BOBBuilder/BOBBuilder:\
$GADGETRON_ROOT/Tools/EagleUtil/EagleUtil:\
$GADGETRON_ROOT/Tools/PADSUtil/PADSUtil:\
$GADGETRON_ROOT/Tools/SVGUtil/SVGUtil:\
$GADGETRON_ROOT/Tools/EagleArt/EagleArt:\
$GADGETRON_ROOT/Tools/pcbartmaker/pcbartmaker:\
$GADGETRON_ROOT/Tools/Gadgetron/Gadgetron:\
$GADGETRON_ROOT/Tools/Dingo/Dingo:\
$GADGETRON_ROOT/Tools/CaseMaker/CaseMaker:\
$GADGETRON_ROOT/Tools/util/gtron_util:\
$GADGETRON_ROOT/Tools/cyborg/cyborg:\
$GADGETRON_ROOT/Tools/GadgetMaker2/GadgetMaker2:\
$GADGETRON_ROOT/Tools/dummysch/dummysch:\
$GADGETRON_ROOT/Tools/Checkers/Checkers:\
$GADGETRON_ROOT/Tools/GCompiler/GCompiler:\
$GADGETRON_ROOT/Tools/CbC/bin:\
/Applications/Arduino.app/Contents/MacOS:\
$PATH

export PATH

export STANDARD_CACHE_DIR="$PWD/repo/cache/pip"
export WHEELHOUSE="${STANDARD_CACHE_DIR}/wheelhouse"
export PIP_FIND_LINKS="file://${WHEELHOUSE}"
export PIP_WHEEL_DIR="${WHEELHOUSE}"

function activate_gadgetron () {
    source $(which activate_gadgetron.sh)
}

function deactivate_gadgetron () {
    source $(which deactivate_gadgetron.sh)
}

activate_gadgetron

export GADGETRON_CATALOG=$GADGETRON_ROOT/Libraries/JetComponents/Catalog
export GADGETRON_CONFIG=$AUTOMAKIT/gadgetron.config
export DOWNLOAD_DIR=$HOME/Downloads


export PYTHONPATH=$GADGETRON_ROOT/../repo/bin:$PYTHONPATH


# in order of preference
# Don't include 7.5.0 unless you are also going to fix the order in that pass the .sch and .brd files to Eagle.  It has be in the right order or eagle will choke, and the correct order has changed in 7.5.0



#For gcloud servers
#if [ -e $(readlink ../eagle.sh) ]; then
#    export EAGLE_EXE=$(readlink ../eagle.sh)
#fi

if [ ".$EAGLE_EXE" = "." ]; then
    echo "Couldn't set EAGLE_EXE.  Please edit setup_gadgets so that others who use your OS won't have this problem in the future"
fi

if [ -e /Applications/Inkscape.app/Contents/Resources/bin/inkscape ]; 
then
    export INKSCAPE_EXE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

elif [ -e /usr/bin/inkscape ];
then
    export INKSCAPE_EXE=/usr/bin/inkscape 

else
    echo "Couldn't set INKSCAPE_EXE.  Please edit setup_gadgets so that others who use your OS won't have this problem in the future"
fi

export ARDUPI_HOME=$GADGETRON_ROOT/Tools/rpiutil
