#!/usr/bin/env bash

#pushd ${0%/*}
MY_HOME=${0%/*}

SVNREPO=$1  # Directory in our svn you want to import.
GITREPO=$2  # name of git repo on our gitlab server (you need to create this ahead of time. it should be empty)

echo $DIR
echo $GIT

if [ ".$SVNREPO" = "." -o ".$GITREPO" = "." ]; then
   echo "usage: svn2git.sh <svn repo> <GIT repo>"
   exit 0
fi 

echo Checking out $SVNREPO from svn, and moving it to $GETREPO
echo If $GITREPO does not exist, this will fail.

git svn clone --authors-file=$MY_HOME/../config/names.mapped $SVNREPO
cd ${SVN_REPO##*/}
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



