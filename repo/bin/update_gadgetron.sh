#!/usr/bin/env bash

pushd ${0%/*}

# Envisioned workload:
#  1.  Create a new development direcotry: 'mkdir Gadgetron'
#  2.  git clone git@github.com:NVSL/gadgetron-setup.git
#  3.  execute 'gadgetron-setup/gitinstall.sh'
#  4.  Update your PATH (this script prints out the command you should execute)

#  You should have all the gadgetron tools in 'Gadgetron/' ready for your hacking/committing etc.  All dependencies should be properly tracked and installed a private virtualenv.

source ../lib/install_util.sh

user=$(cat ../config/bb_username.txt)
echo "Checking under user: $user"

confirm_gadgetron
confirm_venv

NVSL_GIT=git@github.com:NVSL
NVSL_SVN=svn+ssh://$user@bbfs-01.calit2.net/grw/Gordon/svn/branches/swanson/git-migration/Gadgets/

tools="
$NVSL_SVN/Tools/CircuitsByCode
$NVSL_GIT/BOBBuilder 
$NVSL_GIT/gadgetron-vm-util
$NVSL_SVN/Tools/EagleUtil
$NVSL_SVN/Tools/gcam
$NVSL_SVN/Tools/AutomaKit
$NVSL_SVN/Tools/Dingo
$NVSL_SVN/Tools/Koala
$NVSL_SVN/Tools/dummysch
$NVSL_SVN/Tools/util
$NVSL_SVN/Tools/SVGUtil
$NVSL_SVN/Tools/EagleArt
$NVSL_SVN/Tools/Checkers
$NVSL_SVN/Tools/GCompiler
$NVSL_SVN/Tools/GadgetMaker2
$NVSL_SVN/Tools/laserTurtle
$NVSL_SVN/Tools/CaseMaker
$NVSL_SVN/Tools/Checkers
$NVSL_SVN/Tools/Dingo
$NVSL_SVN/Tools/Eagle
$NVSL_SVN/Tools/SVGUtil
$NVSL_SVN/Tools/util
$NVSL_SVN/Tools/rpiutil"

libs="
$NVSL_SVN/Libraries/Parts
$NVSL_SVN/Libraries/CAM
$NVSL_SVN/Designs/GadgetronSketchBook
$NVSL_SVN/Libraries/Components
"

designs="
$NVSL_SVN/Designs/testGadget
"

late_tools="
$NVSL_SVN/Tools/jet_2
"

#$NVSL_SVN/Designs/$USER"

#$NVSL_SVN/CbC"

TOOL_DIR=$GADGETRON_ROOT/Tools
do_cmd mkdir -p $TOOL_DIR

DESIGN_DIR=$GADGETRON_ROOT/Designs
do_cmd mkdir -p $DESIGN_DIR

LIB_DIR=$GADGETRON_ROOT/Libraries
do_cmd mkdir -p $LIB_DIR

TOOL_DIR=$GADGETRON_ROOT/Tools
do_cmd mkdir -p $TOOL_DIR

for step in get_or_update build;do 

    banner "Performing $step"
    
    (cd $TOOL_DIR;
     for p in $tools; do
	 dir=$(get_rcs_dir $p)
	 echo -n ${TOOL_DIR##*/}/$dir
	 $step $p
     done
     for p in $tools_nobuild; do
	 dir=$(get_rcs_dir $p)
	 echo -n ${TOOL_DIR##*/}/$dir
	 #$step $p
     done
    )

    (cd $LIB_DIR;
     for p in $libs; do
	 dir=$(get_rcs_dir $p)
	 echo -n ${LIB_DIR##*/}/$dir
	 $step $p
     done
    )

    (cd $DESIGN_DIR;
     for p in $designs; do
	 dir=$(get_rcs_dir $p)
	 echo -n ${DESIGN_DIR##*/}/$dir
	 $step $p
     done
    )

    (cd $TOOL_DIR;
     for p in $late_tools; do
	 dir=$(get_rcs_dir $p)
	 echo -n ${TOOL_DIR##*/}/$dir
	 $step $p
     done
    )
done
