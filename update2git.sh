#!/usr/bin/env bash

#Run this in your migration git repo that you created with svn2git

git svn fetch
git svn rebase
git push
