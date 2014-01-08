#!/bin/sh
# This script must be ran from a CVS repository


# Update CVS repository
cvs update
#cvs udpate -C


# Set here id of last commit
export LASTINCLUDEDID=eea6adb633b5b055b663bafcfef6e8482aeedad4
# Set here where is store git repository
export GIT_DIR=/home/ldestailleur/git/awstats/.git


# Commit 5 commits at once after last commit
git cherry $LASTINCLUDEDID HEAD | sed -n 's/^+ //p' | head -n 5 | xargs -l1 git cvsexportcommit -c -p -v

