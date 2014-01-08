#!/bin/sh
# This script must be ran from a CVS repository


cvs update
#cvs udpate -C

export LASTINCLUDEDID=6ddc897cd021ad61cc5661297abe61d04e8c9520
export GIT_DIR=/home/ldestailleur/git/awstats/.git

git cherry $LASTINCLUDEDID HEAD | sed -n 's/^+ //p' | xargs -l1 git cvsexportcommit -c -p -v

