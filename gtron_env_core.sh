export GADGETRON_ROOT=$PWD/Gadgets
export GADGETRON_COMPONENT_LIB=$GADGETRON_ROOT/Libraries/JetComponents
export AUTOMAKIT=$GADGETRON_ROOT/Tools/Gadgetron
export GADGETRON_CONFIG=$AUTOMAKIT/gadgetron.config
export EAGLE_LIBS=$GADGETRON_ROOT/Libraries/GadgetronPCBLibs/Eagle
export EAGLE_CAM=$GADGETRON_ROOT/Libraries/GadgetronCAM/Eagle

PATH=$PATH:$PWD/repo/bin

EAGLE_VERSIONS=( "7.6.0" "7.2.0" "7.3.0" "7.1.0" "7.0.1" "7.0.0" "7.4.0")

# look for versions on on mac
for i in "${EAGLE_VERSIONS[@]}"; do
    p=/Applications/EAGLE-${i}/EAGLE.app/Contents/MacOS/EAGLE
    echo "Looking for version" ${i}
    if [ -e $p ]; then
       echo "Found" $p
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
