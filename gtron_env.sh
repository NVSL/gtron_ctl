#!/bin/bash

CDIR=`pwd`

export GADGETRON_ROOT=$PWD/Gadgets
export GADGETRON_VENV=$PWD/repo/venv/Gadgetron

export USE_VENV=yes

#  Setup the PATH
PATH=$GADGETRON_ROOT/Tools/BOBBuilder:\
$GADGETRON_ROOT/Tools/EagleUtil:\
$GADGETRON_ROOT/Tools/PADSUtil:\
$GADGETRON_ROOT/Tools/SVGUtil:\
$GADGETRON_ROOT/Tools/EagleArt:\
$GADGETRON_ROOT/Tools/pcbartmaker:\
$GADGETRON_ROOT/Tools/Gadgetron:\
$GADGETRON_ROOT/Tools/Dingo:\
$GADGETRON_ROOT/Tools/CaseMaker:\
$GADGETRON_ROOT/Tools/util:\
$GADGETRON_ROOT/Tools/cyborg:\
$GADGETRON_ROOT/Tools/GadgetMaker2:\
$GADGETRON_ROOT/Tools/dummysch:\
$GADGETRON_ROOT/Tools/Checkers:\
$GADGETRON_ROOT/Tools/GCompiler:\
$GADGETRON_ROOT/Tools/CbC/bin:\
/Applications/Arduino.app/Contents/MacOS:\
$PWD/repo/bin:\
$PATH

function activate_gadgetron () {
    source $(which activate_gadgetron.sh)
}

function deactivate_gadgetron () {
    source $(which deactivate_gadgetron.sh)
}

activate_gadgetron

export EAGLE_LIBS=$GADGETRON_ROOT/Libraries/GadgetronPCBLibs/Eagle
export EAGLE_CAM=$GADGETRON_ROOT/Libraries/GadgetronCAM/Eagle
export AUTOMAKIT=$GADGETRON_ROOT/Tools/Gadgetron
export GADGETRON_CATALOG=$GADGETRON_ROOT/Libraries/JetComponents/Catalog
export GADGETRON_CONFIG=$AUTOMAKIT/gadgetron.config
export DOWNLOAD_DIR=$HOME/Downloads

export GADGETRON_COMPONENT_LIB=$GADGETRON_ROOT/Libraries/JetComponents

export PYTHONPATH=$GADGETRON_ROOT/../repo/bin:\
$GADGETRON_ROOT/Tools/EagleUtil:\
$GADGETRON_ROOT/Tools/Gadgetron:\
$GADGETRON_ROOT/Tools/Dingo:\
$GADGETRON_ROOT/Tools/util:\
$GADGETRON_ROOT/Tools/SVGUtil:\
$GADGETRON_ROOT/Tools/EagleArt:\
$GADGETRON_ROOT/Tools/Checkers:\
$GADGETRON_ROOT/Tools/GCompiler:\
$GADGETRON_ROOT/Tools/gcam:\
$GADGETRON_ROOT/Tools/CircuitsByCode:\
$GADGETRON_ROOT/Tools/GadgetMaker2:\
$GADGETRON_ROOT/Tools/CircuitsByCode/Extensions:\
$GADGETRON_ROOT/Tools/CbC:\
$GADGETRON_ROOT/Tools/:\
$PYTHONPATH

# in order of preference
# Don't include 7.5.0 unless you are also going to fix the order in that pass the .sch and .brd files to Eagle.  It has be in the right order or eagle will choke, and the correct order has changed in 7.5.0
EAGLE_VERSIONS=("7.4.0" "7.2.0" "7.3.0" "7.1.0" "7.0.1" "7.0.0")

# look for versions on on mac
for i in "${EAGLE_VERSIONS[@]}"; do
    p=/Applications/EAGLE-${i}/EAGLE.app/Contents/MacOS/EAGLE
    if [ -e $p ]; then
       export EAGLE_EXE=$p
       export EAGLE_DTD=/Applications/EAGLE-${i}/doc/eagle.dtd	
       break;
    fi
done

# look for versions on Linux
for i in "${EAGLE_VERSIONS[@]}"; do
    p=/opt/eagle-$i/bin/eagle
    if [ -e $p ]; then
        export EAGLE_EXE=$p
        break;
    fi
done  

# Look for eagle in your home directory.
for i in "${EAGLE_VERSIONS[@]}"; do
    p=$HOME/eagle-$i/bin/eagle
    if [ -e $p ]; then
        export EAGLE_EXE=$p
        break;
    fi
done  

#For the cluster
if [ -e /gro/cad/eagle-7.2.0/bin/eagle ]; then
    export EAGLE_EXE=/gro/cad/eagle-7.2.0/bin/eagle
fi

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
