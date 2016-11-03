# Renaming Scripts
These scripts exist to change filenames from Moodle's love for junk characters and put them in proper directories with their actual Java file names.

Index:
* Rename.py
  * Written by Dr. Jason King (jtking@ncsu.edu)
  * Python
  * Creates a folder for each student's submission, and names it their UnityID.
  * Dr. King, please fill this out greater if you feel the need.
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
