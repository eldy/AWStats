#!/bin/sh
# This script must be ran from a CVS repository


# Update CVS repository
cvs update
#cvs udpate -C


# Set here id of last commit found into git repo of awstats that were included into cvs
export LASTINCLUDEDID=89ac100831d627ac012e4972af9cc572297de97d
# Set here where is store git repository
export GIT_DIR=/home/ldestailleur/git/awstats/.git

# Commit 5 commits at once after last commit
echo "git cherry $LASTINCLUDEDID HEAD | sed -n 's/^+ //p' | head -n 50"
git cherry $LASTINCLUDEDID HEAD | sed -n 's/^+ //p' | head -n 50

git cherry $LASTINCLUDEDID HEAD | sed -n 's/^+ //p' | head -n 50 | xargs -l1 git cvsexportcommit -c -p -v

