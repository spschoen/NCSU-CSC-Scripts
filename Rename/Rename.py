#! /usr/bin/python
import os
import sys
import csv

SUBMISSION_DIRECTORY = "C:\Users\Adminuser\Documents\CSC116\P2\CSC 116 (007) Spring 2017-Project 1 Submit (stage-1)-433410\\"

PDF_DIRECTORY = "C:\\Users\\Adminuser\\Documents\\CSC116\\P2\\FeedbackFiles\\"

def open_file(mapFile):
  mappings = dict()

  with open(mapFile, 'r') as csvfile:
    fieldnames = ['unityID', 'last_name','first_name']
    reader = csv.DictReader(csvfile, fieldnames=fieldnames)
    for row in reader:
      print( row['unityID'], row['first_name'], row['last_name'] )
      mappings.update({ row['unityID'] : row['first_name'] + ' ' + row['last_name'] })
  return mappings

def get_student_name(fileName):
  name = fileName[:fileName.find("_")]
  return name

def main(argv):

  rename_to_moodle_structure()

  #rename_to_classic_structure()

def rename_to_moodle_structure():
  submitFiles = os.listdir(SUBMISSION_DIRECTORY)
  mappings = open_file("007-studentMapping.csv");
  
  for f in submitFiles:
    print f
    prefix = f[:f.find("assignsubmission"):]
    numberSuffix = f[f.find("_")+1:f.rfind("_")-1:]
    participantID = numberSuffix[:numberSuffix.find("_"):]
    studentName = f[:f.find("_"):]
    print prefix
    print studentName
    print participantID

    for key, value in mappings.iteritems():
      first = value[:value.find(" ")]
      last = value[value.find(" ")+1::]

      if first in studentName and last in studentName:
        print 'MATCH: ' + first + ' ' + last + ' in ' + studentName

       # pdfFiles = os.listdir(PDF_DIRECTORY)

        for root, dirs, files in os.walk(PDF_DIRECTORY):
          if 'single' not in root:
            for pdf in files:
              if key in pdf:
                print '\t\t ' + pdf + ' ends with PDF'

        #for pdf in pdfFiles:
                print '\t\t matched key to pdf'
                print '\t\t renaming ' + pdf + ' to ' + prefix + pdf

                outputPDFs = root[:root.rfind('\\'):] + '\\single\\'
                print outputPDFs + prefix + pdf
                if not os.path.exists(outputPDFs):
                  os.makedirs(outputPDFs)
                os.rename(os.path.join(root, pdf), outputPDFs + os.sep + prefix + 'assignsubmission_file_' + pdf)


def rename_to_classic_structure():
  onlyfiles = os.listdir(SUBMISSION_DIRECTORY)
  mappings = open_file("007-studentMapping.csv");
       
  for f in onlyfiles:
    if f.endswith(".java"):
    #if not f.endswith(".py") and  not f.endswith(".csv"):
      print f
      project_file_name = f[f.rfind("_")+1::]
      print '\t' + project_file_name
      name_in_file = get_student_name(f).lower();

      print name_in_file

      for key, value in mappings.iteritems():
        first = value[:value.find(" ")]
        last = value[value.find(" ")+1::]

        if first.lower() in name_in_file and last.lower() in name_in_file:
          print '\t\t' + value + ' IN ' + name_in_file
          if not os.path.exists(key):
            print '\t\tmaking directory ' + key
            os.makedirs(key)
          print '\t\tMoving ' + project_file_name + ' for ' + key
          if os.path.isfile(key + "/" + project_file_name): 
              os.rename(f, key + "/" + project_file_name + "2")
          else:
              os.rename(f, key + "/" + project_file_name)

if __name__ == "__main__":
    main(sys.argv[1:])
    
#print os.path.splitext("path_to_file")[0]
