#####################################################################
#                                                                   #
# CSC 116 Automated 'Grading' Tool.  Will compile and execute files #
# from students, and check style, after download/extraction from    #
# Moodle.  Generates 2 output files for each step - an              #
# output_[step].txt file, and an output_[step]_error.txt file,      #
# both from stdout and stderr.                                      #
# Also generates a report based on output files.  Read that,        #
# and ignore the rest.                                              #
#                                                                   #
# Arguments expected: .java file to compile                         #
#                     directory of student programs.                #
#                       Use rename script if they aren't in their   #
#                       own directories before running script.      #
#                     y/n, whether to use Renaming Script or not    #
#                                                                   #
# Optional arguments: expected output file for comparison           #
#                     input file for stdin                          #
#                                                                   #
# Use: sh CompileAndExecuteScript file.java folder/                 #
# Note: This script assumes you have Zach Butler &                  #
#   Dr. Jessica Schmidt's RenameScript program in the               #
#   same directory.                                                 #
# Note: This program optionally expects an expected file AND        #
#   an input file, or just an expected file.  It will not work      #
#   with only an input file.                                        #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# A quick note on how to download student submissions from Moodle.  #
#  (As well as setting up for the script)                           #
# 1. Go to the assignment quick grade page.                         #
# 2. From the drop-down menu next to 'Grading Action', choose       #
#    'Download all Submissions'.  It will download an archive file. #
# 3. Save this archive as described in the directory structure      #
#    diagram as detailed below, and extract it so your setup        #
#    matches the expected.  Then, delete the archive file.          #
# 4. Run the script.                                                #
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
# Expected file/directory structure (before script):                #
# Directory                                                         #
#  -- CompileAndExecuteScript.sh                                    #
#  -- RenameScript.java                                             #
#  -- GenerateReport.java                                           #
#  -- Assignment Directory                                          #
#      -- Student_Numbers_assignmsubmission_file_JavaProgram.java   #
#      -- Student_Numbers_assignmsubmission_file_JavaProgram.java   #
#      -- ...                                                       #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Expected file/directory structure (after script):                 #
# Directory                                                         #
#  -- CompileAndExecuteScript.sh                                    #
#  -- RenameScript.java                                             #
#  -- GenerateReport.java                                           #
#  -- Assignment Directory                                          #
#      -- Student 1 Directory                                       #
#          -- JavaProgram.java                                      #
#          -- JavaProgram.class                                     #
#          -- output_compile.txt                                    #
#          -- output_compile_error.txt                              #
#          -- output_execute.txt                                    #
#          -- output_execute_error.txt                              #
#          -- output_style.txt                                      #
#          -- output_style_error.txt                                #
#          -- Report.txt                                            #
#      -- Student 2 Directory                                       #
#      -- ...                                                       #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Changelog                                                         #
#   v0   - 16/09/12 - Initial version.                              #
#   v0.1 - 16/09/29 - Updated documentation. SO MUCH DOCUMENTATION. #
#              Started work on arguments.                           #
#              Integrated RenameScript.java                         #
#   v0.2 - 16/10/04 - Started adding optional expected files.       #
#   v1.0 - 16/10/11 - Added optional expected files.                #
#              Started work on adding optional input files.         #
#   v1.1 - 16/10/21 - Integrated GenerateReport.java                #
#              GenerateReport is currently required, will make      #
#              optional once I get to a proper terminal.            #
#              Fixed checking for Stylechecker                      #
#                                                                   #
#####################################################################

#!/bin/bash/

