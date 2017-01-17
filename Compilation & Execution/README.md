# Compilation and Execution Scripts
These scripts are usually the largest and most unwieldy - they are guaranteed to compile and execute programs, but can do more.

Index:
* CompileAndExecuteScript.sh
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Bash / Shell
  * Compiles/Executes, Runs style checker (assumes presence of style checker in ~/cs/)
  * (Optional) Uses input files given by user.
  * (Optional) Compares program output to expected output.
  * REQUIREMENTS (details where to download these files relative to actual script in file):
    * RenameScript.java, created by Dr. Jessica Schmidt and Zach Butler
    * GenerateReport.java, created by Samuel Schoeneberger.
  * Execution of script:
    * sh CompileAndExecuteScript [Java File] [Folder of student submission folders/Assignments to be renamed] [y/n whether or not to run RenameScript.java]
    * sh CompileAndExecuteScript [Java File] [Folder of student submission folders/Assignments to be renamed] [y/n whether or not to run RenameScript.java] [expected output file]
    * sh CompileAndExecuteScript [Java File] [Folder of student submission folders/Assignments to be renamed] [y/n whether or not to run RenameScript.java] [expected output file] [user input file]
