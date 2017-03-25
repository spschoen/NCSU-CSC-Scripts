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
# Optional Arguments: -e expected output file for comparison        #
#                     -i input file for stdin                       #
#                     -f/-q for fast script w/ less information     #
#                     -n to not execute file, just compile.         #
#                     -t to set custom timeout limit.               #
#                                                                   #
# Use: sh CompileAndExecuteScript -p file.java -d dir/ [optionals]  #
#                                                                   #
# Note: This script assumes you have Zach Butler &                  #
#   Dr. Jessica Schmidt's RenameScript program in the               #
#   same directory.                                                 #
#                                                                   #
# Note: This program optionally expects an expected file AND        #
#   an input file, or just an expected file.  It will not work      #
#   with only an input file.                                        #
#                                                                   #
# Note: This script benefits greatly from GenerateReport.sh         #
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
#   v1.6 - 17/03/25 - Documentation, log files, some extra goodies. #
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

# I'm calling this the 'global' area.
# Variables that get used later, functions used, etc.

FAST_FILE="output_fast.txt"

COMPILE_FILE="output_compile.txt"
COMPILE_ERROR_FILE="output_compile_error.txt"

EXECUTE_FILE="output_execute.txt"
EXECUTE_ERROR_FILE="output_execute_error.txt"

STYLE_FILE="output_style.txt"
STYLE_ERROR_FILE="output_style_error.txt"

readonly LOG_FILE="$(pwd)/$(basename "$0")_$(date +%s).log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

