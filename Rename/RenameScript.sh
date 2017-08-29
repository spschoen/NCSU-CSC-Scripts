#####################################################################
#                                                                   #
# It's a script from spschoen.  Run it like any other.              #
# sh RenameScript.sh directory_to_rename/                           #
#                                                                   #
#####################################################################

#!/bin/bash

# Use the below if needed.

readonly LOG_FILE="$(pwd)/$(basename "$0")_$(date +%s).log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }

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

directoryCount=$(find "$DIRECTORY"/* -maxdepth 1 -type d | wc -l)

if [[ "$directoryCount" == "0" ]]; then
    info "Did not detect subdirectories in ""$DIRECTORY"
else
    info "Detected subdirectories in ""$DIRECTORY"
fi

cd "$DIRECTORY"

if [[ "$directoryCount" != "0" ]]; then
	info "--------------------------------------------------"
	for D in *; do
        if [ -d "${D}" ] && [[ "${D}" == *"assignsubmission"* ]]; then
            LASTNAME=$(echo ${D} | cut -d' ' -s -f1)
            LASTNAME=$(echo $LASTNAME | rev | cut -d'-' -s -f1 | rev)
            
            FIRSTNAME=$(echo ${D} | cut -d' ' -s -f2)
            FIRSTNAME=$(echo $FIRSTNAME | cut -d'_' -s -f1)
            
            # info "Original Name: ""${D}"
            # info "Student Name : ""$FIRSTNAME"" ""$LASTNAME"
            
            if [ ! -d "$FIRSTNAME""_""$LASTNAME" ]; then
                mv "${D}" "$FIRSTNAME""_""$LASTNAME"
            else
                mv "${D}"/* "$FIRSTNAME""_""$LASTNAME"
                rm -rf "${D}"
            fi
        fi
    done
    info "Deleting HTML files of size 76 (blank from Noodle)"
    find . -name '*.html' -size 76c -delete
else
	info "--------------------------------------------------"
    info "Deleting HTML files of size 76 (blank from Noodle)"
    find . -name '*.html' -size 76c -delete
    for D in *; do
        if [ ! -d "${D}" ]; then
            LASTNAME=$(echo ${D} | cut -d' ' -s -f1)
            LASTNAME=$(echo $LASTNAME | rev | cut -d'-' -s -f1 | rev)
            
            FIRSTNAME=$(echo ${D} | cut -d' ' -s -f2)
            FIRSTNAME=$(echo $FIRSTNAME | cut -d'_' -s -f1)
            
            FILE=$(echo ${D} | rev | cut -d'_' -s -f1 | rev)
            
			info "Original Name: ""${D}"
			info "Student Name : ""$FIRSTNAME"" ""$LASTNAME"
			info "File Name    : ""$FILE"
            
            if [ ! -d "$FIRSTNAME""_""$LASTNAME" ]; then
                mkdir "$FIRSTNAME""_""$LASTNAME"
            fi
            if [[ "${D}" == *".html" ]]; then
                FILESIZE=$(stat -c%s "${D}")
                if [[ "$FILESIZE" == "76" ]] && [[ "${D}" == *".html" ]]; then
                    warning "Detected Moodle downloaded HTML comment with no comment - deleting."
                    rm -f "${D}"
                fi
            fi
            if [ -f "${D}" ]; then
                mv "${D}" "$FIRSTNAME""_""$LASTNAME"/"$FILE"
            fi
        fi
    done
fi


