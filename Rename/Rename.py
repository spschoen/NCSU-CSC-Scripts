#! /usr/bin/python
import os
import sys
import csv

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
  mappings = open_file("studentMapping.csv");

  DIRECTORY = "C:\Users\Adminuser\Google Drive\Current\CSC116 - Fall 2016\Submissions\CSC 116 Fall 2016-Project 1 Submit--163169"
  onlyfiles = os.listdir(DIRECTORY)

  for f in onlyfiles:
    if f.endswith(".java"):
      print f
      project_file_name = f[f.rfind("_")+1::]
      print '\t' + project_file_name
      name_in_file = get_student_name(f);

      for key, value in mappings.iteritems():
        first = value[:value.find(" ")]
        last = value[value.find(" ")+1::]

        if first in name_in_file and last in name_in_file:
          print '\t\t' + value + ' IN ' + name_in_file
          if not os.path.exists(key):
            os.makedirs(key)
          print '\t\t\tMoving ' + project_file_name + ' for ' + key            
          os.rename(f, key + "/" + project_file_name)

if __name__ == "__main__":
    main(sys.argv[1:])
    
#print os.path.splitext("path_to_file")[0]
