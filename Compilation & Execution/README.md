
# Compilation and Execution Script
This script is the largest and most unwieldy.  It does everything short of delivering grades.  Sadly, I'm not as good as Dr. Lasher - yet.

* Written by Samuel Schoeneberger (spschoen@ncsu.edu)
* Bash / Shell
* Compiles/Executes, Runs style checker (assumes presence of style checker in ~/cs/)
* (Optional) Compares program output to expected output.  Uses input files given by user.
* REQUIREMENTS (details where to download these files relative to actual script in file):
  * RenameScript.java - Has to have been run or at least downloaded.
  * GenerateReport.java - Summarizes output into easier to read files.

Execution of script:
  * sh CompileAndExecuteScript -h for help
  * sh CompileAndExecuteScript -d Directory/ -p Program_Name.java
  * sh CompileAndExecuteScript -d Directory/ -p Program_Name.java -e expected_output.txt
  * sh CompileAndExecuteScript -d Directory/ -p Program_Name.java -e expected_output.txt -i input.txt
  * And more, please view the help output

