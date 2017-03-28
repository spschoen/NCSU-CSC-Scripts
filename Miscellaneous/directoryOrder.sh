#####################################################################
#                                                                   #
# This is a next level lazy script - so lazy, it doesn't even get   #
# documentation.  It's literally designed solely to loop through    #
# directories and do whatever commands you give it.  Because        #
# this is Computer Science - anything done more than 3 times on a   #
# computer MUST be automated immediately.                           #
#                                                                   #
#####################################################################

#!/bin/bash

# Use the below if needed.

readonly LOG_FILE="$(pwd)/$(basename "$0")_$(date +%s).log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

#Cleaning everything up.
clear

#Saving wherever we started
EXEC_DIR=$(pwd)

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

#Check if user supplied arguments
if [ $# -eq 0 ]; then
    fatal "You must specify a directory argument." # Use '-h' or '--help' for details"
fi

if [ ! -d $1 ]; then
    fatal "ERR: Argument 1 is not a directory, or directory does not exist."
fi

#Saving argument 1.
DIRECTORY="$1"

cd $DIRECTORY

for d in *; do
    if [ -d "${d}" ]; then
        cd "${d}"
		info "Currently working in: $(pwd)"
        #COMMANDS GO HERE
    
        echo $(pwd)
        
        #COMMANDS STOP HERE
		info "--------------------------------------------------"
        cd ..
    fi
done
