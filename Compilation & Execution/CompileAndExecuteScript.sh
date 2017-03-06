#####################################################################
#                                                                   #
# CSC 116 Automated 'Grading' Tool.  Will compile and execute files #
# from students, and check style, after download/extraction from    #
# Moodle.  Generates 2 output files for each step - an              #
# output_[step].txt file, and an output_[step]_error.txt file,      #
# both from stdout and stderr.                                      #
# Also generates a report based on output files if you have         #
# GenerateReports.java in the same directory, which generates       #
# a Report.txt file for each submission                             #
#                                                                   #
# Required Arguments: -p .java file to compile                      #
#                     -d directory of student programs.             #
#                                                                   #
# Optional Arguments:  expected output file for comparison          #
#                      input file for stdin                         #
#                      y or n (or nothing) for fast script          #
#                                                                   #
# Use: sh CompileAndExecuteScript file.java dir/ [optional args]    #
#                                                                   #
# Note: This script assumes you have Zach Butler &                  #
#   Dr. Jessica Schmidt's RenameScript program in the               #
#   same directory.                                                 #
#                                                                   #
# Note: This program optionally expects an expected file AND        #
#   an input file, or just an expected file.  It will not work      #
#   with only an input file.                                        #
#                                                                   #
# Note: This script benefits greatly from GenerateReport.java       #
#   (another of my scripts) by summarizing the six (!) output files #
#   from compilation, execution, and style checking.                #
#                                                                   #
# Note: This script will run slow at first launch, especially if    #
#   you haven't already run javac in the current session.  That's   #
#   just how java is, as we're all well aware by this point.        #
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
#      -- Student 1 Directory (UnityID if FirstLastToUnity is used) #
#          -- JavaProgram.java                                      #
#          -- JavaProgram.class                                     #
#          -- output_compile.txt                                    #
#          -- output_compile_error.txt                              #
#          -- output_execute.txt                                    #
#          -- output_execute_error.txt                              #
#          -- output_style.txt                                      #
#          -- output_style_error.txt                                #
#          -- Report.txt                                            #
#      -- Student 2 Directory (UnityID if FirstLastToUnity is used) #
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
#   v1.2 - 16/11/10 - RenameScript is automatically run when needed #
#   v1.3 - 16/11/17 - Integrated FirstLastToUnity usage.            #
#   v1.3 - 16/11/17 - Added fast compilation mode, final arg y/n    #
#   v1.4 - 16/12/09 - Removed argument option, made execution       #
#              optional.  Use -n or --no-execute.                   #
#   v1.5 - 17/01/03 - Fixed execution so infinite loops are handled #
#                       and added argument option for timeout.      #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Script runtime on three example directories...                    #
#    ...normal mode: 27.24 seconds                                  #
#    ...fast mode  : 11.60 seconds                                  #
#                                                                   #
#####################################################################

#!/bin/bash/

capFast() {

    echo "Beginning fast compilation of $(pwd)"
    
    EXEC_FILENAME=${COMP_FILENAME%.java}
    EXEC_FILENAME="$EXEC_FILENAME.class"

    #Check if file supplied by user exists AND is readable.
    if [ ! -f $COMP_FILENAME ]; then
        echo "${bold}ERR:${normal} $COMP_FILENAME not found or could not be read."
        return
    fi
    
    if [ ! -f $EXEC_FILENAME ]; then
        echo "${bold}ERR:${normal} $EXEC_FILENAME not found or could not be read."
        return
    fi

    rm -f output_fast.txt
    
    #Compile the given file notice.
    echo "NOTE: Compiling $COMP_FILENAME"
    
    #Compile the given file, output anything to these files.
    javac $COMP_FILENAME > output_fast.txt 2>> output_fast.txt
    
    #Make sure we compiled and were able to output to files.
    if [ ! -r "output_fast.txt" ]; then
        echo "${bold}ERR:${normal} Could not create output file for compilation."
        echo "Moving on to next submission."
        return
    fi
    
    #Check if there were compilation errors.
    if [ $(stat -c%s output_compile_error.txt) -gt 0 ]; then
        echo "${bold}ERR:${normal} Compilation errors detected.  Moving on to next submission."
        return
    fi
    
    if [ ! -r $EXEC_FILENAME ]; then
        echo "Could not create class.  Moving to next submission."
        return
    fi
    if [ "$NO_EXEC" = "n" ]; then
        #Drop the .class from the filename, execute from that.
        EXEC_FILENAME=${COMP_FILENAME%.class}
        echo "NOTE: Executing $EXEC_FILENAME"
        
        #Execute the program to the output files.
        if [ "$HAVE_INPUT" = "true" ]; then
            read -t 1 -n 10000 discard
            timeout $TIME_LIMIT java $EXEC_FILENAME <$INPUT_FILE > output_execute.txt 2>> output_fast.txt
        else
            timeout $TIME_LIMIT java $EXEC_FILENAME > output_execute.txt 2>> output_fast.txt
        fi
        
        if [ $? -eq 124 ]; then
            echo "Error: Timeout Occured.  Infinite Loop/Break detected." >> output_execute_error.txt
        fi
        
        #Do comparisons for errors during executions.
        #I think this might only happen if you have errors during compilation.
        if [ $(stat -c%s output_execute_error.txt) -gt 0 ]; then
            echo "${bold}ERR:${normal} Execution errors detected.  Moving on to next submission."
            return
        fi
    fi
    
    
    if [ $HAVE_OUTPUT = "true" ]; then
        echo "NOTE: Doing output comparison."
        
        #Using -y because that makes two columns for viewing - easier to read.
        diff -y $EXPECTED_FILE output_execute.txt >> output_fast.txt
        
    fi
    
}

