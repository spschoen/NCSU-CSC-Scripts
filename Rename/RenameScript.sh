#!/bin/bash

# Use the below if needed.

readonly LOG_FILE="$(pwd)/$(basename "$0")_$(date +%s).log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
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

rm -f *.log

#Saving argument 1.
DIRECTORY="$1"

cd $DIRECTORY

for D in *; do
    if [ -d "${D}" ]; then
		if [[ "${D}" == *" "* ]]; then
			DIR_NAME="${D// /_}"
			info "Renaming ${D} to $DIR_NAME"
			mv "${D}" "$DIR_NAME"
			cd "$DIR_NAME"
		else
			cd "${D}"
		fi
		info "Currently working in: $(pwd)"
		
		for F in *; do
			if [[ "${F}" == *"_"* ]]; then
				FIL_NAME="${F##*_}"
				info "Renaming ${F} to $FIL_NAME"
				mv "${F}" "$FIL_NAME"
			fi
			# info "File: ""${F}"
			
			FILESIZE=$(stat -c%s "${F}")
			if [[ "$FILESIZE" == "76" ]] && [[ "${F}" == *".html" ]]; then
				warning "Detected Moodle downloaded HTML comment with no comment - deleting."
				rm -f "$FILESIZE"
			fi
			
		done
        
		info "--------------------------------------------------"
        cd ..
    fi
done
