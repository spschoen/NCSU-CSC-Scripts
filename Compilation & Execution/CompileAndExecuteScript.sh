#####################################################################
#                                                                   #
# CSC 116 Automated 'Grading' Tool.  Will compile and execute files #
# from students, and check style, after download/extraction from    #
# Moodle.  Generates 2 output files for each step - an              #
# output_[step].txt file, and an output_[step]_error.txt file,      #
# both from stdout and stderr.                                      #
#                                                                   #
# Also generates a report based on output files if you have         #
# GenerateReport.sh in the same directory as this script.           #
#                                                                   #
# Required Arguments: -p .java file to compile                      #
#                     -d directory of student programs.             #
#                                                                   #
# Optional Arguments: -e expected output file for comparison        #
#                     -i input file for stdin                       #
#                     -f/-q for fast script w/ less information     #
#                     -n to not execute a file, just compile it.    #
#                     -t to set custom timeout limit.               #
#                     -c to copy a file to each directory.          #
#                     -ncs to disable use of checkstyle.            #
#                     -t to set custom timeout limit.               #
#                     -t to set custom timeout limit.               #
#                                                                   #
# Use: sh CompileAndExecuteScript -p file.java -d dir/ [optionals]  #
#                                                                   #
# Note: This program optionally expects an expected file AND        #
#   an input file, or just an expected file.  It will not work      #
#   with only an input file.                                        #
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
# Update 17/04/05 - Script now uses a new rename script that        #
#                   can rename moodle files whether they are        #
#                   downloaded as all files in one directory        #
#                   or in multiple directories to begin with        #
#                                                                   #
#                   Oh my god I cannot believe all the lines        #
#                   are equal length! I AM A PROGRAMMING GOD        #
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
#  -- Assignment Directory                                          #
#      -- Student 1 Directory (UnityID if FirstLastToUnity is used) #
#          -- JavaProgram.java                                      #
#          -- JavaProgram.class                                     #
#          -- Report.txt                                            #
#      -- Student 2 Directory (UnityID if FirstLastToUnity is used) #
#      -- ...                                                       #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Changelog                                                         #
#   v0.0.0 - 16/09/12 - Initial version.                            #
#                                                                   #
#   v0.1.0 - 16/09/29 - Updated documentation.                      #
#                       SO MUCH DOCUMENTATION.                      #
#                       Started work on arguments.                  #
#                       Integrated RenameScript.java                #
#                                                                   #
#   v0.2.0 - 16/10/04 - Started adding optional expected files.     #
#                                                                   #
#   v1.0.0 - 16/10/11 - Added optional expected files.              #
#                       Started work on adding optional input files #
#                                                                   #
#   v1.1.0 - 16/10/21 - Integrated GenerateReport.java              #
#                       Fixed checking for Stylechecker             #
#                                                                   #
#   v1.2.0 - 16/11/10 - RenameScript is automatically run if needed #
#                                                                   #
#   v1.3.0 - 16/11/17 - Integrated FirstLastToUnity usage.          #
#                                                                   #
#   v1.3.1 - 16/11/17 - Added fast compilation mode, final arg y/n  #
#                                                                   #
#   v1.4.0 - 16/12/09 - Removed argument option, made execution     #
#                       optional.  Use -n or --no-execute.          #
#                                                                   #
#   v1.5.0 - 17/01/03 - Fixed execution so infinite loops are       #
#                       handled and added argument option for       #
#                       timeout.                                    #
#                                                                   #
#   v1.6.0 - 17/03/25 - Documentation, log files, some extras       #
#                                                                   #
#   v1.6.1 - 17/04/05 - Updated Readme to show removal of           #
#                       RenameScript.java                           #
#                                                                   #
#   v1.6.2 - 17/04/17 - Fixed a bug with report(), reports now gen. #
#                       Added copyfile functionality, -c            #
#                       Fixed a bug where the script failed to      #
#                       execute any java programs.  /shrug          #
#                                                                   #
#   v1.6.3 - 17/08/27 - Checkstyle is no longer required to run     #
#                       and the script won't exit if it doesn't     #
#                       exist at ~/cs/.  Added no-checkstyle        #
#                       options.  -ncs / --no-check                 #
#                                                                   #
#   v1.6.4 - 17/08/29 - Fixed Rename not working because Noodle is  #
#                       pure, unfiltered trash in software form.    #
#                                                                   #
#   v1.6.5 - 17/09/01 - Rename confirmed working.  Updated the      #
#                       documentation, and cleaned up output.       #
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
debug()   { if [[ "$DEBUG" == "true" ]]; then echo "[DEBUG]   $@" | tee -a "$LOG_FILE" >&2; fi ; }

