# Miscellaneous Scripts
Scripts here are miscellaneous scripts, with minor use or specialized use.

Index:
* copyfile.sh
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Bash / Shell
  * Functional.
  * Will take directory of directories to distribute a file to.
  * Execution: sh copyFile Directory/ File

* directoryOrder.sh
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Bash / Shell
  * Functional.
  * Requires user editing to function.  Next level laziness.
  * It's a shell of a program, that loops through directories in a directory argument.
  * Execution: sh directoryOrder.sh Directory/

* easyTar.sh
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Bash
  * Functional.
  * It's Zip/Unzip, but tar.  Because, who doesn't want to use tar, but doesn't know how to use tar?
  * Execution: sh easyTar.sh archive.tar/archive.gz directory-to-archive-or-unarchive-to/

* methodPrinter.java
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Java
  * Functional.
  * Will read through a file, and print a method.  Specifically a Java file.
  * Best used with directoryOrder.sh
    * Execution for directoryOrder.sh use: java -classpath $myDir methodPrinter $myDir/$1"${d}"/"FileToScan.extension"
  * Execution: java methodPrinter FileToScan.extension
