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

for D in *; do
    if [ ! -d "${D}" ]; then
        LASTNAME=$(echo ${D} | cut -d' ' -s -f1)
        LASTNAME=$(echo $LASTNAME | rev | cut -d'-' -s -f1 | rev)
        
        FIRSTNAME=$(echo ${D} | cut -d' ' -s -f2)
        FIRSTNAME=$(echo $FIRSTNAME | cut -d'_' -s -f1)
        
        FILE=$(echo ${D} | rev | cut -d'_' -s -f1 | rev)
        # FILE=$(echo $FILE | cut -d'_' -s -f1)
        # echo $FILE
        
        if [ ! -d "$FIRSTNAME""_""$LASTNAME" ]; then
            mkdir "$FIRSTNAME""_""$LASTNAME"
        fi
        if [[ "${D}" == *".html" ]]; then
            # echo "tesT"
		    FILESIZE=$(stat -c%s "${D}")
		    # echo "$FILESIZE"
		    if [[ "$FILESIZE" == "76" ]] && [[ "${D}" == *".html" ]]; then
			    # warning "Detected Moodle downloaded HTML comment with no comment - deleting."
			    rm -f "${D}"
		    fi
        fi
        if [ -f "${D}" ]; then
            mv "${D}" "$FIRSTNAME""_""$LASTNAME"/"$FILE"
        fi
    fi
done

exit

if [[ "$directoryCount" != "0" ]]; then
	info "--------------------------------------------------"
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
				
				FILESIZE=$(stat -c%s "${FIL_NAME}")
				if [[ "$FILESIZE" == "76" ]] && [[ "${F}" == *".html" ]]; then
					warning "Detected Moodle downloaded HTML comment with no comment - deleting."
					rm -f "$FILESIZE"
				fi
				
			done
			
			info "--------------------------------------------------"
			cd ..
		fi
	done
else
	info "--------------------------------------------------"
	for F in *; do
		if [ -f "${F}" ] && [ ! -d "${F}" ]; then
			STUDENT_NAME="${F%%_*}"
			STUDENT_NAME="${STUDENT_NAME// /_}"
			FILE_NAME="${F##*_}"
			# info "Original Name: ""${F}"
			# info "Student Name : ""$STUDENT_NAME"
			# info "File Name    : ""$FILE_NAME"
			if [ ! -d "$STUDENT_NAME" ]; then
				info "Did not detect directory ""$STUDENT_NAME"", creating now."
				mkdir "$STUDENT_NAME"
			fi
			info "Moving ""${F}"" to ""$STUDENT_NAME""/""$FILE_NAME"
			mv "${F}" "$STUDENT_NAME"/"$FILE_NAME"
		fi
		info "--------------------------------------------------"
	done
fi


