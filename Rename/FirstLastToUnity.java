import java.util.*;
import java.io.*;

/**
 * Another rename script - this time, it takes folders renamed by Dr. Schmidt's program
 * and converst them to unityID named directories.
 */
public class FirstLastToUnity {

    // Largest java class I've seen.
    public static final int LARGEST_CLASS = 35;

    public static void main(String[] args) {
    
        if ( args.length != 2 ) {
        
            System.out.println("Expected execution: java FirstLastToUnity mapping.txt Directory/");
            System.exit(1);
        
        }
        
        File folder = new File(args[1]);
        
        if ( !folder.isDirectory() ) {
            System.out.println("Error: supplied directory not a directory.");
            System.exit(1);
        }
        
        //Folders inside the directory
        File[] folders = folder.listFiles();
        
        Scanner names = null;
        
        try {
            names = new Scanner(new File(args[0]));
        } catch (Exception e) {
            System.out.println(e.getMessage());
            System.exit(1);
        }
        
        if ( names == null ) {
            System.out.println("File does not exist, exitting.");
            System.exit(1);
        }
        
        Student[] initStudents = new Student[LARGEST_CLASS];
        int index = 0;
        
        while ( names.hasNextLine() ) {
        
            String line = names.nextLine();
            if (line.equals("")) { // 
               break;
            }
            String[] parts = line.split(",");
            //System.out.println(line);
            initStudents[index] = new Student(parts[0],parts[1],parts[2]);
            index++;
        
        }
        
        Student[] students = new Student[index];
        
        for ( int i = 0; i < index; i++ ) {
            students[i] = initStudents[i];
        }
        
        /*if ( students.length != folders.length ) {
            System.out.println("Something broke; number of folders does not match " + 
                "number of mapped students; probably fewer folders.");
            
        }*/
        
        //Never use initStudents beyond this point - contains null values we don't handle.
        
        for ( Student s : students ) {
            findDirectory(folders, s, folder);
        }
    
    }
    
    public static void findDirectory(File[] folders, Student s, File folder) {
    
        for ( File f : folders ) {
            String baseName = f.getName().substring(f.getName().indexOf("grading")+1);
            //System.out.println(baseName + " " + s.Last_FirstDirectory());
            //System.out.println(baseName.equals(s.Last_FirstDirectory()));
            
            if ( baseName.equals(s.unityDirectory()) ) {
                return;
            }
            
            
            if ( baseName.equals(s.Last_FirstDirectory()) ) {
                System.out.println("Found directory for " + s.getName());
                f.renameTo(new File(folder, s.unityDirectory()));
                return;
            }
        }
    
        /*for ( int i = 0; i < folders.length; i++ ) {
            if ( folders[i].getName().equals(s.Last_FirstDirectory()) ) {
                System.out.println("Found directory for " + s.getName());
                folders[i].renameTo(new File(folder, s.unityDirectory()));
                return;
            }
        }*/
        System.out.println("Could not find directory for " + s.getName());
        
        
    }
    
    private static class Student {
    
        private String firstName;
        private String lastName;
        private String email;
        private String unityID;
        
        public Student(String firstName, String lastName, String email) {
        
            this.lastName = lastName;
            this.firstName = firstName;
            this.email = email;
            
            int atIndex = email.indexOf("@");
            this.unityID = email.substring(0, atIndex);
        
        }
        
        public String toString() {
        
            String s = "";
            s += firstName + " ";
            s += lastName + " ";
            s += email + " ";
            s += unityID;
            return s;
        
        }
        
        public String getName() {
            return firstName + " " + lastName;
        }
        
        public String Last_FirstDirectory() {
            return lastName + "_" + firstName;
        }
        
        public String unityDirectory() {
            return unityID;
        }
    
    }

}
