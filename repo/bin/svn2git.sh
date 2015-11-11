#!/usr/bin/env bash

#pushd ${0%/*}
MY_HOME=${0%/*}

if [ ".$1" = "." -o ".$2" = "." ]; then
   echo "usage: svn2git.sh <svn repo> <GIT repo>"
   exit 0
fi 

SVNREPO=svn+ssh://swanson@bbfs-01.calit2.net/grw/Gordon/svn/trunk/Gadgets/$1  # Directory in our svn you want to import.
GITREPO=git@github.com:NVSL/$2.git # name of git repo on our gitlab server (you need to create this ahead of time. it should be empty)

echo $SVNREPO
echo $GITREPO

echo Checking out $SVNREPO from svn, and moving it to $GETREPO
echo If $GITREPO does not exist, this will fail.


git svn clone --authors-file=$MY_HOME/../config/names.mapped $SVNREPO
cd ${1##*/}

git remote add origin $GITREPO
git push -u origin master

#Tools/jet_2 jet true




#gist84hCow
#cat svn-to-git.map | while read SVN GIT; do echo curl -s -u stevenjswanson https://api.github.com/orgs/NVSL/repos -d '{"name":"'$GIT'"}'; done

# Split out Dingo test boards into a separate repo

# #left behind
# Makefile
# PADSUtil
# GadgetMaker1
# GadgetMakerEagle1
# Rocket
# cygwin
# pcbartmaker
# pyinstall
# ucsdjet
# dummysch