# End of global area.

rename() {

    #Check if user supplied arguments
    if [ $# -eq 0 ]; then
        error "Rename: directory argument not supplied."
        return 21
    fi

    if [ ! -d $1 ]; then
        error "Rename: supplied argument is not a directory/does not exist."
        return 22
    fi

    # rm -f *.log

    #Saving argument 1.
    DIRECTORY="$1"

    directoryCount=$(find "$DIRECTORY"/* -maxdepth 1 -type d | wc -l)

    if [[ "$directoryCount" == "0" ]]; then
        debug "[NORMAL]: Did not detect subdirectories in ""$DIRECTORY"
    else
        debug "[NORMAL]: Detected subdirectories in ""$DIRECTORY"
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
                
                debug "[NORMAL]: Original Name: ""${D}"
                debug "[NORMAL]: Student Name : ""$FIRSTNAME"" ""$LASTNAME"
                
                debug "[NORMAL]: Rename: Moving ""${D}"" to ""$FIRSTNAME""_""$LASTNAME""/"
                if [ ! -d "$FIRSTNAME""_""$LASTNAME" ]; then
                    mv "${D}" "$FIRSTNAME""_""$LASTNAME"
                else
                    mv "${D}"/* "$FIRSTNAME""_""$LASTNAME"
                    rm -rf "${D}"
                fi
            fi
        done
    else
        info "--------------------------------------------------"
        for D in *; do
            if [ ! -d "${D}" ]; then
                LASTNAME=$(echo ${D} | cut -d' ' -s -f1)
                LASTNAME=$(echo $LASTNAME | rev | cut -d'-' -s -f1 | rev)
                
                FIRSTNAME=$(echo ${D} | cut -d' ' -s -f2)
                FIRSTNAME=$(echo $FIRSTNAME | cut -d'_' -s -f1)
                
                FILE=$(echo ${D} | rev | cut -d'_' -s -f1 | rev)
                
                debug "[NORMAL]: Original Name: ""${D}"
                debug "[NORMAL]: Student Name : ""$FIRSTNAME"" ""$LASTNAME"
                debug "[NORMAL]: File Name    : ""$FILE"
                
                if [ ! -d "$FIRSTNAME""_""$LASTNAME" ]; then
                    mkdir "$FIRSTNAME""_""$LASTNAME"
                fi
                info "Rename: Moving ""${D}"" to ""$FIRSTNAME""_""$LASTNAME""/"
                if [ -f "${D}" ]; then
                    mv "${D}" "$FIRSTNAME""_""$LASTNAME"/"$FILE"
                fi
            fi
        done
    fi
    debug "[NORMAL]: Deleting HTML files of size 76 (blank from Noodle)"
    find . -name '*.html' -size 76c -delete
    debug "--------------------------------------------------"
    
    cd "$EXEC_DIR"
    
}

report() {

    # DIR_NAME=$(echo $(pwd) | cut -d' ' -s -f1)
    DIR_NAME=$(echo $(pwd) | rev | cut -d'/' -s -f1 | rev)
    
    info "Running report for $DIR_NAME"
    
    if [ -f "Report.txt" ]; then
        debug "[NORMAL]: Removing previous report."
        rm -f "Report.txt"
    fi

    TabLines=0
    IncInden=0
    JvdMisng=0
    WtsMisng=0
    RetMisng=0
    ParMisng=0
    TrwMisng=0
    MgcNumbr=0
    TypWrong=0
    CstWrong=0
    MtdWrong=0
    PrmWrong=0
    LongLine=0
    uknownError=0

    for F in *; do
        debug "[NORMAL]: ${F}"
        if [[ "${F}" == "output_"*".txt" ]]; then
            FILE_NAME="${F}"
            FILE_NAME="${FILE_NAME##/*/}"
            debug "[NORMAL]: $FILE_NAME"
            printf "%s\n" "--------------------------------------------------" >> Report.txt
            printf "$FILE_NAME\n" >> Report.txt
            if [[ "$FILE_NAME" == "output_style.txt" ]]; then
                debug "Working in output_style parsing."
                #Saving IFS
                old=$IFS
                IFS=$'\n'
                for line in `cat $FILE_NAME`; do
                    if [[ "$line" == *".java"* ]] && [[ "$line" != *">>"* ]]; then
                        line=${line##*/}
                        
                        if [[ "$line" == *"tab"* ]];                    then let "TabLines += 1"
                        elif [[ "$line" == *"indentation"* ]];          then let "IncInden += 1"
                        elif [[ "$line" == *"@author"* ]];              then let "hasAuthorTag += 1"
                        elif [[ "$line" == *"Missing a Javadoc"* ]];    then let "JvdMisng += 1"
                        elif [[ "$line" == *"WhitespaceAround"* ]];     then let "WtsMisng += 1"
                        elif [[ "$line" == *"@return"* ]];              then let "RetMisng += 1"
                        elif [[ "$line" == *"@param"* ]];               then let "ParMisng += 1"
                        elif [[ "$line" == *"@throws"* ]];              then let "TrwMisng += 1"
                        elif [[ "$line" == *"magic"* ]];                then let "MgcNumbr += 1"
                        elif [[ "$line" == *"match pattern"* ]]; then
                            if [[ "$line" == *"Type"* ]];               then let "TypWrong += 1"
                            elif [[ "$line" == *"Constant"* ]];         then let "CstWrong += 1"
                            elif [[ "$line" == *"Method"* ]];           then let "MtdWrong += 1"
                            elif [[ "$line" == *"Parameter"* ]];        then let "PrmWrong += 1"; fi
                        elif [[ "$line" == *"longer than"* ]];          then let "LongLine += 1"
                        else
                            let "uknownError += 1"
                            #echo $line
                            printf "UNKNOWN STYLE ERROR:\n" >> Report.txt
                            printf "$line\n" >> Report.txt
                        fi
                    fi
                done
                IFS=$old
                
                echo "" >> Report.txt
                echo "CHECKSTYLE ERRORS: " >> Report.txt
                if (( hasAuthorTag != 0 )); then printf "File lacks an @author Tag.\n" >> Report.txt; fi
                
                echo "Lines with tab characters detected : $TabLines" >> Report.txt
                
                if (( TabLines != 0 )) && (( IncInden != 0 )); then
                    echo "Warning: Incorrect indentation could be due to tab characters."  >> Report.txt
                fi
                
                echo "Whitespace errors (operators/loops): $WtsMisng" >> Report.txt
                echo "Detected magic numbers             : $MgcNumbr" >> Report.txt
                echo "Number of lines longer than allowed: $LongLine" >> Report.txt
                echo "Number of types incorrectly named  : $TypWrong" >> Report.txt
                echo "       methods incorrectly named   : $CstWrong" >> Report.txt
                echo "       parameters incorrectly named: $MtdWrong" >> Report.txt
                echo "Number of unknown errors detected  : $uknownError" >> Report.txt
                
                echo "" >> Report.txt
                echo "JAVADOC ERRORS   : " >> Report.txt
                echo "Lines with missing Javadoc Comments: $JvdMisng" >> Report.txt
                echo "Missing/Incorrect @return tags     : $RetMisng" >> Report.txt
                echo "Missing/Incorrect @param tags      : $ParMisng" >> Report.txt
                echo "Missing/Incorrect @throws tags     : $TrwMisng" >> Report.txt
            
                #cat "$FILE_NAME" | grep $DIR >> Report.txt
            elif [[ "$FILE_NAME" == output*.txt ]]; then
                debug "[NORMAL]: Catting ""$FILE_NAME"" to Report."
                cat "$FILE_NAME" >> Report.txt
            fi
        fi
    done
    
    rm -f "output_"*".txt"

}

copyFile() {

    if [ $# -ne 2 ]; then
        error "copyFile: Not given expected arguments."
        return 31
    fi

    if [ ! -d $1 ]; then
        error "copyFile: Argument 1 is not a directory, or directory does not exist."
        return 32
    fi

    #Saving argument 1.
    DIRECTORY="$1"

    #Making sure argument 2 is a file.
    if [ ! -f $2 ]; then
        error "copyFile: Argument 2 is not a file, or does not exist."
        return 33
    fi
    
    cp "$2" "$DIRECTORY"

}

compileAndExecuteAndStyle() {

    # if [ "$CAP_FAST" == "y" ]; then
    # 
    # else
    # 
    # fi

    if [ "$CAP_FAST" == "y" ]; then
        if [ ! -f $COMP_FILENAME ]; then
            error "Fast: $COMP_FILENAME not found or could not be read."
            return 11
        fi

        if [ ! -f "$EXEC_FILENAME" ]; then
            error "Fast: "$EXEC_FILENAME" not found or could not be read."
            return 12
        fi
    fi

    #Check if file supplied by user exists AND is readable.
    #Note: change -r to -f if you only care that the file exists.
    #But reading is probably important.
    #Does -r imply -f?
    if [ ! -f $COMP_FILENAME ]; then
        error "$COMP_FILENAME not found or could not be read.""${PWD##*/}"
        return 13
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

    debug "[NORMAL]: --------------------------------------------------"

    #Compile the given file notice.
    debug "[NORMAL]: Attempting to compile $COMP_FILENAME"
    debug "[NORMAL]: Output and errors will be printed to $COMPILE_FILE and $COMPILE_ERROR_FILE"
    info "Compiling $COMP_FILENAME"

    #Compile the given file, output anything to these files.

    if [ "$CAP_FAST" == "y" ]; then
        javac $COMP_FILENAME > $FAST_FILE 2>> $FAST_FILE
    else
        javac $COMP_FILENAME > $COMPILE_FILE 2> $COMPILE_ERROR_FILE
    fi

    #Make sure we compiled and were able to output to files.
    if [ ! -f $COMPILE_FILE ]; then
        error "Could not create output file for compilation."
        return 14
    fi

    if [ ! -f $COMPILE_ERROR_FILE ]; then
        error "Could not create output file for compilation error."
        return 15
    fi

    #Check if there were compilation errors.
    if [ $(stat -c%s $COMPILE_ERROR_FILE) -gt 0 ]; then
        error "Compilation errors detected.  Errors may compound."
    fi

    debug "[NORMAL] Compilation complete."
    debug "--------------------------------------------------"

    #Literally only about GUIs.
    if [ "$NO_EXEC" = "n" ]; then

        # Replace .java with .class.
        EXEC_FILENAME="${COMP_FILENAME%.java}"

        if [ ! -f "$EXEC_FILENAME".class ]; then
            warning "Class not found, or readable.  Skipping execution."
            return 16
        else
            info "Executing ""$EXEC_FILENAME"
            debug "[NORMAL]: Output and errors will be printed to $EXECUTE_FILE and $EXECUTE_ERROR_FILE"
            #Execute the program to the output files.
            if [ "$HAVE_INPUT" = "true" ]; then
                read -t 1 -n 10000 discard
                if [ ${#ARGUMENT} -eq 0 ]; then
                    if [ "$CAP_FAST" == "y" ]; then
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" <$INPUT_FILE > $FAST_FILE 2>> $FAST_FILE
                    else
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" <$INPUT_FILE > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
                    fi
                else
                    if [ "$CAP_FAST" == "y" ]; then
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" $ARGUMENT <$INPUT_FILE > $FAST_FILE 2>> $FAST_FILE
                    else
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" $ARGUMENT <$INPUT_FILE > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
                    fi
                fi
            else
                if [ ${#ARGUMENT} -eq 0 ]; then
                    if [ "$CAP_FAST" == "y" ]; then
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" > $FAST_FILE 2>> $FAST_FILE
                    else
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
                    fi

                else
                    if [ "$CAP_FAST" == "y" ]; then
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" $ARGUMENT > $FAST_FILE 2>> $FAST_FILE
                    else
                        timeout $TIME_LIMIT java "$EXEC_FILENAME" $ARGUMENT > $EXECUTE_FILE 2> $EXECUTE_ERROR_FILE
                    fi

                fi
            fi
            if [ $? -eq 124 ]; then
                error "Error: Timeout Occured.  Infinite Loop/Break detected." >> $EXECUTE_ERROR_FILE
            fi
            # Do comparisons for errors during executions.
            # I think this might only happen if you have errors during compilation.
            if [ "$CAP_FAST" != "y" ] && [ $(stat -c%s $EXECUTE_ERROR_FILE) -gt 0 ]; then
                error "Execution errors detected."
            fi

            # info "Execution complete."
        fi
        if [ $HAVE_OUTPUT = "true" ]; then
            info "Doing output comparison."

            # TODO: Clean this up or remove it.  I'm not happy with it and I'm not sure it ever actually worked.
            
            # if [ "$CAP_FAST" == "y" ]; then
            #     diff -y $EXPECTED_FILE $EXECUTE_FILE >> $FAST_FILE
            # else
            #     info "Lack of pipe character indicates lines are equal."
            #     info "Expected file                                 | User Output File"
            # 
            #     #Using -y because that makes two columns for viewing - easier to read.
            #     # tee -a "$LOG_FILE" >&2
            #     diff -y -W100 $EXPECTED_FILE $EXECUTE_FILE
            #     diff -y -W100 $EXPECTED_FILE $EXECUTE_FILE >> "$LOG_FILE"
            # fi
            # 
            # info "--------------------------------------------------"
        fi
    fi

    if [ "$CAP_FAST" != "y" ] && [ "$CHECK" == "y" ]; then
        info "Executing Automated Style Checker"
        debug "[NORMAL]:    This program assumes your style checker exists in ~/cs/."

        if [ ! -d ~/cs/ ]; then
            error "Could not find checkstyle in ~/cs/.  Please install Checkstyle to ~/cs/"
        else
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
    fi

}

#####################################################################
#                                                                   #
#     Privacy divider.  Please respect the privacy of the code.     #
#                                                                   #
#####################################################################

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

# Saving wherever we started; Needed because half this script works on relative position
EXEC_DIR=$(pwd)

DEBUG="false"

if [ $# -eq 0 ]; then
    echo "You must specify a dialog type. Use '-h' or '--help' for details"
    exit 0
fi

if [ $1 == "-h" ] || [ $1 == "--help" ]; then
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
  -c, --copy-file               File to copy into each directory.
  -ncs, --no-check              Do not run the checkstyle program.
"
    exit 0
fi

CAP_FAST="n"
NO_EXEC="n"
CHECK="y"
COPY_FILE=""

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
        -c) COPY_FILE="$2"; shift 2;;
        -q) CAP_FAST="y"; shift 1;;
        -f) CAP_FAST="y"; shift 1;;
        -n) NO_EXEC="y"; shift 1;;
        -ncs) CHECK="n"; shift 1;;

        --program=*) COMP_FILENAME="${1#*=}"; shift 1;;
        --dir=*) DIRECTORY="${1#*=}"; shift 1;;
        --expected=*) EXPECTED_FILE="${1#*=}"; shift 1;;
        --input=*) INPUT_FILE="${1#*=}"; shift 1;;
        --argument=*) ARGUMENT="${1#*=}"; shift 1;;
        --time-limit=*) TIME_LIMIT="${1#*=}"; shift 1;;
        --copy-file=*) COPY_FILE="${1#*=}"; shift 1;;
        --quick*) CAP_FAST="y"; shift 1;;
        --fast*) CAP_FAST="y"; shift 1;;
        --no-execute*) NO_EXEC="y"; shift 1;;
        --no-check*) CHECK="n"; shift 1;;
        --program|--dir|--expected|--input) echo "$1 requires an argument" >&2; exit 1;;

        -*) echo "unknown option: $1" >&2; exit 1;;
        *) echo "unrecognized argument: $1"; exit 0
    esac