compileAndExecuteAndStyle() {

    #Check if file supplied by user exists AND is readable.
    #Note: change -r to -f if you only care that the file exists.
    #But reading is probably important.
    #Does -r imply -f?
    if [ ! -r $COMP_FILENAME ]; then
        echo "${bold}ERR:${normal} $COMP_FILENAME not found or could not be read."
        echo ${PWD##*/}
        return
    fi

    #Yeah I'm not super happy with deleting files in the script
    #But it's probably the best thing to do.
    #I'm explicitly writing them out because I don't want to take chances.
    echo "NOTE: Deleting old output files if they exist."
    rm -f output_compile.txt output_compile_error.txt
    rm -f output_execute.txt output_execute_error.txt
    rm -f output_style.txt output_style_error.txt
    rm -f diff.txt
    
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
        echo "${bold}ERR:${normal} Could not create output file for compilation."
        echo "Exiting program with status 2"
        exit 2
    fi
    
    if [ ! -r $COMP_OUTPUT_ERROR ]; then
        echo "${bold}ERR:${normal} Could not create output file for compilation error."
        echo "Exiting program with status 2"
        exit 2
    fi
    
    #Check if there were compilation errors.
    if [ $(stat -c%s output_compile_error.txt) -gt 0 ]; then
        echo "${bold}ERR:${normal} Compilation errors detected.  Errors may compound."
    else
        echo "NOTE: No compilation errors detected."
    fi
    
    echo "NOTE: Compilation complete."
    echo "--------------------------------------------------------"

    #Literally only about GUIs.
    if [ "$NO_EXEC" = "n" ]; then
        #Drop the .java from the filename, execute from that.
        EXEC_FILENAME=${COMP_FILENAME%.java}
        echo "NOTE: Attempting to execute $EXEC_FILENAME"
        echo "NOTE: Output and errors will be printed to output_execute.txt and output_execute_error.txt"
        
        #Execute the program to the output files.
        if [ "$HAVE_INPUT" = "true" ]; then
                read -t 1 -n 10000 discard
            if [ ${#ARGUMENT} -eq 0 ]; then
                timeout $TIME_LIMIT java $EXEC_FILENAME <$INPUT_FILE > output_execute.txt 2> output_execute_error.txt
            else
                timeout $TIME_LIMIT java $EXEC_FILENAME "$EXEC_DIR"/$ARGUMENT <$INPUT_FILE > output_execute.txt 2> output_execute_error.txt
            fi
        else
            if [ ${#ARGUMENT} -eq 0 ]; then
                timeout $TIME_LIMIT java $EXEC_FILENAME > output_execute.txt 2> output_execute_error.txt
            else
                timeout $TIME_LIMIT java $EXEC_FILENAME "$EXEC_DIR"/$ARGUMENT > output_execute.txt 2> output_execute_error.txt
            fi
        fi
        
        if [ $? -eq 124 ]; then
            echo "Error: Timeout Occured.  Infinite Loop/Break detected." >> output_execute_error.txt
        fi
        
        #Do comparisons for errors during executions.
        #I think this might only happen if you have errors during compilation.
        if [ $(stat -c%s output_execute_error.txt) -gt 0 ]; then
            echo "${bold}ERR:${normal} Execution errors detected."
            echo "NOTE: Continuing.  Errors may compound."
        else
            echo "NOTE: No execution errors detected."
        fi
        
        echo "NOTE: Execution complete."
        echo "--------------------------------------------------------"
    fi
    
    if [ $HAVE_OUTPUT = "true" ]; then
        echo "NOTE: Doing output comparison."
        echo "NOTE: Lack of pipe character indicates lines are equal."
        echo "Expected file                                 | User Output File"
        
        #Using -y because that makes two columns for viewing - easier to read.
        diff -y -W100 $EXPECTED_FILE output_execute.txt
        
        diff -y $EXPECTED_FILE output_execute.txt > diff.txt
        
        #read -n 1 -r -s -p "
#NOTE: Press any key to continue
#"
        
        echo "--------------------------------------------------------"
    fi
    
    echo "NOTE: Automated Style Checker executing."
    echo "NOTE: This program assumes your style checker exists in ~/cs/."
    
    if [ ! -d ~/cs/ ]; then
        echo "${bold}ERR:${normal} Could not find checkstyle in ~/cs/.  Please install Checkstyle to ~/cs/"
        echo "Exiting program with status 5"
        exit 5
    fi
    
    echo $COMP_FILENAME_WITHOUT_JAVA > output_style.txt
    ~/cs/checkstyle $COMP_FILENAME > output_style.txt 2> output_style_error.txt
    
    if [ $(stat -c%s output_style_error.txt) -gt 0 ]; then
        echo "${bold}ERR:${normal} Errors occured while checking style.  Details in output_style_error.txt"
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

#Sleep for a quick pause.
sleep 0.25

#Saving wherever we started
#Needed because half this script works on relative position of everything.
EXEC_DIR=$(pwd)

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

#Setting up for bolding error messages.
bold=$(tput bold)
normal=$(tput sgr0)

if [ $# -eq 0 ]; then
    echo "You must specify a dialog type. Use '-h' or '--help' for details"
    exit 0
fi

if [ $1 == "-h" ] || [ $1 == "--help" ] || [ $1 == "--h" ] || [ $1 == "-help" ]; then
    echo "Usage:
sh CompileAndExecuteScript.sh [OPTION...]

Help Options:
  -h, --help                    Show help options

Application Options:
  -p, --program                 REQUIRED: Java program to evaluate.
  -d, --dir                     REQUIRED: Directory of submissions to evaluate.
  -e, --expected                Expected output from Java program.
  -i, --input                   Input file for Java Programs.  Requires -e option as well.
  -a, --argument                Possible argument to execute program with (max 1 argument)
  -f, --fast                    Informing the program to run fast - less output and work done.
  -q, --quick                   Same as -f option.
  -n, --no-execute              Do not execute java files, just compile them.
  -t, --time-limit              Time limit for programs to execute for.
"
    exit 0
fi

CAP_FAST="n"
NO_EXEC="n"

#Since this should never be anything but an integer, let's just declare it.
#""""types"""" in bash.
declare -i TIME_LIMIT=15

while [ "$#" -gt 0 ]; do
    case "$1" in
        -p) COMP_FILENAME="$2"; shift 2;;
        -d) DIRECTORY="$2"; shift 2;;
        -e) EXPECTED_FILE="$2"; shift 2;;
        -i) INPUT_FILE="$2"; shift 2;;
        -a) ARGUMENT="$2"; shift 2;;
        -t) TIME_LIMIT="$2"; shift 2;;
        -q) CAP_FAST="y"; shift 1;;
        -f) CAP_FAST="y"; shift 1;;
        -n) NO_EXEC="y"; shift 1;;

        --program=*) COMP_FILENAME="${1#*=}"; shift 1;;
        --dir=*) DIRECTORY="${1#*=}"; shift 1;;
        --expected=*) EXPECTED_FILE="${1#*=}"; shift 1;;
        --input=*) INPUT_FILE="${1#*=}"; shift 1;;
        --argument=*) ARGUMENT="${1#*=}"; shift 1;;
        --time-limit=*) TIME_LIMIT="${1#*=}"; shift 1;;
        --quick=*) CAP_FAST="y"; shift 1;;
        --fast=*) CAP_FAST="y"; shift 1;;
        --no-execute=*) NO_EXEC="y"; shift 1;;
        --program|--dir|--expected|--input) echo "$1 requires an argument" >&2; exit 1;;

        -*) echo "unknown option: $1" >&2; exit 1;;
        *) echo "unrecognized argument: $1"; exit 0
    esac
