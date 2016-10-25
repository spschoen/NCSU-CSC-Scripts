#####################################################################
#                                                                   #
# copyFile.sh is made for transferring files to multiple            #
# directories without having to move or copy files manually.        #
# This is really only useful if you're using another script to      #
# interacting with many folders at once, and not inspecting         #
# a single program at a time.                                       #
#                                                                   #
# THIS PROGRAM DOES NOT COPY DIRECTORIES INTO DIRECTORIES.          #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
#               Report errors to spschoen@ncsu.edu                  #
#             (or whoever is maintaining the script)                #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Expected file/directory structure:                                #
# Directory                                                         #
#  -- copyFile.sh                                                   #
#  -- CopiedFile.filetype                                           #
#  -- Assignment Directory                                          #
#      -- Student 1 Directory                                       #
#      -- Student 2 Directory                                       #
#      -- ...                                                       #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Expected file/directory structure (after script):                 #
# Directory                                                         #
#  -- copyFile.sh                                                   #
#  -- CopiedFile.filetype                                           #
#  -- Assignment Directory                                          #
#      -- Student 1 Directory                                       #
#           -- CopiedFile.filetype                                  #
#      -- Student 2 Directory                                       #
#           -- CopiedFile.filetype                                  #
#      -- ...                                                       #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Changelog                                                         #
#   v1.0   - 16/09/22 - Initial version.                            #
#                                                                   #
#####################################################################

#Cleaning everything up.
clear

#Quick sleep just because.
sleep 0.25

#Saving wherever we started
myDir=$(pwd)

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

#Check if user supplied arguments
if [ $# -ne 2 ]; then
    echo "ERR: Not given expected arguments.."
    echo "Expected [directory of directories to distribute file to] [file to distribute]"
    echo "Exiting program with status 0."
    exit 0
fi

if [ ! -d $1 ]; then
    echo "ERR: Argument 1 is not a directory, or directory does not exist."
    echo "Exiting program with status 0."
fi

#Saving argument 1.
DIRECTORY="$1"

#Making sure argument 2 is a file.
if [ ! -f $2 ]; then
    echo "ERR: Argument 2 is not a file, or does not exist."
    echo "Exiting program with status 0."
    exit 0
fi

for d in $DIRECTORY*/; do 
    cp $2 "$d";
    echo "Moved $2 to $d"
done
