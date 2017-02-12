# Renaming Scripts
These scripts exist to change filenames from Moodle's love for junk characters and put them in proper directories with their actual Java file names.

Index:
* Rename.py
  * Written by Dr. Jason King (jtking@ncsu.edu)
  * Python
  * Converts from Moodle format to Wolfware Classic, OR converts from Wolfware Classic to Moodle format
  * Convert from Wolfware Classic to Moodle format:
     * Download .zip of all Moodle submissions (not in individual directories) 
	 * Unzip it
	 * Edit Rename.py to update the path to the unzipped file contents
	 * Edit Rename.py to update the path to the Feedback Files (which are in Wolfware Classic format)
	 * Create your mapping file (CSV file with: unityID, lastName, firstName)
	 * Run the script.
  * Execution:
    * python Rename.py
* RenameScript.java
  * Written by Dr. Jessica Schmidt (jessica_schmidt@ncsu.edu)
  * Java
  * Creates directory for each student submission, and moves files inside. Folder names are LastName_FirstName.
  * Execution:
    * java RenameScript [Folder of submissions from Moodle to be renamed]
* FirstLastToUnity.java
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Java
  * Converts Dr. Jessica Schmidt's renaming script from LastName_FirstName to unityID.
  * REQUIREMENTS:
    * Mapping file (csv is easiest to create, any will do if it follows described structure) in same directory as FirstLastToUnity.java
  * Execution:
    * java RenameScript [Folder of submissions from Moodle to be renamed]
* Mapping.txt
  * Written by Samuel Schoeneberger (spschoen@ncsu.edu)
  * Text
  * Example file for FirstLastToUnity.java
  * Contains basic structure of how FirstLastToUnity expects its mapping file to look.
