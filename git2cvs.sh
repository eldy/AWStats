#!/bin/sh
# This script must be ran from a CVS repository


cvs update
#cvs udpate -C


export GIT_DIR=/home/ldestailleur/git/awstats/.git

git-cvsexportcommit IDCOMMIT

