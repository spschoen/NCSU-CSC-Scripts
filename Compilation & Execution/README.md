
# Compilation and Execution Script
This script is the largest and most unwieldy.  It does everything short of delivering grades.  Sadly, I'm not as good as Dr. Lasher - yet.

( Script grading planned for Fall 2017 )

* Written by Samuel Schoeneberger (spschoen@ncsu.edu)
* Bash / Shell
* Compiles/Executes, Runs style checker (assumes presence of style checker in ~/cs/)
* (Optional) Compares program output to expected output.  Uses input files given by user.
* Optional File - GenerateReport.sh - Summarizes output into easier to read files.  Found in Report Generation

Execution of script:
  * sh CompileAndExecuteScript -h for help
  * sh CompileAndExecuteScript -d Directory/ -p Program_Name.java
  * sh CompileAndExecuteScript -d Directory/ -p Program_Name.java -e expected_output.txt
  * sh CompileAndExecuteScript -d Directory/ -p Program_Name.java -e expected_output.txt -i input.txt
  * And more, please view the help output

