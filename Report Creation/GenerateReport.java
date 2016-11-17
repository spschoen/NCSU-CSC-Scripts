import java.util.*;
import java.io.*;
import java.nio.file.*;

/**
 * GenerateReport, will read through files created from saving stylechcker and create a user
 * readable version.  Does not print the lines of the error - will refactor code to do that.
 * Similar to GenerateReports, however, this will only generate a single report, for a single
 * student submission.
 * @author Samuel Schoeneberger
 */
public class GenerateReport {

    /** number of text files to be read, generated by CompileAndExecuteScript.sh */
    public static final int READ_TEXT_FILES = 6;
    
    /** String printed out that is always at the end of usable data from file. */
    public static final CharSequence AUDIT_COMPLETE = "Audit done.";
    
    /** Tells us indent level, to skip over more importantly. */
    public static final CharSequence INDENT_LEVEL = "indent level";
    
    /** Same as above; sequence to skip. */
    public static final CharSequence INDENT_LEVEL_TWO = "(If this isn't";
    
    /** Checking for another line to skip. */
    public static final CharSequence DOING_STYLE = "** Doing style";
    
    /** Last to skip - from this point forwar, we care about input. */
    public static final CharSequence STARTING_AUDIT = "Starting audit...";
    
    public static final int AFS_START_SUBSTRING_LENGTH = 28;
    
