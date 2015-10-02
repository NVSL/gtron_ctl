#!/usr/bin/env bash

DIR=$1  # Directory in our svn you want to import
GIT=$2  # name of git repo on our gitlab server (you need to create this ahead of time. it should be empty)

echo $DIR
echo $GIT

if [ ".$DIR" = "." -o ".$GIT" = "." ]; then
   echo "usage: svn2git.sh <path relative to svn+ssh://bbfs-01.calit2.net/grw/Gordon/svn/trunk/Gadgets> <GIT repo name>"
   exit 0
fi 

GITREPO=git@github.com:NVSL/$2.git

echo Checking out svn+ssh://bbfs-01.calit2.net/grw/Gordon/svn/trunk/Gadgets/$1 from svn, and moving it to $GETREPO
echo If $GITREPO does not exist, this will fail.

git svn clone --authors-file=$GADGETRON_ROOT/Tools/pyinstall/names.mapped svn+ssh://bbfs-01.calit2.net/grw/Gordon/svn/trunk/Gadgets/$DIR
cd $(echo $DIR| perl -ne '@a =split("/"); print "$a[-1]"')
git remote add origin $GITREPO
git push -u origin master


# #private
# BOBBuilder
# AutomaKit
# CaseMaker
# CbC
# CircuitsByCode
# Dingo
# Koala
# GadgetMaker2
# gspec
# jet_2
# ucsdgadgetron

# JetLibrary

# #public
# Checkers
# Eagle
# EagleArt
# EagleComposer
# EagleUtil
# GCompiler
# SVGUtil
# gadgetron-setup
# gcam
# laserTurtle
# rpiutil
# util

# Designs
# GadgetronCAM
# GadgetronEagleLibs

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