compileAndExecuteAndStyle() {

	# if [ "$CAP_FAST" == "y" ]; then
    # 
	# else
    # 
	# fi

	if [ "$CAP_FAST" == "y" ]; then
		if [ ! -f $COMP_FILENAME ]; then
			error "$COMP_FILENAME not found or could not be read."
			return
		fi

		if [ ! -f $EXEC_FILENAME ]; then
			error "$EXEC_FILENAME not found or could not be read."
			return
		fi
	fi

    #Check if file supplied by user exists AND is readable.
    #Note: change -r to -f if you only care that the file exists.
    #But reading is probably important.
    #Does -r imply -f?
    if [ ! -r $COMP_FILENAME ]; then
        error "$COMP_FILENAME not found or could not be read."
        error "${PWD##*/}"
        return
    fi

    #Yeah I'm not super happy with deleting files in the script
    #But it's probably the best thing to do.
    #I'm explicitly writing them out because I don't want to take chances.
    info "Deleting old output files if they exist."
	if [ "$CAP_FAST" == "y" ]; then
		rm -f $FAST_FILE
	else
		rm -f $COMPILE_FILE $COMPILE_ERROR_FILE
		rm -f $EXECUTE_FILE $EXECUTE_ERROR_FILE
		rm -f $STYLE_FILE $STYLE_ERROR_FILE
		rm -f diff.txt
	fi

    info "--------------------------------------------------"

    #Compile the given file notice.
    info "Attempting to compile $COMP_FILENAME"
    info "Output and errors will be printed to $COMPILE_FILE and $COMPILE_ERROR_FILE"

    #Compile the given file, output anything to these files.

	if [ "$CAP_FAST" == "y" ]; then
		javac $COMP_FILENAME > $FAST_FILE 2>> $FAST_FILE
	else
		javac $COMP_FILENAME > $COMPILE_FILE 2> $COMPILE_ERROR_FILE
	fi

    #Make sure we compiled and were able to output to files.
    if [ ! -r $COMPILE_FILE ]; then
        error "Could not create output file for compilation."
        error "Exiting program with status 2"
        exit 2
    fi

    if [ ! -r $COMPILE_ERROR_FILE ]; then
        error "Could not create output file for compilation error."
        error "Exiting program with status 2"
        exit 2
    fi

    #Check if there were compilation errors.
    if [ $(stat -c%s $COMPILE_ERROR_FILE) -gt 0 ]; then
        error "Compilation errors detected.  Errors may compound."
    else
        info "No compilation errors detected."
    fi

    info "Compilation complete."
    info "--------------------------------------------------"

    #Literally only about GUIs.
    if [ "$NO_EXEC" = "n" ]; then

		# Replace .java with .class.
		EXEC_FILENAME="${COMP_FILENAME%.java}.class"

		if [ ! -r $EXEC_FILENAME ]; then
			warning "Class not found, or readable.  Skipping execution."
			return
		fi

        #Drop the .java from the filename, execute from that.
        info "Attempting to execute $EXEC_FILENAME"
        info "Output and errors will be printed to $EXECUTE_FILE and $EXECUTE_ERROR_FILE"

		#Execute the program to the output files.
        if [ "$HAVE_INPUT" = "true" ]; then
			read -t 1 -n 10000 discard
            if [ ${#ARGUMENT} -eq 0 ]; then
				if [ "$CAP_FAST" == "y" ]; then
					timeout $TIME_LIMIT java $EXEC_FILENAME <$INPUT_FILE > $FAST_FILE 2>> $FAST_FILE
				else
					timeout $TIME_LIMIT java $EXEC_FILENAME <$INPUT_FILE > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
				fi
            else
				if [ "$CAP_FAST" == "y" ]; then
					timeout $TIME_LIMIT java $EXEC_FILENAME $ARGUMENT <$INPUT_FILE > $FAST_FILE 2>> $FAST_FILE
				else
					timeout $TIME_LIMIT java $EXEC_FILENAME $ARGUMENT <$INPUT_FILE > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
				fi
            fi
        else
            if [ ${#ARGUMENT} -eq 0 ]; then
				if [ "$CAP_FAST" == "y" ]; then
					timeout $TIME_LIMIT java $EXEC_FILENAME > $FAST_FILE 2>> $FAST_FILE
				else
					timeout $TIME_LIMIT java $EXEC_FILENAME > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
				fi

            else
				if [ "$CAP_FAST" == "y" ]; then
					timeout $TIME_LIMIT java $EXEC_FILENAME $ARGUMENT > $FAST_FILE 2>> $FAST_FILE
				else
					timeout $TIME_LIMIT java $EXEC_FILENAME $ARGUMENT > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
				fi

            fi
        fi

        if [ $? -eq 124 ]; then
            error "Error: Timeout Occured.  Infinite Loop/Break detected." >> $EXECUTE_ERROR_FILE
        fi

		#Do comparisons for errors during executions.
        #I think this might only happen if you have errors during compilation.
		if [ "$CAP_FAST" != "y" ] && [ $(stat -c%s $EXECUTE_ERROR_FILE) -gt 0 ]; then
			error "Execution errors detected."
            info "Continuing.  Errors may compound."
		else
			info "No execution errors detected."
		fi

        info "Execution complete."
        info "--------------------------------------------------"
    fi

    if [ $HAVE_OUTPUT = "true" ]; then
		info "Doing output comparison."

		if [ "$CAP_FAST" == "y" ]; then
			diff -y $EXPECTED_FILE $EXECUTE_FILE >> $FAST_FILE
		else
			info "Lack of pipe character indicates lines are equal."
			info "Expected file                                 | User Output File"

			#Using -y because that makes two columns for viewing - easier to read.
			# tee -a "$LOG_FILE" >&2
			diff -y -W100 $EXPECTED_FILE $EXECUTE_FILE
			diff -y -W100 $EXPECTED_FILE $EXECUTE_FILE >> "$LOG_FILE"
		fi

        info "--------------------------------------------------"
    fi

	if [ "$CAP_FAST" != "y" ]; then
		info "Automated Style Checker executing."
		info "This program assumes your style checker exists in ~/cs/."

		if [ ! -d ~/cs/ ]; then
			error "Could not find checkstyle in ~/cs/.  Please install Checkstyle to ~/cs/"
			error "Exiting program with status 5"
			exit 5
		fi

		echo $COMP_FILENAME_WITHOUT_JAVA > $STYLE_FILE
		~/cs/checkstyle $COMP_FILENAME > $STYLE_FILE 2> $STYLE_ERROR_FILE

		if [ $(stat -c%s $STYLE_ERROR_FILE) -gt 0 ]; then
			error "Errors occured while checking style.  Details in $STYLE_ERROR_FILE"
		fi

		#This is some funky math.
		#So, the amount of bytes written by checkstyle is 199 + name of file -.java
		#So we check for size of file > (199 + length of program name)
		#If greater, we have style errors.  If not, it's equal and we're good to go.
		STYLE_FILESIZE=$(stat -c%s $STYLE_FILE)
		COMP_FILENAME_WITHOUT_JAVA=${COMP_FILENAME%.java}

		if [ "$STYLE_FILESIZE" -gt $(( 199 + ${#COMP_FILENAME_WITHOUT_JAVA} )) ]; then
			info "Style errors detected.  ;-;"
		else
			info "No style errors detected.  Great!"
		fi
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
    error "Lacking Java File Argument."
    error "Exiting program with status 0."
    exit 0
else
    #Making sure Argument 1 is a java file.  Or has a java extension at least.
    if  [[ $COMP_FILENAME != *.java ]]; then
        error "Java file argument lacks java extension."
        error "Exiting program with status 0."
        exit 0
    fi
fi

if [ ${#DIRECTORY} == 0 ]; then
    error "Lacking Directory Argument."
    error "Exiting program with status 0."
    exit 0
else
    #Making sure argument 2 is a directory.
    if [ ! -d $DIRECTORY ]; then
        error "Argument 2 is not a directory."
        error "Exiting program with status 0."
        exit 0
    fi
fi

if [ "$TIME_LIMIT" -le "0" ]; then
    error "Timeout limit provided 0, less than 0, or non-integer."
    info "Setting Timeout limit to default 15."
    TIME_LIMIT=15
    sleep 1
fi

#Cleaning everything up.
clear

#Shamelessly stolen from stackoverflow, as per 90% of any production code is.
directoryCount=`find $DIRECTORY/* -maxdepth 1 -type d | wc -l`

if [ $directoryCount -eq 0 ]; then
    info "Did not detect subdirectories in $DIRECTORY, running RenameScript if it exists."
    if [ ! -r "RenameScript.java" ]; then
        error "RenameScript.java does not exist."
        error "Could not rename files.  Exiting program with status 0"
        exit 0
    else
        #Note to futuer self - make it detected whether to run javac or java only.
        if [ ! -f "RenameScript.class" ]; then
            javac RenameScript.java
        fi
        java RenameScript $DIRECTORY
    fi
else
    info "Subdirectories detected in $DIRECTORY, RenameScript will not be executed."
fi

if [ -r "FirstLastToUnity.java" ] && [ -r "mapping.txt" ]; then
    info "Running UnityID Mapper."
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
        error "Expected output file does not exist."
        error "Exiting program with status 0."
        exit 0
    else
        HAVE_OUTPUT=true
    fi

    #We can only have an input file if we have an output file.
    if [ ${#INPUT_FILE} != 0 ]; then
        INPUT_FILE="$EXEC_DIR"/$INPUT_FILE
        if [ ! -r $EXPECTED_FILE ]; then
            error "Input file does not exist."
            error "Exiting program with status 0."
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

FILE_COUNT="$(ls -1 "$EXEC_DIR"/$DIRECTORY | wc -l)"

#echo $FILE_COUNT

if [ $FILE_COUNT -eq "1" ]; then
    # echo "Pretty sure that's an archive in there boss."
	info "Possible archive found in $DIRECTORY"
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
            info "Current working directory: ${d}"
			compileAndExecuteAndStyle
			if [ -f "$EXEC_DIR"/"ReportGenerator.sh" ]; then
				info "--------------------------------------------------"
				info "Generating Report based on output files."
				bash "$EXEC_DIR"/"ReportGenerator.sh" ./
				echo $(pwd) >> "Report.txt"
			fi
            sleep 1
        else
            error "File does not exist"
        fi
        cd ..
		info "--------------------------------------------------------"
    fi
done

cd "$EXEC_DIR"

exit 0
