#####################################################################
#                                                                   #
# TODO: Documentation                                               #
#                                                                   #
#####################################################################

#!/bin/bash

#Saving wherever we started
EXEC_DIR=$(pwd)

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

#Check if user supplied arguments
if [ $# -ne 1 ]; then
    echo "ERR: Number of given arguments incorrect."
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

for d in *; do
    if [ -d "${d}" ]; then
        echo "--------------------------------------------------"
        cd "${d}"
        DIR="${d}"
        DIR="${DIR##/*/}"
        echo "Directory: $DIR"
        #COMMANDS GO HERE
        
        if [ -f "Report.txt" ]; then
            echo "Removing Report.txt"
            rm -f "Report.txt"
        fi
        
        echo "Generating Report."

        for F in *; do
            FILE_NAME=${F}
            FILE_NAME="${FILE_NAME##/*/}"
            if [[ "$FILE_NAME" == *.txt ]]; then
                printf "%s\n" "--------------------------------------------------" >> Report.txt
                printf "$FILE_NAME\n" >> Report.txt
            fi
            
            if [[ "$FILE_NAME" == "output_style.txt" ]]; then
                #Saving IFS
                old=$IFS
                IFS=$'\n'
                for line in `cat $FILE_NAME`; do
                    if [[ "$line" == *$DIR* ]]; then
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
                cat "$FILE_NAME" >> Report.txt
            fi
        done
        printf "%s\n" "--------------------------------------------------" >> Report.txt

        #COMMANDS STOP HERE
        cd ..
    fi
done

echo "--------------------------------------------------"