compileAndExecuteAndStyle() {

    #Check if file supplied by user exists AND is readable.
    #Note: change -r to -f if you only care that the file exists.
    #But reading is probably important.
    #Does -r imply -f?
    if [ ! -r $COMP_FILENAME ]; then
        echo "ERR: $COMP_FILENAME not found or could not be read."
        echo ${PWD##*/}
        #echo "Exiting program with status 1."
        #exit 1
        return
    fi

    #Yeah I'm not super happy with deleting files in the script
    #But it's probably the best thing to do.
    #I'm explicitly writing them out because I don't want to take chances.
    echo "NOTE: Deleting old output files if they exist."
    rm -f output_compile.txt output_compile_error.txt
    rm -f output_execute.txt output_execute_error.txt
    rm -f output_style.txt output_style_error.txt

    echo "--------------------------------------------------------"

    #Compile the given file notice.
    echo "NOTE: Attempting to compile $COMP_FILENAME"
    echo "NOTE: Output and errors will be printed to output_compile.txt and output_compile_error.txt"

    #Compile the given file, output anything to these files.
    javac $COMP_FILENAME > output_compile.txt 2> output_compile_error.txt

    COMP_OUTPUT="output_compile.txt"
    COMP_OUTPUT_ERROR="output_compile_error.txt"

    #Make sure we compiled and were able to output to files.
    if [ ! -r $COMP_OUTPUT ]; then
        echo "ERR: Could not create output file for compilation."
        echo "Exiting program with status 2"
        exit 2
    fi

    if [ ! -r $COMP_OUTPUT_ERROR ]; then
        echo "ERR: Could not create output file for compilation error."
        echo "Exiting program with status 2"
        exit 2
    fi

    #Check if there were compilation errors.
    if [ $(stat -c%s output_compile_error.txt) -gt 0 ]; then
        echo "ERR: Compilation errors detected.  Would you like to continue? (y\n)"
        read confirmation
        if [ "$confirmation" != "y" ]; then
            echo "Exiting program with status 3."
            exit 3
        else 
            echo "NOTE: Continuing.  Errors may compound."
        fi
    else
        echo "NOTE: No compilation errors detected."
    fi

    echo "NOTE: Compilation complete."
    echo "--------------------------------------------------------"

    #Drop the .java from the filename, execute from that.
    EXEC_FILENAME=${COMP_FILENAME%.java}
    echo "NOTE: Attempting to execute $EXEC_FILENAME"
    echo "NOTE: Output and errors will be printed to output_execute.txt and output_execute_error.txt"
    
    #Execute the program to the output files.
    if [ "$HAVE_INPUT" = "true" ]; then
        read -t 1 -n 10000 discard
        java $EXEC_FILENAME <$INPUT_FILE > output_execute.txt 2> output_execute_error.txt
    else
        java $EXEC_FILENAME > output_execute.txt 2> output_execute_error.txt
    fi
    
    #Do comparisons for errors during executions.
    #I think this might only happen if you have errors during compilation.
    if [ $(stat -c%s output_execute_error.txt) -gt 0 ]; then
        echo "ERR: Execution errors detected."
        echo "NOTE: Continuing.  Errors may compound."
    else
        echo "NOTE: No execution errors detected."
    fi
    
    echo "NOTE: Execution complete."
    
    echo "--------------------------------------------------------"
    
    if [ $HAVE_OUTPUT = "true" ]; then
        echo "NOTE: Doing output comparison."
        echo "NOTE: Lack of pipe character indicates lines are equal."
        echo "Expected file                                 | User Output File"
        
        #Using -y because that makes two columns for viewing - easier to read.
        diff -y --width=100 $EXPECTED_FILE output_execute.txt
        
        read -n 1 -r -s -p "NOTE: Press any key to continue
"
        
        echo "--------------------------------------------------------"
    fi
    
    

    echo "NOTE: Automated Style Checker executing."
    echo "NOTE: This program assumes your style checker exists in ~/cs/."

    if [ ! -d ~/cs/ ]; then
        echo "ERR: Could not find checkstyle in ~/cs/.  Please install Checkstyle to ~/cs/"
        echo "Exiting program with status 5"
        exit 5
    fi

    ~/cs/checkstyle $COMP_FILENAME > output_style.txt 2> output_style_error.txt

    if [ $(stat -c%s output_style_error.txt) -gt 0 ]; then
        echo "ERR: Errors occured while checking style.  Details in output_style_error.txt"
    fi

    #This is some funky math.
    #So, the amount of bytes written by checkstyle is 199 + name of file -.java
    #So we check for size of file > (199 + length of program name)
    #If greater, we have style errors.  If not, it's equal and we're good to go.
    STYLE_FILESIZE=$(stat -c%s output_style.txt)
    COMP_FILENAME_WITHOUT_JAVA=${COMP_FILENAME%.java}

    if [ "$STYLE_FILESIZE" -gt $(( 199 + ${#COMP_FILENAME_WITHOUT_JAVA} )) ]; then
        echo "NOTE: Style errors detected.  ;-;"
    else
        echo "NOTE: No style errors detected.  Great!"
    fi
	
}

#####################################################################
#                                                                   #
#     Privacy divider.  Please respect the privacy of the code.     #
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

#Check if user supplied a file as an argument.
if [ $# -lt 3 ]; then
    echo "ERR: Below minimum argument count."
    echo "Expected [something].java [folder of assignments] Rename [y/n]"
    echo "Optional arguments following: [expected output] [inputFile]"
    echo "Exiting program with status 0."
    exit 0
fi

if [ $# -gt 5 ]; then
    echo "ERR: Above maximum argument count."
    echo "Expected [something].java [folder of assignments] Rename [y/n]"
    echo "Optional arguments following: [expected output] [inputFile]"
    echo "Exiting program with status 0."
    exit 0
fi

#Making sure Argument 1 is a java file.  Or has a java extension at least.
#Grep as suggested by Curtis Moore.  Everyone can thank Curtis more.
if grep -q "*.java" <<<$1; then
    echo "ERR: Java file argument lacks java extension."
    echo "Exiting program with status 0."
    exit 0
fi

#We're sure it's a java file, so we go ahead and assign a value.
COMP_FILENAME="$1"

#Making sure argument 2 is a directory.
if [ ! -d $2 ]; then
    echo "ERR: Argument 2 is not a directory."
    echo "Exiting program with status 0."
    exit 0
fi

#Making sure argument 3 is y or n

#Trying to compress this to RENAME_VAR=${$3,,} causes a bad substitution error.
#So we have to be a bit inefficient with it
RENAME_VAR=$3
RENAME_VAR=${RENAME_VAR,,}

#Check if the value, after lowercase conversion, is y or n.
if [ "$RENAME_VAR" != "y" ] && [ "$RENAME_VAR" != "n" ]; then
    echo "ERR: Argument 3 is not y or n.  Will not take command."
    echo "Exiting program with status 0."
    exit 0
fi

if [ "$RENAME_VAR" == "y" ]; then
    if [ ! -r "RenameScript.java" ]; then
        echo "ERR: RenameScript.java does not exist."
        echo "Exiting program with status 0."
        exit 0
    fi
    #TODO: do this in the script/a separate script
    javac RenameScript.java; java RenameScript $2
fi

HAVE_OUTPUT=false
HAVE_INPUT=false

if [ $# -ge 4 ]; then
    if [ ! -r $4  ]; then
        echo "ERR: Expected output file does not exist."
        echo "Exiting program with status 0."
        exit 0
    else
        HAVE_OUTPUT=true
        
        #Because, for some reason, doing just $myDir/$4 doesn't work.
        EXPECTED_FILE=$myDir/$4
    fi
    if [ $# == 5 ] && [ ! -r $5 ]; then
        echo "ERR: Input file does not exist."
        echo "Exiting program with status 0."
        exit 0
    else
        HAVE_INPUT=true
        INPUT_FILE=$myDir/$5
    fi
fi

#Change directory to the directory of many folders.
#Life has many directories edboy
#Note to future self: this has to be last, because of file checks.
cd $2

#The working loop.  Loops through each directory in the $2 directory,
#And runs the compilation function on it, with the filename argument.
for d in *; do
    #check if * is a directory, not a file
    if [ -d "${d}" ]; then
        cd "${d}"
        if [ -r $COMP_FILENAME ]; then
            clear
            echo "NOTE: Current working directory: ${d}"
            compileAndExecuteAndStyle "$COMP_FILENAME"
			echo "--------------------------------------------------------"
			echo "NOTE: Generating Report based on output files."
			java -classpath $myDir GenerateReport $myDir/$2/"${d}"
			sleep 1
        else
            echo "Err: File does not exist"
        fi
        cd ..
    fi
done

exit 0 
