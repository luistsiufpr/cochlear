# cochlear
Programming assignment

This includes the EXE files to avoid build issues.

The branches are:
* Main - First created with all the rules in the UI
* withDataModule - Based on Main, it contains a data module to hold the business rules
* withClass - **FINAL SOLUTION**
  * Based on the withDataModule adding a class to encapsulate the implementation and test cases with DUnit. 
  * Brings the correct solution for processing the string to find the sequences. There was a bug in the Main and withDataModule branches
  * Memory leaks analysed with FastMM in this branch, but not added to the project to avoid dependencies.
