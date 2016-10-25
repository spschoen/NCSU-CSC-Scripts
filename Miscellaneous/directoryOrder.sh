#####################################################################
#                                                                   #
# This is a next level lazy script - so lazy, it doesn't even get   #
# documentation.  It's literally designed solely to loop through    #
# directories and do whatever commands you give it.  Because        #
# this is Computer Science - anything done more than 3 times on a   #
# computer MUST be automated immediately.                           #
#                                                                   #
#####################################################################

#Cleaning everything up.
clear

#Saving wherever we started
myDir=$(pwd)

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

#Check if user supplied arguments
if [ $# -ne 1 ]; then
    echo "ERR: Not given expected arguments.."
    echo "Expected [directory of directories to distribute file to]"
    echo "Exiting program with status 0."
    exit 0
fi

if [ ! -d $1 ]; then
    echo "ERR: Argument 1 is not a directory, or directory does not exist."
    echo "Exiting program with status 0."
fi

#Saving argument 1.
DIRECTORY="$1"

cd $DIRECTORY

for d in *; do
    cd "${d}"
    #COMMANDS GO HERE
    
    echo $(pwd)
    
    #COMMANDS STOP HERE
    read -n 1 -r -s -p "
NOTE: Press any key to continue
"
    cd ..
    clear
done