done

#Check if size of java file is 0
if [ ${#COMP_FILENAME} == 0 ]; then
    echo "${bold}ERR:${normal} Lacking Java File Argument."
    echo "Exiting program with status 0."
    exit 0
else
    #Making sure Argument 1 is a java file.  Or has a java extension at least.
    if  [[ $COMP_FILENAME != *.java ]]; then
        echo "${bold}ERR:${normal} Java file argument lacks java extension."
        echo "Exiting program with status 0."
        exit 0
    fi
fi

if [ ${#DIRECTORY} == 0 ]; then
    echo "${bold}ERR:${normal} Lacking Directory Argument."
    echo "Exiting program with status 0."
    exit 0
else
    #Making sure argument 2 is a directory.
    if [ ! -d $DIRECTORY ]; then
        echo "${bold}ERR:${normal} Argument 2 is not a directory."
        echo "Exiting program with status 0."
        exit 0
    fi
fi

if [ "$TIME_LIMIT" -le "0" ]; then
    echo "${bold}ERR:${normal} Timeout limit provided 0, less than 0, or non-integer."
    echo "Setting Timeout limit to default 15."
    TIME_LIMIT=15
    sleep 1
fi

#Cleaning everything up.
clear

#Shamelessly stolen from stackoverflow, as per 90% of any production code is.
directoryCount=`find $DIRECTORY/* -maxdepth 1 -type d | wc -l`

if [ $directoryCount -eq 0 ]; then
    echo "NOTE: Did not detect subdirectories in $DIRECTORY, running RenameScript if it exists."
    if [ ! -r "RenameScript.java" ]; then
        echo "${bold}ERR:${normal} RenameScript.java does not exist."
        echo "Could not rename files.  Exiting program with status 0"
        exit 0
    else
        #Note to futuer self - make it detected whether to run javac or java only.
        if [ ! -f "RenameScript.class" ]; then
            javac RenameScript.java
        fi
        java RenameScript $DIRECTORY
    fi
else
    echo "NOTE: Subdirectories detected in $DIRECTORY, RenameScript will not be executed."
fi

if [ -r "FirstLastToUnity.java" ] && [ -r "mapping.txt" ]; then
    echo "Running UnityID Mapper."
    if [ ! -f "FirstLastToUnity.class" ]; then
        javac FirstLastToUnity.java
    fi
    java FirstLastToUnity $DIRECTORY
    sleep 1
fi

HAVE_OUTPUT=false
HAVE_INPUT=false

if [ ${#EXPECTED_FILE} != 0 ]; then
    EXPECTED_FILE="$EXEC_DIR"/$EXPECTED_FILE
    if [ ! -r $EXPECTED_FILE ]; then
        echo "${bold}ERR:${normal} Expected output file does not exist."
        echo "Exiting program with status 0."
        exit 0
    else
        HAVE_OUTPUT=true
    fi
    
    #We can only have an input file if we have an output file.
    if [ ${#INPUT_FILE} != 0 ]; then
        INPUT_FILE="$EXEC_DIR"/$INPUT_FILE
        if [ ! -r $EXPECTED_FILE ]; then
            echo "${bold}ERR:${normal} Input file does not exist."
            echo "Exiting program with status 0."
            exit 0
        else
            HAVE_INPUT=true
        fi
    fi
fi

#Change directory to the directory of many folders.
#Life has many directories edboy
#Note to future self: this has to be last, because of file checks.
cd $DIRECTORY

FILE_COUNT="$(ls -1 $EXEC_DIR/$DIRECTORY | wc -l)"

#echo $FILE_COUNT

if [ $FILE_COUNT -eq "1" ]; then
    echo "Pretty sure that's an archive in there boss."
    for file in "$EXEC_DIR"/"$DIRECTORY"/*; do
        mv "$file" "${file// /_}" #convert all spaces to underscores, because /bruh/
        #echo $file
        file=${file##*/} #remove the path from the file.
        #echo $file
        if [[ "$file" == *.zip ]]; then
            unzip "$file" -d ./
            mkdir -v "$EXEC_DIR/Archives/"
            mv -v "$file" "$EXEC_DIR/Archives/""$file"
            break
        fi
    done
fi

sleep 1
clear

#The working loop.  Loops through each directory in the supplied directory,
#And runs the compilation function on it, with the filename argument.
for d in *; do
    #check if * is a directory, not a file
    if [ -d "${d}" ]; then
        cd "${d}"
        if [ -r $COMP_FILENAME ]; then
            #clear
            echo "NOTE: Current working directory: ${d}"
            if [ "$CAP_FAST" == "y" ]; then        
                capFast "$COMP_FILENAME"
            else
                compileAndExecuteAndStyle
                if [ -f "$EXEC_DIR"/"ReportGenerator.sh" ]; then
                    echo "--------------------------------------------------------"
                    echo "NOTE: Generating Report based on output files."
                    bash "$EXEC_DIR"/"ReportGenerator.sh" ./
                    echo $(pwd) >> "Report.txt"
                fi
            fi
            sleep 1
        else
            echo "${bold}ERR:${normal} File does not exist"
        fi
        cd ..
    fi
done

cd "$EXEC_DIR"

exit 0
