import java.io.*;
import java.nio.file.*;

/**
 * Rename the moodle downloaded files to their original filenames
 *
 * @author Zach Butler zcbutler@ncsu.edu
 * @author Jessica Young Schmidt - updated to include command line argument for
 *         the directory name
 * @precondition Java 1.8 or greater is installed
 */
public class RenameScript {
    /** Name of directory containing student submissions */
    public static String directory;

    /**
     * Run the script to rename the files Make sure the unzipped submissions
     * folder from moodle is named based on the first command line argument and
     * is at the same level as this file
     *
     * @param args command line argument - single argument for directory name
     */
    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Usuage: java RenameScript directory_name");
            System.exit(1);
        }
        directory = args[0];

        File folder = new File(directory);
        File[] allFiles = folder.listFiles();
        for (File f : allFiles) {
            String moodleFileName = f.getName();
            String studentName = moodleFileName.substring(0,
                    moodleFileName.indexOf("_")).replaceAll(" ", "_");
            String actualFileName = moodleFileName.substring(moodleFileName
                    .indexOf("_file_") + 6);
            File studentFolder = new File(directory + "/" + studentName);
            if (!studentFolder.exists()) {
                studentFolder.mkdir();
            }
            if (renameFile(f, studentName, actualFileName)) {
                System.out.printf("Renamed %s to %s\n", moodleFileName,
                        actualFileName);
            } else {
                System.out.printf("FAILED to rename %s to %s\n",
                        moodleFileName, actualFileName);
            }
        }
    }

    /**
     * Renames the file while updating directory structure
     * 
     * @param f current filename
     * @param heirarchy name of directory to place file in (should be student's
     *            name)
     * @param newName new name of file
     * @return whether rename was successful
     */
    private static boolean renameFile(File f, String heirarchy, String newName) {
        if (f.renameTo(new File(directory + "/" + heirarchy + "/" + newName))) {
            return true;
        } else {
            try {
                Files.move(Paths.get(directory + "/" + f.getName()),
                        Paths.get(directory + "/" + heirarchy + "/" + newName));
                return true;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
    }
}