done

#Check if size of java file is 0
if [ "${#COMP_FILENAME}" == 0 ]; then
    error "Lacking Java File Argument."
    error "Exiting program with status 0."
    exit 0
else
    #Making sure Argument 1 is a java file.  Or has a java extension at least.
    if  [[ "$COMP_FILENAME" != *.java ]]; then
        error "Java file argument lacks java extension."
        error "Exiting program with status 0."
        exit 0
    fi
fi

if [ "${#DIRECTORY}" == 0 ]; then
    error "Lacking Directory Argument."
    error "Exiting program with status 0."
    exit 0
else
    #Making sure argument 2 is a directory.
    if [ ! -d "$DIRECTORY" ]; then
        error "Argument 2 is not a directory."
        error "Exiting program with status 0."
        exit 0
    fi
fi

if [ "$TIME_LIMIT" -le "0" ]; then
    error "Timeout limit provided 0, less than 0, or non-integer."
    info "Setting Timeout limit to default 15."
    TIME_LIMIT=15
fi

HAVE_OUTPUT=false
HAVE_INPUT=false

if [ "${#EXPECTED_FILE}" != 0 ]; then
    EXPECTED_FILE="$EXEC_DIR"/$EXPECTED_FILE
    if [ ! -r $EXPECTED_FILE ]; then
        error "Expected output file does not exist."
        error "Exiting program with status 0."
        exit 0
    else
        HAVE_OUTPUT=true
    fi

    #We can only have an input file if we have an output file.
    if [ "${#INPUT_FILE}" != 0 ]; then
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

rename "$DIRECTORY"

#Change directory to the directory of many folders.
#Life has many directories edboy
#Note to future self: this has to be last, because of file checks.
cd "$DIRECTORY"

FILE_COUNT="$(ls -1 "$EXEC_DIR"/$DIRECTORY | wc -l)"

#echo $FILE_COUNT

if [ "$FILE_COUNT" -eq "1" ]; then
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

#The working loop.  Loops through each directory in the supplied directory,
#And runs the compilation function on it, with the filename argument.
for d in *; do
    #check if * is a directory, not a file
    if [ -d "${d}" ]; then
        cd "${d}"
        info "Current working directory: ${d}"
        if [ -r "$COMP_FILENAME" ]; then
            #clear
            if [[ "$COPY_FILE" != "" ]]; then
                copyFile ./ "$EXEC_DIR"/"$COPY_FILE"
            fi
            compileAndExecuteAndStyle
            report ./
        else
            error "File ""$COMP_FILENAME"" does not exist"
        fi
        cd ..
        info "--------------------------------------------------"
    fi
done

cd "$EXEC_DIR"

exit 0
