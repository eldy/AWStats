#!/bin/sh

cvs update
#cvs udpate -C


export GIT_DIR=/home/ldestailleur/git/awbot/.git

git-cvsexportcommit IDCOMMIT

