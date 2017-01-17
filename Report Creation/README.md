# Report Creation Scripts
These scripts will read other files and make human readable/moodle accepting files of them, for quicker grading.

Index:
* GenerateReports.java
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Java
  * Semi functional - reads output_style.txt and creates a human-readable version.
  * Planned: Reads files from CompileAndExecuteScript.sh and creates user readable files.
    * Sort of.
  * Execution: java GenerateReports.java [Folder of Folders of Java File]
* GenerateReport.java
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Java
  * Creates a human readable version of output files from CompileAndExecute.sh, Report.txt
  * Execution: java GenerateReports.java [Student Submission folder containing output_*.txt files]
* checkstyletohtmlpdf.sh
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Bash / Shell
  * Functional - creates HTML and PDF outputs of stylechecker.  Makes it human readable.
  * REQUIREMENTS:
    * XML_CSS.xsl (same directory)
    * wkhtmltopdf (http://wkhtmltopdf.org/) (in home directory)
  * Assuming you lack wkhtmltopdf, the HTML might still be created.  I haven't tested.
* XML_CSS
  * Not a script, just a required file for checkstyletohtmlpdf to work.