    /**
     * Main method.  Program execution and all that.
     * Checks if we have the right number of arguments (1), then checks through the
     * first argument for a folder of folder of output files to generate reports.
     * @param args command line arguments
     */
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.out.println("Usage: java GenerateReports directory_name");
            System.exit(1);
        }
        
        File folder = new File(args[0]);
        if ( !folder.isDirectory() ) {
            System.out.println("Error: supplied directory not a directory.");
            System.exit(1);
        }
        
        //Files in directory to be read.
        File[] files = new File[READ_TEXT_FILES];
        
        //Get files from each directory - the output.*.txt files specifically
        files = folder.listFiles(new FilenameFilter(){
            @Override
            public boolean accept(File directory, String fileName) {
                return fileName.startsWith("output") && fileName.endsWith(".txt");
            }
        } );
        
        FileWriter writer = null;
        Scanner reader = null;
            
        String reportFile = "Report.txt";
        File report = new File(folder, reportFile);
        
        //System.out.println(report.getPath());
        
        // Making sure that report doesn't already exist.
        if ( report.exists() ) {
            report.delete();
        }
        
        boolean outputCompileEmpty = false;
        
        for ( int i = 0; i < files.length; i++ ) {
            
            // Making sure we can create that report file.
            try {
                report.createNewFile();
            } catch ( Exception e ) {
                System.out.print("ERROR in creating report file: ");
                System.out.println(e.getMessage());
                System.exit(1);
            }
            
            // Setting up our reader/writer combo.
            try {
                writer = new FileWriter(report, true);
                reader = new Scanner(files[i]);
            } catch ( Exception e ) {
                System.out.print("ERROR in creating writer/reader combo: ");
                System.out.println(e.getMessage());
                System.exit(1);
            }
            
            if ( i == 4 ) {
                //System.out.println("Style file");
                styleReport(files[i], reader, writer);
                writer.write("--------------------------------------------------\n");
                writer.flush();
                continue;
            }
            
            //System.out.println(reader.nextLine());
            if ( !reader.hasNextLine() ) {
                if ( i == 0 ) {
                    outputCompileEmpty = true;
                    continue;
                }
                if ( i == 1 && outputCompileEmpty ) {
                    writer.write("No errors in compilation.\n");
                    writer.write("--------------------------------------------------\n");
                    writer.flush();
                    continue;
                }
                if ( i == 3 ) {
                    writer.write("No errors in execution.\n");
                    writer.write("--------------------------------------------------\n");
                    writer.flush();
                    continue;
                }
                if ( i == 5 ) {
                    writer.write("No errors in style checking.\n");
                    writer.write("--------------------------------------------------\n");
                    continue;
                }
            } else {
                if ( i == 2 ) {
                    writer.write("Submission output: \n");
                    writer.write("--------------------------------------------------\n");
                }
                while ( reader.hasNextLine() ) {
                    writer.write(reader.nextLine() + "\n");
                }
            }
            
            writer.write("--------------------------------------------------\n");
            writer.flush();
            
        }
    
    }

    public static void styleReport( File f, Scanner reader, FileWriter writer ) throws IOException {
        String javaFileName = "";
        int numTabLines = 0;
        int numIncInden = 0;
        int numJvdMisng = 0;
        int numWtsMisng = 0;
        int numRetMisng = 0;
        int numParMisng = 0;
		int numTrwMisng = 0;
        int numMgcNumbr = 0;
        int numTypWrong = 0;
        int numCstWrong = 0;
        int numMtdWrong = 0;
        int numPrmWrong = 0;
        int numLongLine = 0;
		int uknownError = 0;
        
        boolean hasAuthorTag = true;
        
        while ( reader.hasNextLine() ) {
            String line = reader.nextLine();
            
            // If the audit is complete.
            if ( line.contains(AUDIT_COMPLETE) ) {
                break;
            }
            
            if (line.contains(INDENT_LEVEL) || 
                line.contains(INDENT_LEVEL_TWO) || 
                line.contains(DOING_STYLE) || 
                line.contains(STARTING_AUDIT) ||
                line.equals("")) {
                
                continue;
                
            }
            
            //Removing a few things:
            
            // /afs/unity.ncsu.edu/users/* /
            line = line.substring(AFS_START_SUBSTRING_LENGTH);
            
            // unityid/folders/.../StudentLastName_
            line = line.substring(line.indexOf("_") + 1);
            
            // StudentFirstName/
            line = line.substring(line.indexOf("/") + 1);
            //System.out.println(line);
            
            //Final output: Program.java:##: Style Error
            
            javaFileName = line.substring(0, line.indexOf("."));
            
            // Check if a tab character was detected.
            if (line.contains("tab")) {
                numTabLines++;
            } else if ( line.contains("incorrect indentation") ) {
                numIncInden++;
            } else if ( line.contains("@author") ) {
                hasAuthorTag = false;
            } else if ( line.contains("Missing a Javadoc") ) {
                numJvdMisng++;
            } else if ( line.contains("WhitespaceAround:") ) {
                numWtsMisng++;
            } else if ( line.contains("@return") ) {
                numRetMisng++;
            } else if ( line.contains("@param") ) {
                numParMisng++;
            } else if ( line.contains("@throws") ) {
                numTrwMisng++;
            } else if ( line.contains("magic") ) {
                numMgcNumbr++;
            } else if ( line.contains("match pattern") ) {
                if ( line.contains("Type name") ) {
                    numTypWrong++;
                }
                if ( line.contains("Constant name") ) {
                    numCstWrong++;
                }
                if ( line.contains("Method name") ) {
                    numMtdWrong++;
                }
                if ( line.contains("Parameter name") ) {
                    numPrmWrong++;
                }
                
            } else if ( line.contains("longer than") ) {
				numLongLine++;
			} else {
				uknownError++;
				writer.write("UNKNOWN STYLE ERROR:\n");
				writer.write(line + "\n");
			}
            
        }
        
        writer.write("Style Report for " + javaFileName + "\n");
        
        if ( !hasAuthorTag ) {
            writer.write("File lacks an @author Tag.\n");
        }
        
        String outputLine = "Lines with tab characters detected : ";
        outputLine += numTabLines + "\n";
        writer.write(outputLine);
        
        outputLine = "Lines with incorrect indentation   : ";
        outputLine += numIncInden + "\n";
        writer.write(outputLine);
        
        if ( numTabLines != 0 && numIncInden != 0 ) {
            writer.write("Warning: Incorrect indentation could be due to tab characters.\n");
        }
        
        outputLine = "Whitespace errors (operators/loops): ";
        outputLine += numWtsMisng + "\n";
        writer.write(outputLine);
        
        outputLine = "Detected magic numbers             : ";
        outputLine += numMgcNumbr + "\n";
        writer.write(outputLine);
        
        outputLine = "Number of lines longer than allowed: ";
        outputLine += numLongLine + "\n";
        writer.write(outputLine);
        
        outputLine = "Number of types incorrectly named  : ";
        outputLine += numTypWrong + "\n";
        writer.write(outputLine);
        
        outputLine = "       constants incorrectly named : ";
        outputLine += numCstWrong + "\n";
        writer.write(outputLine);
        
        outputLine = "       methods incorrectly named   : ";
        outputLine += numMtdWrong + "\n";
        writer.write(outputLine);
        
        outputLine = "       parameters incorrectly named: ";
        outputLine += numPrmWrong + "\n";
        writer.write(outputLine);
        
        outputLine = "Number of unknown errors detected  : ";
        outputLine += uknownError + "\n";
        writer.write(outputLine);
		
		writer.write("--------------------------------------------------\n");
        writer.write("Javadoc Report for " + javaFileName + "\n");
		
        outputLine = "Lines with missing Javadoc Comments: ";
        outputLine += numJvdMisng + "\n";
        writer.write(outputLine);
        
        outputLine = "Missing/Incorrect @return tags     : ";
        outputLine += numRetMisng + "\n";
        writer.write(outputLine);
        
        outputLine = "Missing/Incorrect @param tags      : ";
        outputLine += numParMisng + "\n";
        writer.write(outputLine);
        
        outputLine = "Missing/Incorrect @throws tags     : ";
        outputLine += numTrwMisng + "\n";
        writer.write(outputLine);
        
        writer.flush();
    }
    
}
