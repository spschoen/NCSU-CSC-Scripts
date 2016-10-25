#####################################################################
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
#                                                                   #
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
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Expected file/directory structure (after script):                 #
#                                                                   #
#####################################################################

#####################################################################
#                                                                   #
# Changelog                                                         #
#   v0   - 16/10/20 - Initial version.                              #
#                                                                   #
#####################################################################

#!/bin/bash/

#Cleaning everything up.
clear

#Quick sleep just because.
sleep 0.25

#Saving wherever we started
myDir=$(pwd)

#Don't forget to change directory to wherever we are.
cd "$(dirname "$0")"

# This code has been taken from Tyler Bletsch's checkstyle script,
# all credit goes to him for all code from this point until the next noted point.

# Detect the path where this script was called from -- this should be inside a checkstyle install directory.
#CHECKSTYLE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CHECKSTYLE_PATH=~/cs/

# Path to the checkstyle configuration file to use.
CONFIG_FILE=$CHECKSTYLE_PATH/csc116_checks.xml

# Path to the "-all" jar file -- you shouldn't need to mess with this unless changing checkstyle versions.
CHECKSTYLE_JAR=$CHECKSTYLE_PATH/checkstyle-6.1.1-all.jar

# The class to execute -- this shouldn't change
CHECKSTYLE_CLASS=com.puppycrawl.tools.checkstyle.Main

# Samuel comment - it's almost as bad as grep ;-;
INDENT_LEVEL=`perl -e '$/=undef; $_=<>; s#/\s*\*.*?\*\s*/##gs; s#.*?\{##s; /^( +)\w/m and print(length($1)) or print(0);' "$1"`
# ^ This incantation detects the indent level by counting the spaces after the first open brace, returning 0 if none are found.
#  Breakdown:
#    $/=undef; $_=<>;   -- slurp the whole file into the perl default variable $_
#    s#/\s*\*.*?\*\s*/##gs; -- Remove all multi-line comments, in case they're weird
#    s#.*?\{##s;        -- Remove everything up to the first brace
#    /^( +)\w/m         -- Match the first line's worth of whitespace that starts with non-punctuation
#    and ... or ...     -- short-circuit based logic to print the space count if the regex worked, or zero if it didn't

if   [[ $INDENT_LEVEL == 2 || $INDENT_LEVEL == 3 || $INDENT_LEVEL == 4 ]] ; then
    echo ">> Detected an indent level of $INDENT_LEVEL based on $1."
	echo "(If this isn't right, you'll get spurious indent errors below.)"
else
    echo ">> Invalid indent level detected in $1 ($INDENT_LEVEL), defaulting to 4."
	echo "(If this isn't right, you'll get spurious indent errors below.)"
    INDENT_LEVEL=4
fi
echo ""

# So here is my code - seems little, does a lot.  A lot of a lot.  Instead of outputting to txt, and being unreadable,
# this outputs to xml, which is actually pretty readable already.  And in theory, we could provide xml css for students
# and host these xml files where only they could access them, and we can call it a day.  However, we won't.
java -classpath $CHECKSTYLE_JAR -Dindent_level=$INDENT_LEVEL $CHECKSTYLE_CLASS -f xml -o output.xml -c $CONFIG_FILE "$@"

# Now we get funky.  We take the output.xml file, use XML_CSS.xsl to convert it to html, then output to output.html.
xsltproc -o style.html XML_CSS.xsl output.xml

# And we use a third party 

if [ ! -d ~/wkhtmltox/ ]; then
    echo "ERR: wkhtmltox converter does not exist in ~/"
    echo "Please install wkhtmltox in ~/ for PDF output."
    echo "HTML and XML output is still created."
else
    ~/wkhtmltox/bin/wkhtmltopdf style.html style.pdf
fi



exit 0 
