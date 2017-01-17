#!/bin/sh

#Cleaning everything up.
clear

#Saving wherever we started
WORKING_DIR=$(pwd)

#Don't forget to change directory to wherever we are.
cd $WORKING_DIR

#Check if user supplied arguments
if [ $# -ne 2 ]; then
    echo "ERR: Not given expected arguments."
    echo "Expected [name of archive] [directory to be archived]"
    echo "Expected [name of archive] [directory to be unarchived]"
    echo "Exiting program with status 0."
    exit 0
fi

ARCHIVE=$1
DIRCTRY=$2

if  [[ $ARCHIVE != *.tar ]] && [[ $ARCHIVE != *.gz ]]; then
    echo "ERR: First argument lacks archive extension."
    echo "Exiting program with status 0."
    exit 0
fi

if [ ! -d $DIRCTRY ] && [ -f $DIRCTRY ]; then
    echo "ERR: Second argument not a directory."
    echo "Exiting program with status 0."
    exit 0
fi

if [ -r "tar.log" ]; then
    rm -f tar.log
fi

if [ -f $ARCHIVE ]; then
    echo "$ARCHIVE exists.  Extracting."
    echo "Output will be logged in tar.log."
    if [ ! -d $DIRCTRY ] && [ ! -f $DIRCTRY ]; then
        mkdir $DIRCTRY
    fi
    tar -xzvf $ARCHIVE -C $DIRCTRY 1> tar.log 2> tar.log
else
    echo "$ARCHIVE does not exist.  Archiving."
    echo "Output will be logged in tar.log."
    tar -czvf $ARCHIVE $DIRCTRY 1> tar.log 2> tar.log
fi
