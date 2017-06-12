/*	Chad R. Bhatti
	03.25.2015
	proc_datasets_example.sas
*/



libname mydata	'/courses/d6fc9ae5ba27fe300/c_3505/SAS_Data/' access=readonly;


/* 
Use PROC DATASETS to list out the SAS data sets in a directory defined
by a libname statement;

Extremely useful when working on a Unix server, but applicable to any
version of SAS.
*/


* Very simple syntax;
proc datasets library=mydata; run; quit;



