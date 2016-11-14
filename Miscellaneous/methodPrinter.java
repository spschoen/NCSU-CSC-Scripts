import java.util.*;
import java.io.*;

/**
 * The programming equivalent of a lazy sunday.
 * Provide CLI of a file to scan, and then give it a method name to search for
 * and this program will print out the entire method.  It's stupid, but it works.
 * It's best used with directoryOrder.sh
 * @author Samuel Schoeneberger
 */
public class methodPrinter {
	
	/**
	 * It starts the program.
	 * @param args CLI arguments, should be 1 in length, the file to scan.
	 */
	public static void main(String[] args) {
	
		if ( args.length != 1 ) {
			System.out.println("rip1");
			System.exit(1);
		}
	
		Scanner in = new Scanner(System.in);
		System.out.print("Method name: ");
		String methodName = in.next();
		System.out.println();
		
		String dir = args[0];
		File f = new File(dir);
		if ( !f.exists() ) {
			System.out.println("rip2");
			System.exit(1);
		}
		
		Scanner fi = null;
		try {
			fi = new Scanner(f);
		} catch (Exception e) {
			System.out.println("rip3");
			System.exit(1);
		}
		
		int bracketCount = 1;
		boolean gottem = false;
		while ( fi.hasNextLine() ) {
			String s = fi.nextLine();
			if ( ( s.contains("public") || s.contains("private") || s.contains("protected") )
					&& s.contains(methodName) ) {
				while ( !s.contains("{") ) {
					System.out.println(s);
					s = fi.nextLine();
				}
				gottem = true;
			}
			
			if ( gottem ) {
				System.out.println(s);
				if (s.contains("{")) {
					bracketCount++;
				}
				if (s.contains("}")) {
					bracketCount--;
				}
			}
			if ( bracketCount == 1 && gottem ) {
				break;
			}
		}
	
	}
	
}
