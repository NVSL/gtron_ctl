#!/usr/bin/env bash

moduleName=$1
copysrc=$2

echo $moduleName
echo $copysrc

if [ ".$moduleName" = "." -o ".$copysrc" = "." ]; then
   echo "usage: prepPackage <moudleName> <dir to copy setup.py from>"
   exit 0
fi 
   
FILES="VERSION.txt MANIFEST.in DESCRIPTION.rst README.txt $moduleName/__init__.py"
DIRS="doc Test"

mkdir $moduleName
svn add $moduleName

svn mv $(ls -1| grep -v $moduleName) $moduleName/
svn cp $copysrc/setup.py ./
svn cp $copysrc/Makefile ./

mkdir $DIRS
svn add $DIRS

touch $FILES
svn add $FILES




