#####################################################################
#                                                                   #
# GUI Wrapper for CompileAndExecuteScript.  Thanks to Zenity, you   #
# can now interface with CompileAndExecuteScript without worrying   #
# too much on whether your arguments are correct.  Some error       #
# checking occurs in this script, but it's very basic compared to   #
# CAE.                                                              #
# In short summary, the following will occur when executing this    #
# script:                                                           #
#   Information prompt basically restating this.                    #
#   Prompt for .java file (asdf.java, for example).                 #
#   Directory selection for directory of submissions.               #
#   Confirmation dialog for whether to rename or not.               #
#   Dialog asking whether you have an expected output file or not.  #
#     File selection for your expected file, if you affirmed.       #
#   Dialog asking whether you have input or not.                    #
#     File selection for your input file, if you affirmed.          #
#                                                                   #
# This script will then execute CAE with correct commands (and      #
# whatever information you provided, as long as it passed error     #
# checking), and CAE will continue as if you executed via command   #
# line the entire time.                                             #
#                                                                   #
# Yes, this script exists entirely to allow TAs to be just a tiny   #
# bit lazier.  Ain't it just grand?                                 #
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
# Changelog                                                         #
#   v1.0 - 16/11/05 - Initial version.                              #
#                                                                   #
#####################################################################

clear

zenity --info --text "This is the test of a GUI wrapper for CompileAndExecuteScript.  You will be shown a set of windows to enter information.  They correspond to the file to compile, directory of submissions, and whether to rename those submissions or not."

bold=$(tput bold)
normal=$(tput sgr0)

file=$(zenity --title="File Selection" --text "Enter Filename to compile (including .java):" --entry)

if [ "$file" = "" ]; then
    echo "${bold}ERR:${normal} No Java file supplied."
    echo "Exiting GUI/Program with status 0"
    exit 0
fi

directory=$(zenity --title="Directory Selection" --file-selection --confirm-overwrite --directory)
renameConfirmation=$(zenity --title="Rename Confirmation" --text "Rename files (y/n):" --question --ok-label="YES" --cancel-label="NO")

if [ "$renameConfirmation" = "0" ]; then
    renameConfirmation="y"
else
    renameConfirmation="n"
fi

expected=0
input=0

expected=$(zenity --title="Expected Output Check" --text "Do you have an expected output file?" --question --ok-label="YES" --cancel-label="NO")

if [ $? -eq "0" ]; then
    expectedOutput=$(zenity --title="Expected File" --file-selection --ok-label="YES" --cancel-label="NO")
    
    #Can only output, or output & input.  Input alone not valid.
    input=$(zenity --title="Expected Output Check" --text "Do you have an input file?" --question --ok-label="YES" --cancel-label="NO")
    if [ $? -eq "0" ]; then
        input=$(zenity --title="Input File" --file-selection --ok-label="YES" --cancel-label="NO")
    fi
fi

if [ "$directory" = "" ]; then
    echo "ERR: No directory supplied."
    echo "Exiting GUI/Program with status 0"
    exit 0
fi

if [ "$expected" != "0" ] && [ "$input" != "0" ]; then
    sh CompileAndExecuteScript.sh $file $directory $renameConfirmation "$expected" "$input"
elif [ "$expected" != "0" ] && [ "$input" == "0" ]; then
    sh CompileAndExecuteScript.sh $file $directory $renameConfirmation "$expected"
elif [ "$expected" == "0" ] && [ "$input" != "0" ]; then
    echo "Error: Will not execute script with input file and no expected file."
elif [ "$expected" == "0" ] && [ "$input" == "0" ]; then
    sh CompileAndExecuteScript.sh $file $directory $renameConfirmation
fi

clear

echo "Compilation complete."
